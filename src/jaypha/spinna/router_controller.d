//Written in the D programming language
/*
 * Router Controller with authorisation
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.spinna.router_controller;

import gen.router;
public import jaypha.spinna.authorisation;

struct SpinnaRouter(alias fr, alias aa)
{
  static ActionInfo info;

  static bool hasRoute(string path, string method)
  {
    info = find_route(path,method);
    return info.action !is null;
    return false;
  }

  static @property bool isAuthorised()
  {
    if (info.roles == 0)
      return true;
    else
      return hasRole(info.roles);
  }

  static @property string redirect()
  {
     if (!isLoggedIn())
      return info.redirect;
     else
       return null;
  }

  static void service() { info.service(); }
}
