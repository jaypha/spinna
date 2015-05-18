

module testsession;

import jaypha.spinna.session;

import std.stdio;

void main()
{
  writeln("testing session");
  auto session = Session();

  session["a/b/c"].setStr("x","123");
  assert(session["a/b/c"].getStr("x") == "123");

  writeln("about to save session");
  auto sessId = save(session);
  writeln("session saved");

  auto newSession = Session(sessId);
  assert(!newSession.expired);
  assert(newSession.active);

  assert(newSession["a/b/c"].getStr("x") == "123");
  writeln("finished testing session");
}
