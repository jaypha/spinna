module roles;

import std.exception;

enum TestRole : uint
{
  Admin    = 0x00000001,
  Coach    = 0x00000002,
  Dispatch = 0x00000004,
  Clerk    = 0x00000008,

  Member   = 0x00010000,
  Sponsor  = 0x00020000,
  Customer = 0x00040000,
  None     = 0
};

public import jaypha.spinna.authorisation;

alias Auth = Authorisation!TestRole;

immutable string[TestRole] account_role_labels;

static this()
{
  auto l =
  [
    TestRole.None : "None",
    TestRole.Admin : "Admin",
    TestRole.Coach : "Coach",
    TestRole.Dispatch : "Dispatch",
    TestRole.Clerk : "Clerk",
    TestRole.Member : "Member",
    TestRole.Sponsor : "Sponsor",
    TestRole.Customer : "Customer"
  ];
  account_role_labels = assumeUnique(l);
  mixin(import("gen/permissions.tpl"));
}
