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

import jaypha.types;
import jaypha.spinna.global;

//----------------------------------------------------------------------------
// Authorisation - Permission to do something.

// Account Role is an enumeration of values that are bitwise mutually exclusive.
 
template Authorisation(AccountRole)
{
  struct Permission
  {
    AccountRole[] roles;
    bool redirect;
  }

  Permission[string] permissions;

  //----------------------------------------------------------------------------

  bool has_role(ulong roles, AccountRole role)
  {
    return (roles & role) != 0;
  }

  bool has_role(AccountRole role)
  {
    if (!is_logged_in()) return false;
    return (session["login"].get!ulong("roles") & role) != 0;
  }

  //----------------------------------------------------------------------------

  AccountRole extract_role()
  {
    assert(is_logged_in());
    return extract_role(session["login"].get!ulong("roles"));
  }

  AccountRole extract_role(ulong roles)
  {
    foreach (j; EnumMembers!AccountRole)
      if (roles & j)
        return j;
    return AccountRole.None;
  }

  //----------------------------------------------------------------------------

  bool action_authorised(string action)
  {
    return action_authorised
    (
      action,
      is_logged_in()?session["login"].get!ulong("roles"):0
    );
  }

  bool action_authorised(string action, ulong roles)
  {
    // If no permissions are defined then access is universal.
    if (action !in permissions)
      return true;

    // Admin always has authorisation.
    if (has_role(roles, AccountRole.Admin))
      return true;

    // Check against listed roles.
    foreach (r; permissions[action].roles)
      if (has_role(roles, r))
        return true;

    return false;
  }

  //----------------------------------------------------------------------------

  bool redirect_unauthorised(string action)
  {
    assert(action in permissions);
    return permissions[action].redirect;
  }
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
