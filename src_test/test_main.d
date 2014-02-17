
module test_main;

import std.stdio;
import jaypha.io.output_stream;

import jaypha.types;

import jaypha.spinna.pagebuilder.widgets.validate;

import jaypha.container.hash;

import std.typecons;

import jaypha.decimal;
import Backtrace = backtrace.backtrace;

void main(string[] args)
{
  debug { Backtrace.install(stderr); }

  StrHash request;

  request["wip"] = "";
  request["bip"] = "0";
  request["zip"] = "64";


  bool v;

  assert(validate_boolean(v, request, "yak", false));
  assert(!v);
  assert(!validate_boolean(v, request, "yak", true));

  assert(validate_boolean(v, request, "wip", false));
  assert(!v);
  assert(!validate_boolean(v, request, "wip", true));

  assert(validate_boolean(v, request, "bip", false));
  assert(!v);
  assert(!validate_boolean(v, request, "bip", true));

  assert(validate_boolean(v, request, "zip", false));
  assert(v);
  assert(validate_boolean(v, request, "zip", true));
  assert(v);
  writeln(request["tip"]);

}
