//Written in the D programming language
/*
 * 'Main' file for interfacing with FCGI servers.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.main.fcgi;

public import jaypha.fcgi.loop;
public import jaypha.spinna.processNew;

import jaypha.spinna.router_controller_no_auth;

alias RP!(FcgiInStream,FcgiOutStream,RouterController) requestProcessor;

void main()
{
  fcgiLoop(&processFcgi);
}


// Process serves as an adapter between FCGI_loop and process_request

void processFcgi(ref FcgiRequest r)
{
  requestProcessor.run
  (
    r.env,
    r.fcgiIn,
    r.fcgiOut,
    r.fcgiErr,
  );
}
