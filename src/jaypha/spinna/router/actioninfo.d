// Written in the D programming language.
/*
 * ActionInfo definition for route resolution
 *
 * Copyright 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.spinna.router.actioninfo;

struct ActionInfo
{
  string action;
  void delegate() service;
}
