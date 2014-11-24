//Written in the D programming language
/*
 * A session persistant storage of values.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
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
 * - session_time_limit as ulong
 */


struct Session
{
  @property bool expired() { if (!active) load(this); return _expired; }
  string sessionId;

  Activity opIndex(string name) { return get(name); }
  Activity* opBinaryRight(string op : "in")(string name) { return (name in activities); }

  Activity get(string name)
  {
    if (!active) load(this);

    if (!(name in activities))
      activities[name] = new Activity();

    return activities[name];
  }

  bool has(string name)
  {
    if (!active) load(this);
    return !((name in activities) is null);
  }

  void remove(string name) { if (!active) load(this); activities.remove(name); }


  void renew() { _expired = false; }
  this(string sid = null) { this.sessionId = sid; }

  bool active = false;

  int opApply(int delegate(ref string, ref Activity) dg)
  {
    if (!active) load(this);

    int result = 0;
    foreach (i, v; activities)
    {
      result = dg(i, v);
      if (result) break;
    }
    return result;
  }

  void clear()
  {
    activities = activities.init;
    sessionId = null;
    active = false;
  }

  void clobber()
  {
    if (sessionId !is null)
    {
      char[] filename = sessionDir.dup ~ sessionId;
      .remove(filename);
      clear();
    }
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
  
  alias set!(long)   setInt;
  alias set!(string) setStr;

  final T get(T)(string name)
  {
    if (name in values)
    {
      string s = values[name];
      return unserialize!(T)(s);
    }
    else
      return T.init;
  }

  alias get!(long)   getInt;
  alias get!(string) getStr;

  final bool isSet(string name) { return !((name in values) is null); }

  int opApply(int delegate(ref string, ref string) dg)
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
    string[string] values;
}

string save(ref Session sess)
{
  auto app = appender!string();

  if (sess.expired)
    app.put(serialize!(long)(sess.timestamp));
  else
    app.put(serialize!(long)(Clock.currStdTime()));
  app.put
  (
    customSerialize!
    (
      serializeActivity,
      Activity[string]
    )
    (sess.activities)
  );

  if (sess.sessionId is null)
  {
    while (true)
    {
      sess.sessionId = rndGen().take(4).map!(bin2hex).join();
      if (!exists(sessionDir~sess.sessionId))
        break;
    }
  }

  write(sessionDir~sess.sessionId,app.data);
  return sess.sessionId;
}

void load(ref Session sess)
{
  sess.active = true;
  if (sess.sessionId !is null)
  {
    char[] filename = sessionDir.dup ~ sess.sessionId;

    if (!exists(filename))
      sess._expired = true;
    else
    {
      string contents = readText!string(filename);
      sess.timestamp = unserialize!(long)(contents);
      if (Clock.currStdTime() - sess.timestamp > sessionTimeLimit)
        sess._expired = true;
      sess.activities = customUnserialize!(unserializeActivity,Activity[string])(contents);
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


string serializeActivity(Activity a)
{
  return serialize!(string[string])(a.values);
}


Activity unserializeActivity(ref string str)
{
  auto a = new Activity();
  a.values = unserialize!(string[string])(str);
  return a;
}
/+
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
+/