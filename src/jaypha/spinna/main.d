module jaypha.server.main;

import std.range;

import jaypha.fcgi.loop;
import jaypha.server.process;
import jaypha.router;

import jaypha.spinna.response;
import jaypha.spinna.pagebuilder.document;

import jaypha.spinna.global;

void process(ref FCGI_Request r)
{
  void default_error_handler(uint code, string message)
  {
    if (code/100 == 5) // Only interested in 500 errors.
      r.fcgi_err.put("Spinna Error: "~to!string(code)~": message");

    response.status(code);

    Document doc;
    auto body = make_error_document(doc);
    
    body.set(code, "code");
    body.set(message, "message");
    
    transfer(doc,response);
  }

  processRequest
  (
    r.env,
    r.fcgi_in,
    r.fcgi_out,
    &find_route,
    &default_error_handler
  );
}

void main()
{
  FCGI_loop(&process);
}
