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
 * Written in the D programming language.
 */

module jaypha.spinna.process;

import std.range;
import std.algorithm;

import jaypha.spinna.global;
import jaypha.spinna.authorisation;
import std.uni;
import gen.router;
import std.traits;
import std.conv;

/*
 * Procedure
 *
 * 1. Interperet the HTTP request and put info into easy to use data structures.
 * 2. Run the router to determine which service to call. Failure results in a 404 response.
 * 3. Test if service is authorised. Generate a 403 if not.
 * 4. Run the service.
 * 5. Catch any exceptions to generate an error page.
 * 6. Output the HTTP response.
 */

// TODO must test for service of type void Delegate()

enum bool isRouterController(R) = is(typeof(
  (inout int = 0)
  {
    if (R.hasRoute("","")) {}
    if (R.isAuthorised) {}
    string h = R.redirect;
    R.service();
  }
));

void processRequest(I,O,RC)
(
  string[string] env,
  I inputStream,
  O outputStream,
  void delegate(ulong, string) errorHandler
) if (isOutputRange!(O,immutable(ubyte)[]) && isRouterController!RC)
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
      errorHandler(404, "Page not found: "~request.path);
    }
    else
    {
        if (RC.isAuthorised)
        {
          RC.service();
        }
        else
        {
          auto redirect = RC.redirect;
          if (redirect)
            response.redirect(redirect~"?url="~request.path);
          else
            errorHandler(403, "Not authorised to access: "~request.path);
        }
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
    errorHandler(e.code,e.msg);
  }
  catch (Exception e)
  {
    errorHandler(500,e.msg);
  }

  response.copy(outputStream);
}
