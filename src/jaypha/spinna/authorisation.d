//Written in the D programming language
/*
 * Access Control
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.authorisation;

import std.conv;
import std.traits;
import std.exception;

import jaypha.types;
import jaypha.spinna.global;

public import gen.roles;


// Account Role is an enumeration of ulong values that are bitwise mutually exclusive.

private pure nothrow @safe /* @nogc */ bool is_valid_role_type(E)(E type) if (is(E == enum) && isImplicitylyConvertible!(E,ulong))
{
  ulong run = 0;
  foreach (x;EnumMembers!E)
  {
    if (x & run) return false;
    run |= x;
  }
  return true;
}

enum isValidRoleType(E) = is_valid_role_type!E

// Check for existance of Role and RoleGroup
static assert(isValidRoleType(Role));
static assert(isImplicitylyConvertible!(RoleGroup,ulong));


//----------------------------------------------------------------------------
// Authorisation - Permission to do something.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Does 'r1' include any of 'r2'.

bool hasRole(RoleGroup r1, RoleGroup r2)
{
  return (r1 & r2) != 0;
}

// Does logged in person have any of 'r2'
bool hasRole(RoleGroup r2)
{
  if (!isLoggedIn) return false;
  return (session["login"].get!ulong("roles") & r2) != 0;
}

//----------------------------------------------------------------------------
// Returns the most significant role from 'roles'

Role extractRole(RoleGroup roles)
{
  foreach (j; EnumMembers!AccountRole)
    if (roles & j)
      return j;
  return 0;
}

//----------------------------------------------------------------------------
// Returns the most significant roles for logged in person.

Role extractRole()
{
  assert(isLoggedIn);
  return extractRole!AccountRole(session["login"].get!ulong("roles"));
}

//----------------------------------------------------------------------------

bool actionAuthorised(string action)
{
  return actionAuthorised
  (
    action,
    isLoggedIn?session["login"].get!ulong("roles"):0
  );
 }

bool actionAuthorised(string action, RoleGroup roles)
{
  // Admin always has authorisation.
  if (hasRole(roles, AccountRole.Admin))
    return true;

  // If no permissions are defined then access is universal.
  if (action !in permissions)
    return true;

  // Check against permission.
  return roles & permissions[action];
}

//----------------------------------------------------------------------------
// authenication - login
//----------------------------------------------------------------------------

void login(string userId, ulong roles)
{
  session["login"].setStr("id", userId);
  session["login"].set!ulong("roles", roles);
}

//----------------------------------------------------------------------------

void logout()
{
  session.clear();
}

//----------------------------------------------------------------------------

@property bool isLoggedIn()
{
  return session.has("login");
}

//----------------------------------------------------------------------------

@property string loggedInId()
{
  if (session.has("login"))
    return session["login"].getStr("id");
  else
    return null;
}

@property ulong loggedInRoles()
{
  if (session.has("login"))
    return session["login"].get!ulong("roles");
  else
    return 0;
}
