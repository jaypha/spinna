

module jaypha.spinna.modules.auth.authorization;

import jaypha.types;

import std.conv;
import std.traits;

bool has_role(RoleType)(ref strstr auth, RoleType role) if (is(RoleType == enum))
{
  return (to!uint(auth["roles"]) & role);
}

RoleType extract_role(RoleType)(ref strstr auth) if (is(RoleType == enum))
{
  auto roles = to!uint(auth["roles"]);

  foreach (j; EnumMembers!RoleType)
    if (roles & j)
      return j;
  throw new Exception("unknown role");
}

bool action_authorized(string action)
{
  return true;
}
