/*
 * A persistant storage of values.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.spinna.session;

import jaypha.types;
import jaypha.io.serialize;
import jaypha.conv;

import std.random;
import std.array;
import std.algorithm;
import std.range;
import std.datetime;
import std.file;
import std.format;

import config.general;

/*
 * config must supply the following configurations
 * - session_dir as string
 * - time_limit as ulong
 */


struct Session
{
  @property bool expired() { if (!active) load(this); return _expired; }
  string session_id;

  Activity opIndex(string name) { return get(name); }

  Activity get(string name)
  {
    if (!active) load(this);

    if (!(name in activities))
      activities[name] = new Activity();

    return activities[name];
  }

  bool has(string name) { if (!active) load(this); return !((name in activities) is null); }

  void remove(string name) { if (!active) load(this); activities.remove(name); }


  void renew() { _expired = false; }
  this(string sessionid = null) { this.session_id = session_id; }

  bool active = false;

  int opApply(int delegate(ref string, ref Activity) dg)
  {
    int result = 0;
    foreach (i, v; activities)
    {
      result = dg(i, v);
      if (result) break;
    }
    return result;
  }

  private:
    Activity[string] activities;
    bool _expired = false;
    long timestamp;
}

class Activity
{
  final void set(T)(string name, T value) { values[name] = serialize!(T)(value); }
  final void unset(string name) { values.remove(name); }
  
  alias set!(int)    set_int;
  alias set!(cstring) set_str;

  final T get(T)(string name)
  {
    if (name in values)
    {
      cstring s = values[name];
      return unserialize!(T)(s);
    }
    else
      return T.init;
  }

  alias get!(int)   get_int;
  alias get!(string) get_str;

  final bool is_set(string name) { return !((name in values) is null); }

  int opApply(int delegate(ref string, ref cstring) dg)
  {
    int result = 0;
    foreach (i, v; values)
    {
      result = dg(i, v);
      if (result) break;
    }
    return result;
  }

  private:
    cstring[string] values;
}

string save(ref Session sess)
{
  auto app = appender!cstring();

  if (sess.expired)
    app.put(serialize!(long)(sess.timestamp));
  else
    app.put(serialize!(long)(Clock.currStdTime()));
  app.put
  (
    custom_serialize!
    (
      serializeActivity,
      Activity[string]
    )
    (sess.activities)
  );

  if (sess.session_id is null)
  {
    while (true)
    {
      sess.session_id = rndGen().take(4).map!(bin2hex).join();
      if (!exists(session_dir~sess.session_id))
        break;
    }
  }

  write(session_dir~sess.session_id,app.data);
  return sess.session_id;
}

void load(ref Session sess)
{
  sess.active = true;
  if (sess.session_id !is null)
  {
    char[] filename = session_dir.dup ~ sess.session_id;

    if (!exists(filename))
      sess._expired = true;
    else
    {
      cstring contents = readText!string(filename);
      sess.timestamp = unserialize!(long)(contents);
      if (Clock.currStdTime() - sess.timestamp > time_limit)
        sess._expired = true;
      sess.activities = custom_unserialize!(unserializeActivity,Activity[string])(contents);
      //auto len = checkLengthTypeStart(contents, 'o');
      //foreach (i;0..len)
      //{
      //  auto s = unserialize!(string)(contents);
      //  sess.activities[s] = new Activity();
      //  sess.activities[s].values = unserialize!(cstring[string])(contents);
      //}
    }
  }
}

/*

cstring serialize(T:Session)(T a)
{
  auto a = appender!(cstring);
  a.put("a2");  // array of two items
  a.put(serialize!(ulong)(timestamp));
  a.put(serialize!(Activity[string])(a.activities));
  return app.data;
}

T unserialize (T:Session)(ref cstring str))
{
  T session = T("");
  auto len checkLengthStart(str, 'a');
  if (len != 2) throw new Exception("Bad Serialize string");
  auto timestamp = unserialize!(ulong)(timestamp);
  session.expired = (timestamp < x);
  session.activities = unserilize!(Activity[string])(str);
  return session;
}

void unserialize(ref Session session, cstring str)
*/


cstring serializeActivity(Activity a)
{
  return serialize!(const(char)[][string])(a.values);
}


Activity unserializeActivity(ref cstring str)
{
  auto a = new Activity();
  a.values = unserialize!(cstring[string])(str);
  return a;
}

unittest
{
  import std.stdio;

  Session s = Session();

  auto a = s.get("staff/members/list");

  assert(a.values.length == 0);

  assert(a.get!(int)("abc") == 0);
  assert(a.get!(char[])("abc") == "");

  a.set!(int)("abc", 42);
  a.set!(int)("def", 63);

  assert(a.get!(int)("abc") == 42);
  assert(a.get!(int)("def") == 63);

  a.set!(char[])("abc", "xyz".dup);
  assert(a.get!(char[])("abc") == "xyz");

  auto b = s.get("staff/members");

  assert(b.get!(int)("abc") == 0);
  assert(b.get!(char[])("abc") == "");

  b.set!(int)("abc", 89);
  assert(b.get!(int)("abc") == 89);
  assert(a.get!(char[])("abc") == "xyz");

  auto c = s.get("staff/members/list");

  assert(c.get!(char[])("abc") == "xyz");
  assert(c.get!(int)("def") == 63);

  c.set!(long)("long", 200);
  assert(c.get!(long)("long") == 200);
  assert(a.get!(long)("long") == 200);

  auto sessid = save(s);

  Session w = Session(sessid);
  assert(!w.expired());
  assert(w.active);

  auto wa = s.get("staff/members/list");
  assert(wa.values.length == 3);
  assert(wa.get!(char[])("abc") == "xyz");
  assert(wa.get!(int)("def") == 63);
  assert(wa.get!(long)("long") == 200);
}
