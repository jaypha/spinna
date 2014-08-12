
module test_router;


import jaypha.spinna.router_tools;

import std.stdio;

void test_routr()
{
//  writeln(match_static_route!("home","/", "primalinx.pub.home.get_home"));
  writeln(match_static_route!("admin.home","/home", "x.y"));
  writeln(match_sub_route!("/admin", "find_routeadmin"));
}
