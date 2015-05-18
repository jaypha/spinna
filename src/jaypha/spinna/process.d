//Written in the D programming language
/*
 * Main processing code for HTTP requests.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 */

module jaypha.spinna.process;

import std.range;
import std.algorithm;

import jaypha.spinna.global;
import jaypha.spinna.router.actioninfo;
import std.uni;
import std.traits;
import std.conv;

/*
 * Procedure
 *
 * 1. Interperet the HTTP request and put info into easy to use data structures.
 * 2. Run the router to determine which service to call. Failure results in a 404 response.
 * 3. Call pre-process routine, if any. Pre-process routine may perform authorisation
 *    or other validation.
 * 4. Run the service, if OK'd by pre-process.
 * 5. Run post-process routine, if any.
 * 6. Catch any exceptions to generate an error page.
 * 7. Output the HTTP response.
 */

//---------------------------------------------------------------------------------------
// This would be defined as an alias in an appropriate adaptor file.
//---------------------------------------------------------------------------------------
struct RequestProcessor(I,O)
  if (isOutputRange!(O,immutable(ubyte)[]))
//---------------------------------------------------------------------------------------
{
  alias O OutputRange;
  shared static void function (ulong, string, ref O) errorHandler;
  shared static bool function () preServiceHandler;
  shared static void function () postServiceHandler;
  shared static ActionInfo function (string,string) findRoute;

  static void run(strstr env, ref I inputStream, ref O outputStream, ref O errorStream)
  {
    assert(errorHandler);
    assert(findRoute);
    scope(exit) { session.clear(); request.clear(); response.clear(); }
    try
    {
      if (!isFCGI)
      {
        auto r = extractEnv(env, inputStream);
        request.prepare(env, r);
      }
      else
        request.prepare(env, inputStream);

      if ("SPINNA_SESSION" in request.cookies)
        session.sessionId = request.cookies["SPINNA_SESSION"].value;

      auto info = findRoute(request.path,toLower(request.method));

      if (info.action is null)
      {
        // Could not match.
        errorHandler(404, "Page not found: "~request.path, errorStream);
      }
      else
      {
        request.environment["CURRENT_ACTION"] = info.action;

        bool doService = true;
        if (preServiceHandler)
          doService = preServiceHandler();
        if (doService)
          info.service();
        if (postServiceHandler)
          postServiceHandler();
      }
      if (session.active)
      {
        auto sessid = save(session);
        response.setSessionCookie("SPINNA_SESSION",sessid);
      }
    }
    catch (HttpException e)
    {
      errorHandler(e.code,e.msg, errorStream);
    }
    catch (Exception e)
    {
      // General problem result in a 500 response.
      errorHandler(500,e.msg, errorStream);
    }

    response.copy(outputStream);
  }
}


//----------------------------------------------------------------------------
// Extracts environment variables from the main headers of a MIME document.
//
// As a concession to FCGI, RequestProcessor requires the main HTTP
// headers to be extracted and placed in an environment array.
// When not reading from an FCGI source, this function is called
// first to manually perform the extraction.

import std.string;
import jaypha.inet.mime.reading;

auto extractEnv(R)(ref strstr env, ref R reader)
{
  auto firstLine = appender!ByteArray();
  auto stuff = jaypha.inet.mime.reading.readUntil(reader, "\r\n");
  stuff.copy(firstLine);

  auto firstLineWords = split(cast(string)firstLine.data);

  env["REQUEST_METHOD"] = firstLineWords[0];
  env["REQUEST_URI"] = firstLineWords[1];
  env["SERVER_PROTOCOL"] = firstLineWords[2];

  auto s = split(firstLineWords[1],"?");
  env["SCRIPT_NAME"] = s[0];
  env["SCRIPT_URL"] = s[0];
  env["QUERY_STRING"] = s.length>1?s[1]:null;

  auto entity = mimeEntityReader(reader);
  foreach (h; entity.headers)
  {
    switch (h.name)
    {
      case "Host":
        env["HTTP_HOST"] = strip(h.fieldBody);
        env["SERVER_NAME"] = strip(h.fieldBody);
        break;
      case "Content-Type":
        env["CONTENT_TYPE"] = strip(h.fieldBody);
        break;
      case "Cookie":
        env["HTTP_COOKIE"] = strip(h.fieldBody);
        break;
      case "Referer":
        env["HTTP_REFERER"] = strip(h.fieldBody);
        break;
      case "Content-Length":
        env["CONTENT_LENGTH"] = strip(h.fieldBody);
        break;
      default:
        ;
    }
  }

  return entity.content;
}
