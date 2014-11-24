//Written in the D programming language
/*
 * Router controller for no authorisation
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.spinna.router_controller_no_auth;

import gen.router;
import std.range;

struct RouterController
{
  static ActionInfo info;

  static bool hasRoute(string path, string method)
  {
    info = find_route(path,method);
    return info.action !is null;
  }

  static immutable bool isAuthorised = true;

  static immutable string redirect = null;

  static void service() { info.service(); }
}
