/*
 * Struct for making HTTP connections to remote hosts.
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.http.connection;

import jaypha.http.method;
import jaypha.mime.entity;


struct HttpConnection
{
  string host;
  string keep_alive;

  HttpResponse send_request(HttpMethod method, bool secure, bool keep_alive, ref MimeEntity content)
  {
  }
}
