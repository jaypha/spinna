/*
 * Access Control
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.spinna.authorisation;

import std.conv;
import std.traits;
import std.exception;

import jaypha.types;
import jaypha.spinna.global;

//----------------------------------------------------------------------------
// Authorisation - Permission to do something.


  //----------------------------------------------------------------------------

  bool has_role(ulong roles, ulong role)
  {
    return (roles & role) != 0;
  }

  bool has_role(ulong role)
  {
    if (!is_logged_in()) return false;
    return (session["login"].get!ulong("roles") & role) != 0;
  }

  //----------------------------------------------------------------------------

  ulong extract_role(R)()
  {
    assert(is_logged_in());
    return extract_role!R(session["login"].get!ulong("roles"));
  }

  ulong extract_role(R)(ulong roles)
  {
    foreach (j; EnumMembers!R)
      if (roles & j)
        return j;
    return 0;
  }



//----------------------------------------------------------------------------
// authenication - identify an account, login.

enum auth_string(string table) = "select id, roles from "~table~" where username=";

string authenticate(Database, string table = "account")(Database database, string username, string password, bool login = true)
{
  auto response = database.query_row(auth_string!table~database.quote(username)~" and password="~database.quote(password));
  if (response)
  {
    if (login)
    {
      session["login"].set_str("id", response["id"]);
      session["login"].set!ulong("roles", to!ulong(response["roles"]));
    }
    return response["id"];
  }

  return null;
}

//----------------------------------------------------------------------------

enum account_string(string table) = "select id from "~table~" where username=";

bool account_exists(Database, string table = "account")(Database database, string username, string account_id = null)
{
  auto aid = database.query_value(account_string!table ~ database.quote(username));

  if (aid is null) return false;
  else return account_id != aid;
}

//----------------------------------------------------------------------------

void logout()
{
  session.clear();
}

/+
enum account_string(string table) = "select count(*) from "~table~" where username=";

bool account_exists(Database, string table = "account")(Database database, string username, string account_id = null)
{
  import std.exception;
  import jaypha.string;

  if (id is null)
    return (database.query_value(account_string!table ~ database.quote(username)) != "0");
  enforce(is_digits(account_id));
  return (database.query_value(account_string!table ~ database.quote(username) ~ " and not id="~account_id) != "0");
}
+/
//----------------------------------------------------------------------------

bool is_logged_in()
{
  return session.has("login");
}

//----------------------------------------------------------------------------

string get_logged_in_id()
{
  if (session.has("login"))
    return session["login"].get_str("id");
  else
    return null;
}

ulong get_logged_in_roles()
{
  if (session.has("login"))
    return session["login"].get!ulong("roles");
  else
    return 0;
}
