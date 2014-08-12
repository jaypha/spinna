/*
 * Functions to extract and validate input values from a StrHash source
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

/*
  Functions are

  validate_string
  validate_required_integer
  validate_optional_integer
  validate_required_decimal
  validate_optional_decimal
  validate_boolean
*/

module jaypha.spinna.validate;

public import jaypha.container.hash;
import jaypha.decimal;

import std.conv;
import std.regex;
public import std.typecons;
import std.ascii;


//----------------------------------------------------------------------------
// Specialised function to validate numeric IDs.
// Returns - whether the validation succeded.

bool validate_id
(
  out string value,
  StrHash source,
  string name,
  bool required = true
)
{
  if (name !in source || source[name].length == 0)
  {
    if (required) return false;
    value = null;
  }
  else
  {
    foreach (c; source[name])
      if (!isDigit(c))
        return false;
    value = source[name];
  }
  return true;
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validate_string
(
  out string value,
  StrHash source,
  string name,
  bool required,
  uint min_length = 0,
  uint max_length = 0,
  string regex = null
)
{
  if (name !in source || source[name].length == 0)
  {
    if (required) return false;
    else value = "";
  }
  else
  {
    value = source[name];
    if (value.length < min_length || (max_length != 0 && value.length > max_length))
      return false;
    // TODO regex.
  }
  return true;
}

unittest
{
  StrHash source;

  source["wip"] = "";
  source["zip"] = "2";
  source["quip"] = "honk";
  source["towick"] = "46gzigmontiqu";
  source["crap"] = "0";

  source["strip"] = [ "-34", "zank" ];
  source["strat"] = [ "tonk", "15" ];


  string v;

  assert(!validate_string(v, source, "tip", true));
  assert(validate_string(v, source, "tip", false));
  assert(v == "");

  assert(!validate_string(v, source, "wip", true));
  assert(validate_string(v, source, "wip", false));
  assert(v == "");

  assert(validate_string(v, source, "zip", true));
  assert(v == source["zip"]);

  assert(validate_string(v, source, "zip", false));
  assert(v == source["zip"]);

  assert(validate_string(v, source, "quip", false));
  assert(v == source["quip"]);

  assert(validate_string(v, source, "towick", false));
  assert(v == source["towick"]);

  assert(validate_string(v, source, "crap", false));
  assert(v == source["crap"]);

  assert(validate_string(v, source, "towick", false, 4, 15));
  assert(v == source["towick"]);
  assert(validate_string(v, source, "towick", false, 6));
  assert(validate_string(v, source, "towick", false, 13, 13));
  assert(!validate_string(v, source, "towick", false, 10, 11));
  assert(!validate_string(v, source, "towick", false, 17, 22));
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validate_required_integer
(
  out long value,
  StrHash source,
  string name,
  long min = long.min,
  long max = long.max
)
{
  Nullable!long v;
  if (!validate_optional_integer(v,source, name, min, max))
    return false;

  if (v.isNull)
    return false;
  value = v.get();
  return true;
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validate_optional_integer
(
  out Nullable!long value,
  StrHash source,
  string name,
  long min = long.min,
  long max = long.max
)
{
  if (name !in source || source[name].length == 0)
  {
    value.nullify();
    return true;
  }
  else
  {
    ulong i = 0;
    if (source[name][0] == '+' || source[name][0] == '-')
    {
      if (source[name].length == 1) return false;
      i = 1;
    }
    //auto Nd = unicode.Decimal_Number;
    foreach (c; source[name][i..$])
      if (!isDigit(c))
        return false;
    value = to!long(source[name]); // TODO may be faster to manually convert since we visit each character anyway
    return (value >= min && value <= max);
  }
}

//----------------------------------------------------------------------------

unittest
{
  StrHash source;

  source["wip"] = "";
  source["zip"] = "2";
  source["quip"] = "honk";
  source["towick"] = "46g";
  source["crap"] = "0";

  source["strip"] = [ "-34", "zank" ];
  source["strat"] = [ "tonk", "15" ];


  Nullable!long v1;
  long v2;

  assert(!validate_required_integer(v2, source, "tip"));
  assert(validate_optional_integer(v1, source, "tip"));
  assert(v1.isNull);

  assert(!validate_required_integer(v2, source, "wip"));
  assert(validate_optional_integer(v1, source, "wip"));
  assert(v1.isNull);

  assert(validate_required_integer(v2, source, "zip"));
  assert(v2 == 2);

  assert(validate_optional_integer(v1, source, "zip"));
  assert(v1.get() == 2);

  assert(!validate_optional_integer(v1, source, "zip", -3,1));
  assert(!validate_optional_integer(v1, source, "zip", 3,6));
  assert(validate_optional_integer(v1, source, "zip", 0));
  assert(v1.get() == 2);
  assert(validate_optional_integer(v1, source, "zip", 0,2));
  assert(v1.get() == 2);

  assert(!validate_optional_integer(v1, source, "quip"));
  assert(!validate_optional_integer(v1, source, "towick"));

  assert(validate_optional_integer(v1, source, "crap"));
  assert(v1.get() == 0);

  assert(validate_optional_integer(v1, source, "strip"));
  assert(v1.get() == -34);
  assert(!validate_optional_integer(v1, source, "strip", 0));

  assert(!validate_optional_integer(v1, source, "strat"));
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validate_required_decimal(uint scale)
(
  out decimal!scale value,
  StrHash source,
  string name,
  decimal!scale min = decimal!scale.min,
  decimal!scale max = decimal!scale.max
)
{
  Nullable!(decimal!scale) v;
  if (!validate_optional_decimal!scale(v,source, name, min, max))
    return false;

  if (v.isNull)
    return false;
  value = v.get();
  return true;
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validate_optional_decimal(uint scale)
(
  out Nullable!(decimal!scale) value,
  StrHash source,
  string name,
  decimal!scale min = decimal!scale.min,
  decimal!scale max = decimal!scale.max
)
{
  if (name !in source || source[name].length == 0)
  {
    value.nullify();
    return true;
  }
  else
  {
    decimal!scale x;
    auto r = regex(r"^[+-]?\d+(.\d{1,"~to!string(scale)~"})?$");
    auto m = match(source[name],r);
    if (!m)
      return false;
    x = source[name];
    value = x;
    return (value.get() >= min && value.get() <= max);
  }
}

//----------------------------------------------------------------------------

unittest
{
  StrHash source;

  source["wip"] = "";
  source["zip"] = "64";
  source["dip"] = "2.3";
  source["rip"] = "3.06";
  source["yip"] = "-1533.99";
  source["bip"] = "0";

  source["trip"] = "87.341";
  source["quip"] = "honk";
  source["towick"] = "46gzigmontiqu";
  source["thick"] = "gzigm7.8ontiqu";

  source["sip"] = [ "-34", "zank" ];
  source["strat"] = [ "tonk", "15" ];


  Nullable!dec2 nv;
  dec2 v;

  assert(!validate_required_decimal!2(v, source, "yak"));
  assert(validate_optional_decimal!2(nv, source, "yak"));
  assert(nv.isNull);

  assert(!validate_required_decimal!2(v, source, "wip"));
  assert(validate_optional_decimal!2(nv, source, "wip"));
  assert(nv.isNull);

  assert(validate_required_decimal!2(v, source, "zip"));
  assert(v == 64);

  assert(validate_optional_decimal!2(nv, source, "zip"));
  assert(nv.get() == 64);

  assert(validate_optional_decimal!2(nv, source, "dip"));
  assert(nv.get() == 2.3);

  assert(validate_optional_decimal!2(nv, source, "rip"));
  assert(nv.get() == 3.06);

  assert(validate_optional_decimal!2(nv, source, "yip"));
  assert(nv.get() == -1533.99);

  assert(validate_optional_decimal!2(nv, source, "bip"));
  assert(nv.get() == 0);

  assert(!validate_optional_decimal!2(nv, source, "trip"));
  assert(!validate_optional_decimal!2(nv, source, "quip"));
  assert(!validate_optional_decimal!2(nv, source, "towick"));
  assert(!validate_optional_decimal!2(nv, source, "thick"));

  assert(validate_optional_decimal!2(nv, source, "sip"));
  assert(nv.get() == -34);

  assert(!validate_optional_decimal!2(nv, source, "strat"));

  dec2 min, max;
  min = 2.5;
  max = 4.1;

  assert(!validate_optional_decimal!2(nv, source, "dip", min, max));
  assert(!validate_optional_decimal!2(nv, source, "zip", min, max));
  assert(validate_optional_decimal!2(nv, source, "rip", min, max)); 
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

/*
 * For booleans, 'required' means that the value must be true, as opposed to
 * other widget types, where 'required' means 'not empty'.
 *
 * Absent, empty, '0' and case insensitive 'false' all equate to false.
 * Everything else equates to true.
 */

bool validate_boolean(out bool value, StrHash source, string name, bool required)
{
  import std.uni;

  value = 
  (
    name in source && 
    source[name] != "0" &&
    source[name] != "" &&
    toLower(source[name]) != "false"
  );
  return value || !required;
}

unittest
{
  StrHash source;

  source["wip"] = "";
  source["bip"] = "0";
  source["zip"] = "64";


  bool v;

  assert(validate_boolean(v, source, "yak", false));
  assert(!v);
  assert(!validate_boolean(v, source, "yak", true));

  assert(validate_boolean(v, source, "wip", false));
  assert(!v);
  assert(!validate_boolean(v, source, "wip", true));

  assert(validate_boolean(v, source, "bip", false));
  assert(!v);
  assert(!validate_boolean(v, source, "bip", true));

  assert(validate_boolean(v, source, "zip", false));
  assert(v);
  assert(validate_boolean(v, source, "zip", true));
  assert(v);
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.


bool validate_single_enumerated
(
  out string value,
  StrHash source,
  string name,
  bool required,
  string[] options
)
{
  import std.algorithm;

  if (name !in source)
  {
    if (required) return false;
    else value = null;
  }
  else
  {
    value = source[name];
    return ((options is null) || canFind(options, value));
  }
  return true;
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validate_multiple_enumerated
(
  out string[] value,
  StrHash source,
  string name,
  string[] options,
  uint min_count,
  uint max_count=0
)
{
  import std.algorithm;

  if (name !in source)
  {
    if (min_count != 0) return false;
    else value = [];
  }
  else
  {
    value = source(name);
    if (value.length < min_count || (max_count != 0 && value.length > max_count))
      return false;
    if (options !is null)
      foreach (v;value)
        if (!canFind(options, v))
          return false;
  }
  return true;
}

//----------------------------------------------------------------------------

unittest
{
  StrHash source;

  source["zip"] = "2";
  source["quip"] = "honk";

  source["strip"] = [ "beetle", "zank" ];
  source["strat"] = [ "tonk", "tank" ];

  string[] options = [ "hello", "honk",  "beetle", "tonk", "tweetle", "tank" ];

  string v;
  string[] vv;

  assert(!validate_single_enumerated(v, source, "tip", true, options));
  assert(validate_single_enumerated(v, source, "tip", false, options));
  assert(v is null);
  assert(!validate_single_enumerated(v, source, "zip", false, options));
  assert(validate_single_enumerated(v, source, "quip", true, options));
  assert(v == "honk");
  assert(validate_single_enumerated(v, source, "strip", true, options));
  assert(v == "beetle");

  assert(!validate_multiple_enumerated(vv, source, "tip", options, 1));
  assert(validate_multiple_enumerated(vv, source, "tip", options, 0));
  assert(vv == []);
  assert(!validate_multiple_enumerated(vv, source, "zip", options, 1));
  assert(!validate_multiple_enumerated(vv, source, "zip", options, 0));

  assert(validate_multiple_enumerated(vv, source, "quip", options, 1));
  assert(vv == ["honk"]);
  assert(!validate_multiple_enumerated(vv, source, "quip", options, 2));

  assert(!validate_multiple_enumerated(vv, source, "strip", options, 1));
  assert(validate_multiple_enumerated(vv, source, "strat", options, 1));
  assert(vv == source("strat"));
  assert(validate_multiple_enumerated(vv, source, "strat", options, 2));
  assert(vv == source("strat"));
  assert(!validate_multiple_enumerated(vv, source, "strat", options, 3));
  assert(!validate_multiple_enumerated(vv, source, "strat", options, 0,1));
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

import std.datetime;

bool validate_optional_date
(
  out Nullable!Date value,
  StrHash source,
  string name,
)
{
  if (name !in source || source[name].length == 0)
  {
    value.nullify();
    return true;
  }
  else
  {
    value=Date(0);
    return validate_required_date(value.get(),source,name);
  }
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validate_required_date
(
  out Date value,
  StrHash source,
  string name,
)
{
  if (name !in source || source[name].length == 0)
    return false;

  try
  {
    value = Date.fromISOExtString(source[name]);
    return true;
  }
  catch (DateTimeException e)
  {
    return false;
  }
}

//----------------------------------------------------------------------------

unittest
{
  StrHash source;

  source["wip"] = "";
  source["zip"] = "2";
  source["quip"] = "2001-99-99";
  source["towick"] = "2001-05-22";
  source["crap"] = "0";

  source["strip"] = [ "2022-07-13", "zank" ];
  source["strat"] = [ "tonk", "2001-05-22" ];


  Nullable!Date d1;
  Date d2;

  assert(!validate_required_date(d2,source,"rip"));
  assert(!validate_required_date(d2,source,"wip"));
  assert(!validate_required_date(d2,source,"zip"));
  assert(!validate_required_date(d2,source,"quip"));
  assert(validate_required_date(d2,source,"towick"));
  assert(d2.toISOExtString() == "2001-05-22");
  assert(validate_required_date(d2,source,"strip"));
  assert(d2.toISOExtString() == "2022-07-13");
  assert(!validate_required_date(d2,source,"strat"));

  assert(validate_optional_date(d1,source,"rip"));
  assert(d1.isNull);
  assert(validate_optional_date(d1,source,"wip"));
  assert(d1.isNull);
  assert(!validate_optional_date(d1,source,"zip"));
  assert(!validate_optional_date(d1,source,"quip"));
  assert(validate_optional_date(d1,source,"towick"));
  assert(d1.get().toISOExtString() == "2001-05-22");
  assert(validate_optional_date(d1,source,"strip"));
  assert(d1.get().toISOExtString() == "2022-07-13");
  assert(!validate_optional_date(d1,source,"strat"));

}