
module test_main;

import std.stdio;
import jaypha.io.output_stream;

import jaypha.types;

import jaypha.spinna.pagebuilder.widgets.boolean;

import jaypha.container.hash;

import std.typecons;

import jaypha.decimal;


void main(string[] args)
{
  StrHash request;

  request["wip"] = "";
  request["bip"] = "0";
  request["zip"] = "64";


  bool v;

  assert(extract_boolean_value(v, request, "yak", false));
  assert(!v);
  assert(!extract_boolean_value(v, request, "yak", true));

  assert(extract_boolean_value(v, request, "wip", false));
  assert(!v);
  assert(!extract_boolean_value(v, request, "wip", true));

  assert(extract_boolean_value(v, request, "bip", false));
  assert(!v);
  assert(!extract_boolean_value(v, request, "bip", true));

  assert(extract_boolean_value(v, request, "zip", false));
  assert(v);
  assert(extract_boolean_value(v, request, "zip", true));
  assert(v);
}
