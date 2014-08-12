
module test_auth;

import std.stdio;

import roles;
import jaypha.spinna.global;

import db;

void test_authorisation()
{
  database.host = "localhost";
  database.dbname = "primalinx";
  database.username = "root";

  assert(authenticate(database,"root","root",false) != 0);
  assert(authenticate(database,"root","bob",false) == 0);
  assert(authenticate(database,"bob","bob",false) == 0);
  assert(is_logged_in() == false);

  authenticate(database,"root","root");
  assert(is_logged_in() == true);

  ulong roles = session["login"].get!ulong("roles");

  assert(Auth.has_role(TestRole.Admin));
  assert(!Auth.has_role(TestRole.Coach));
  assert(Auth.extract_role() == TestRole.Admin);

  writeln("Role is: ",account_role_labels[Auth.extract_role()]);

  ulong some_roles = TestRole.Dispatch | TestRole.Member;
  
  assert(Auth.action_authorised("admin.home"));
  assert(!Auth.action_authorised("admin.home", some_roles));
  some_roles = TestRole.Dispatch | TestRole.Coach;
  assert(Auth.action_authorised("admin.home", some_roles));
}
