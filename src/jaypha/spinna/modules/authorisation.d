

module jaypha.spinna.modules.authorisation;

import std.conv;
import std.traits;

import jaypha.types;
import jaypha.spinna.global;

public import roles;

//----------------------------------------------------------------------------
// Authorisation - Permission to do something.

struct Permission
{
  AccountRole[] roles;
  bool redirect;
}

Permission[string] permissions;

static this()
{
  #line 1 "gen/permissions.tpl"
  mixin(import("gen/permissions.tpl"));
  #line 28 "jaypha.spinna.modules.authorisation"
}

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

//----------------------------------------------------------------------------
// authenication - identify an account, login.

import db;

enum auth_string(string table) = "select id, roles from "~table~" where username=";

ulong authenticate(string table = "account")(string username, string password, bool login = true)
{
  auto response = database.query_row(auth_string!table~database.quote(username)~" and password="~database.quote(password));
  if (response)
  {
    auto id = to!ulong(response["id"]);
    if (login)
    {
      session["login"].set!ulong("id", id);
      session["login"].set!ulong("roles", to!ulong(response["roles"]));
    }
    return id;
  }

  return 0;
}

//----------------------------------------------------------------------------

enum account_string(string table) = "select count(*) from "~table~" where username=";

bool account_exists(string table = "account")(string username, ulong account_id = 0)
{
  return (database.query_value(account_string!table ~ database.quote(username) ~ " and not id="~to!string(account_id)) != "0");
}

//----------------------------------------------------------------------------

bool is_logged_in()
{
  return session.has("login");
}

//----------------------------------------------------------------------------

ulong get_logged_in_id()
{
  if (session.has("login"))
    return session["login"].get!ulong("id");
  else
    return 0;
}
