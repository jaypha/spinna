
module jaypha.dbms.variables;

import jaypha.types;
import jaypha.io.serialize;
import jaypha.conv;


struct Variables(Database, string table)
{
  Database database;
  private strstr values;

  bool is_set(string name)
  {
    if (name in values)
      return true;
    else
      return (database.query_value("select count(*) from "~table~" where name='"~name~"'") != "0");
  }

  T get(T)(string name)
  {
    if (!(name in values))
    {
      auto s = database.query_value("select value from "~table~" where name='"~name~"'");
      if (s is null)
        return T.init;
      else
      {
        values[name] = s;
      }
    }
    cstring s = values[name];
    return unserialize!(T)(s);
  }

  void set(T)(string name, T value)
  {
    values[name] = serialize!(T)(value);
    database.query("replace "~table~" set name='"~name~"', value="~database.quote(values[name]));
  }
  void unset(string name)
  {
    database.query("delete from "~table~" where name='"~name~"'");
    values.remove(name);
  }

  alias set!(int)    set_int;
  alias set!(cstring) set_str;

  alias get!(int)   get_int;
  alias get!(string) get_str;
}
