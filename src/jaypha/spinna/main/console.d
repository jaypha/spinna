//Written in the D programming language
/*
 * 'Main' file for interfacing with the console.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.main.console;

import jaypha.types;
public import jaypha.io.dirtyio;
import jaypha.spinna.processNew;
import jaypha.spinna.router_controller_no_auth;

import std.stdio;
import std.range;
import std.array;
import std.string;

import config.properties;

debug
{
  import Backtrace = backtrace.backtrace;
}

alias RP!(ReadIn,WriteOut,RouterController) requestProcessor;

void main(string[] args)
{
  strstr env;

  debug { Backtrace.install(stderr); }

  if (args.length < 3)
  {
    writeln("console <method> <url>");
    return;
  }

  env["SERVER_NAME"] = "Console";
  env["SERVER_SOFTWARE"] = "Shell";
  env["REQUEST_URI"] = args[2];
  auto s = split(args[2],"?");
  env["SCRIPT_NAME"] = s[0];
  if (s.length > 1)
    env["QUERY_STRING"] = s[1];
  env["REQUEST_METHOD"] = args[1];

  auto writer = WriteOut(stdout);
  auto errWriter = WriteOut(stderr);
  auto reader = ReadIn(stdin);

  auto content = extractEnv(env, reader);

  requestProcessor.run
  (
    env,
    content,
    writer,
    errWriter
  );
  writeln();
}
