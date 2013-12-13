module jaypha.console.console;

import jaypha.server.process;
import jaypha.types.types;
import jaypha.router;

import std.stdio;
import std.range;
import std.conv;
import std.array;

void main(string[] args)
{
  saa env;
  auto s = split(args[$-1],"?");
  env["SCRIPT_NAME"] = s[0];
  env["QUERY_STRING"] = s[1];
  env["REQUEST_METHOD"] = "POST";
  env["CONTENT_TYPE"] = "application/x-www-form-urlencoded";

  string txt = "r=5&q=10&t=3+12&n=8";
  env["CONTENT_LENGTH"] = to!string(txt.length);

  auto r1 = inputRangeObject(txt);

  processRequest!(typeof(r1),typeof(stdout.lockingTextWriter))
  (
    env,
    r1,
    stdout.lockingTextWriter,
    stderr.lockingTextWriter,
    &find_route
  );
}
