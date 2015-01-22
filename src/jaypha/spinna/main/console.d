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

//---------------------------------------------------------------------------
// consoleSpinnaRequestProcessor
//---------------------------------------------------------------------------
// This module defines a RequestProcessor instance that uses the Spinna
// Router and interfaces with the console.
//---------------------------------------------------------------------------

module jaypha.spinna.main.console;

import jaypha.types;
public import jaypha.io.dirtyio;
import jaypha.spinna.process;
import jaypha.spinna.router_controller;

import std.stdio;
import std.range;
import std.array;
import std.string;

debug
{
  import Backtrace = backtrace.backtrace;
}

alias RequestProcessor!(ReadIn,WriteOut,RouterController)
  consoleSpinnaRequestProcessor;

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

  consoleSpinnaRequestProcessor.run
  (
    env,
    content,
    writer,
    errWriter
  );
  writeln();
}
