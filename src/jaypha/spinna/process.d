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

import gen.router;

/*
 * Procedure
 *
 * 1. Interperet the HTTP request and put info into easy to use data structures.
 * 2. Run the router to determine which service to call. Failure results in a 404 response.
 * 3. Test is service is authorised. Generate a 403 if not.
 * 4. Run the service.
 * 5. Catch any exceptions to generate an error page.
 * 6. Generate an HTTP response.
 */

void process_request(I,O,alias AuthInst = null)
(
  string[string] env,
  I input_stream,
  O output_stream,
  void delegate(uint, string) error_handler
) if (isOutputRange!(O,immutable(ubyte)[]))
{
  try
  {
    request.prepare(env, input_stream);
    if ("SPINNA_SESSION" in request.cookies)
      session.session_id = request.cookies["SPINNA_SESSION"].value;

    auto action_info = find_route(request.path);

    if (action_info.action is null)
    {
      // Could not match.
      error_handler(404, "Page not found: "~request.path);
    }
    else
    {
      static if (is(AuthInst.Permission))
      {
        if (AuthInst.action_authorised(action_info.action))
          action_info.service();
        else
        {
          if (AuthInst.redirect_unauthorised(action_info.action) && !is_logged_in())
            response.redirect("/login?url="~request.path);
          else
            error_handler(403, "Not authorised to access: "~request.path);
        }
      }
    }
    if (session.active)
    {
      auto sessid = save(session);
      response.set_session_cookie("SPINNA_SESSION",sessid);
    }
  }
  catch (HttpException e)
  {
    // A malformed HTTP request
    // Give 4xx response
    error_handler(e.code,e.msg);
  }
  catch (Exception e)
  {
    error_handler(500,e.msg);
  }

  response.copy(output_stream);
}
