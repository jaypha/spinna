//Written in the D programming language
/*
 * Server adapter for FCGI.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

//---------------------------------------------------------------------------
// fcgiRequestProcessor
//---------------------------------------------------------------------------
// This module defines a RequestProcessor instance that interfaces with FCGI.
//---------------------------------------------------------------------------

module jaypha.spinna.main.fcgi;

public import jaypha.fcgi.loop;
public import jaypha.spinna.process;

import jaypha.spinna.global;

//---------------------------------------------------------------------------

alias RequestProcessor!(FcgiInStream,FcgiOutStream)
  fcgiRequestProcessor;

//---------------------------------------------------------------------------

void main()
{
  fcgiLoop(&processFcgi);
}

//---------------------------------------------------------------------------
// Process serves as an adapter between fcgiLoop and RequestProcessor

void processFcgi(ref FcgiRequest r)
{
  isFCGI = true;

  fcgiRequestProcessor.run
  (
    r.env,
    r.fcgiIn,
    r.fcgiOut,
    r.fcgiErr,
  );
}
