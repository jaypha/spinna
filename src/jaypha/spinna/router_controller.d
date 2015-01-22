//Written in the D programming language
/*
 * Router Controller for using Spinna's builtin router.
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/* This is the interface to Spinna's compile time generated
 * router. It rests on the assumption that the router code is
 * contiained in 'gen.router';
 */

module jaypha.spinna.router_controller;

import jaypha.spinna.global;

import gen.router;

/+
public import jaypha.spinna.authorisation;
struct RouterController(alias fr, alias aa)
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
+/


struct RouterController
{
  static ActionInfo info;

  static bool hasRoute(string path, string method)
  {
    info = find_route(path,method);
    request.environment["CURRENT_ACTION"] = info.action;
    return info.action !is null;
  }

  static void doService() { info.service(); }
}
