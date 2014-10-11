//Written in the D programming language
/*
 * Convert between MySQL time format and D time structures.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.dbms.mysql.date;

import std.datetime;
import std.array;


SysTime toSysTime(string mysqlTime)
{
  SysTime t;
  auto s = replaceFirst(mysqlTime, " ", "T");
  return t.fromISOExtString(s);
}

string toMySqlTime(SysTime time)
{
  return null; // TODO
}