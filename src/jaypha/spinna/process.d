module jaypha.spinna.process;


import jaypha.spinna.global;

import std.range;
import std.algorithm;

/*
 * Procedure
 *
 * 1. Interperet the HTTP request and put info into easy to use data structures.
 * 2. Run the router to determine which service to call. Failure results in a 404 response.
 * 3. Run the service.
 * 4. Catch any exceptions to generate an error page.
 * 5. Generate an HTTP response.
 */

void processRequest(I,O)
(
  string[string] env,
  I input_stream,
  O output_stream,
  void delegate() function(string) router,
  void delegate(uint, string) error_handler
) if (isOutputRange!(O,immutable(ubyte)[]))
{
  try
  {
    request.prepare(env, input_stream);
    if ("SPINNA_SESSION" in request.cookies)
      session.session_id = request.cookies["SPINNA_SESSION"].value;
    auto service = router(request.path);
    if (service is null)
    {
      // Could not match.
      error_handler(404, "Page not found: "~request.path);
    }
    else
    {
      service();
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
