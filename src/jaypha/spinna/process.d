//Written in the D programming language
/*
 * Main processing routine for HTTP requests.
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
import std.uni;
import gen.router;
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

// TODO must test for service of type void Delegate()

enum bool isRouterController(R) = is(typeof(
  (inout int = 0)
  {
    if (R.hasRoute("","")) {}
    R.doService();
  }
));

//---------------------------------------------------------------------------------------
// This would be defined as an alias in an appropriate main file.

struct RequestProcessor(I,O,RC)
  if (isOutputRange!(O,immutable(ubyte)[]) && isRouterController!RC)
{
  shared static void function (ulong, string, O) errorHandler;
  shared static bool function () preServiceHandler;
  shared static void function () postServiceHandler;

  static void run(strstr env, I inputStream, O outputStream, O errorStream)
  {
    scope(exit) { session.clear(); request.clear(); response.clear(); }
    try
    {
      request.prepare(env, inputStream);

      if ("SPINNA_SESSION" in request.cookies)
        session.sessionId = request.cookies["SPINNA_SESSION"].value;

      if (!RC.hasRoute(request.path,toLower(request.method)))
      {
        // Could not match.
        errorHandler(404, "Page not found: "~request.path, outputStream);
      }
      else
      {
        bool doService = true;
        if (preServiceHandler)
          doService = preServiceHandler();
        if (doService)
          RC.doService();
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
      // A malformed HTTP request
      // Give 4xx response
      errorHandler(e.code,e.msg, outputStream);
    }
    catch (Exception e)
    {
      // General problem
      errorHandler(500,e.msg, outputStream);
    }

    response.copy(outputStream);
  }
}

import std.string;
import jaypha.inet.mime.reading;

//----------------------------------------------------------------------------
// Extracts environment variables from the main headers of a mime document.
//
// As a concession to FCGI, RequestProcessor assumes that the main HTTP
// headers have already been read an processed. If you are reading from a
// source that doesn't do this, then use extractEnv to extract information
// from the HTTP headers and put it into enviroment variables.

auto extractEnv(R)(ref strstr env, R reader)
{
  auto entity = mimeEntityReader(reader);
  foreach (h; entity.headers)
  {
    switch (h.name)
    {
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
