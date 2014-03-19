
module jaypha.spinna.modules.auth.authentication;

import jaypha.types;

import jaypha.spinna.global;

import std.conv;

bool is_logged_in()
{
  return session.has("login");
}

struct Authenticate(DB)
{
  DB database;

  ulong id;
  string username;
  string password;

  ulong roles;

  //-------------------------------------------------------------------------

  bool authenticate(bool login = false)
  {
    auto response = database.query_row("select id, roles from authenticate where username="~database.quote(username)~" and password="~database.quote(password));
    if (response)
    {
      id = to!ulong(response["id"]);
      roles = to!ulong(response["roles"]);
      if (login)
      {
        session["login"].set!ulong("id", id);
        session["login"].set!ulong("roles", roles);
      }
      return true;
    }

    return false;
  }

  //-------------------------------------------------------------------------

  bool exists()
  {
    string res = database.query_value("select count(*) from authenticate where username="~database.quote(username)~" and id!="~to!string(id));
    return res != "0";
  }

  //-------------------------------------------------------------------------

  bool has_role(RoleType)(RoleType role) if (is(RoleType == enum))
  {
    return (roles & role) != 0;
  }

  //-------------------------------------------------------------------------

  this(strstr props) { fill(props); id = to!ulong(props["id"]); }
  
  bool load(ulong _id)
  {
    auto props = database.get("authenticate", _id);
    if (props is null) return false;
    id = _id;
    fill(props);
    return true;
  }

  private void fill(strstr props)
  {
    username = props["username"];
    password = props["password"];
    roles = to!ulong(props["roles"]);
  }

  //-------------------------------------------------------------------------

  ulong save()
  {
    strstr holding =
    [
      "username" : username,
      "password" : password,
      "roles" : to!string(roles)
    ];

    if (id)
      database.set("authenticate", holding, id);
    else
      id = database.quick_insert("authenticate", holding);

    return id;
  }
}
