//Written in the D programming language
/*
 * Functions to extract and validate input values from a StrHash source
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/*
  Functions are

  validateString
  validateRequiredInteger
  validateOptionalInteger
  validateRequiredDecimal
  validateOptionalDecimal
  validateBoolean
  validateSingleEnumerated
  validateMultipleEnumerated
  validateOptionalDate
  validateRequiredDate
  validateDate

  All functions return whether the validation succeded.
*/

module jaypha.spinna.validate;

import jaypha.types;
public import jaypha.container.hash;
import jaypha.decimal;

import std.conv;
import std.regex;
public import std.typecons;
import std.ascii;
import std.array;


//----------------------------------------------------------------------------
// Specialised function to validate numeric IDs.
// Returns - whether the validation succeded.

bool validateId
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
    value = string.init;
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

//---------------------------------------------------------
// Shortcut mixins.

enum IdGet(bool requried = false) = "string id; if (!validateId(id, request.gets, \"id\", "~(requried?"true":"false")~")) { response.status(400); return; }";
enum IdPost(bool requried = false) = "string id; if (!validateId(id, request.posts, \"id\", "~(requried?"true":"false")~")) { response.status(400); return; }";

//----------------------------------------------------------------------------

bool validateString
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
    else value = string.init;
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

//-----------------------------------------------

bool validateString
(
  ref strstr value,
  StrHash source,
  string name,
  bool required,
  uint min_length = 0,
  uint max_length = 0,
  string regex = null
)
{
  string v;
  bool x = validateString(v, source, name, required, min_length, max_length, regex);
  if (x) value[name] = v;
  return x;
}

//-----------------------------------------------

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

  assert(!validateString(v, source, "tip", true));
  assert(validateString(v, source, "tip", false));
  assert(v == "");

  assert(!validateString(v, source, "wip", true));
  assert(validateString(v, source, "wip", false));
  assert(v == "");

  assert(validateString(v, source, "zip", true));
  assert(v == source["zip"]);

  assert(validateString(v, source, "zip", false));
  assert(v == source["zip"]);

  assert(validateString(v, source, "quip", false));
  assert(v == source["quip"]);

  assert(validateString(v, source, "towick", false));
  assert(v == source["towick"]);

  assert(validateString(v, source, "crap", false));
  assert(v == source["crap"]);

  assert(validateString(v, source, "towick", false, 4, 15));
  assert(v == source["towick"]);
  assert(validateString(v, source, "towick", false, 6));
  assert(validateString(v, source, "towick", false, 13, 13));
  assert(!validateString(v, source, "towick", false, 10, 11));
  assert(!validateString(v, source, "towick", false, 17, 22));
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validateRequiredInteger
(
  out long value,
  StrHash source,
  string name,
  long min = long.min,
  long max = long.max
)
{
  Nullable!long v;
  if (!validateOptionalInteger(v,source, name, min, max))
    return false;

  if (v.isNull)
    return false;
  value = v.get();
  return true;
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validateOptionalInteger
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

  assert(!validateRequiredInteger(v2, source, "tip"));
  assert(validateOptionalInteger(v1, source, "tip"));
  assert(v1.isNull);

  assert(!validateRequiredInteger(v2, source, "wip"));
  assert(validateOptionalInteger(v1, source, "wip"));
  assert(v1.isNull);

  assert(validateRequiredInteger(v2, source, "zip"));
  assert(v2 == 2);

  assert(validateOptionalInteger(v1, source, "zip"));
  assert(v1.get() == 2);

  assert(!validateOptionalInteger(v1, source, "zip", -3,1));
  assert(!validateOptionalInteger(v1, source, "zip", 3,6));
  assert(validateOptionalInteger(v1, source, "zip", 0));
  assert(v1.get() == 2);
  assert(validateOptionalInteger(v1, source, "zip", 0,2));
  assert(v1.get() == 2);

  assert(!validateOptionalInteger(v1, source, "quip"));
  assert(!validateOptionalInteger(v1, source, "towick"));

  assert(validateOptionalInteger(v1, source, "crap"));
  assert(v1.get() == 0);

  assert(validateOptionalInteger(v1, source, "strip"));
  assert(v1.get() == -34);
  assert(!validateOptionalInteger(v1, source, "strip", 0));

  assert(!validateOptionalInteger(v1, source, "strat"));
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validateRequiredDecimal(uint scale)
(
  out decimal!scale value,
  StrHash source,
  string name,
  decimal!scale min = decimal!scale.min,
  decimal!scale max = decimal!scale.max
)
{
  Nullable!(decimal!scale) v;
  if (!validateOptionalDecimal!scale(v,source, name, min, max))
    return false;

  if (v.isNull)
    return false;
  value = v.get();
  return true;
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validateOptionalDecimal(uint scale)
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

  assert(!validateRequiredDecimal!2(v, source, "yak"));
  assert(validateOptionalDecimal!2(nv, source, "yak"));
  assert(nv.isNull);

  assert(!validateRequiredDecimal!2(v, source, "wip"));
  assert(validateOptionalDecimal!2(nv, source, "wip"));
  assert(nv.isNull);

  assert(validateRequiredDecimal!2(v, source, "zip"));
  assert(v == 64);

  assert(validateOptionalDecimal!2(nv, source, "zip"));
  assert(nv.get() == 64);

  assert(validateOptionalDecimal!2(nv, source, "dip"));
  assert(nv.get() == 2.3);

  assert(validateOptionalDecimal!2(nv, source, "rip"));
  assert(nv.get() == 3.06);

  assert(validateOptionalDecimal!2(nv, source, "yip"));
  assert(nv.get() == -1533.99);

  assert(validateOptionalDecimal!2(nv, source, "bip"));
  assert(nv.get() == 0);

  assert(!validateOptionalDecimal!2(nv, source, "trip"));
  assert(!validateOptionalDecimal!2(nv, source, "quip"));
  assert(!validateOptionalDecimal!2(nv, source, "towick"));
  assert(!validateOptionalDecimal!2(nv, source, "thick"));

  assert(validateOptionalDecimal!2(nv, source, "sip"));
  assert(nv.get() == -34);

  assert(!validateOptionalDecimal!2(nv, source, "strat"));

  dec2 min, max;
  min = 2.5;
  max = 4.1;

  assert(!validateOptionalDecimal!2(nv, source, "dip", min, max));
  assert(!validateOptionalDecimal!2(nv, source, "zip", min, max));
  assert(validateOptionalDecimal!2(nv, source, "rip", min, max)); 
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

bool validateBoolean(out bool value, StrHash source, string name, bool required)
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

bool validateBoolean(ref strstr value, StrHash source, string name, bool required)
{
  bool v;
  bool x = validateBoolean(v, source, name, required);
  if (x) value[name] = v?"1":"0";
  return x;
}

unittest
{
  StrHash source;

  source["wip"] = "";
  source["bip"] = "0";
  source["zip"] = "64";


  bool v;

  assert(validateBoolean(v, source, "yak", false));
  assert(!v);
  assert(!validateBoolean(v, source, "yak", true));

  assert(validateBoolean(v, source, "wip", false));
  assert(!v);
  assert(!validateBoolean(v, source, "wip", true));

  assert(validateBoolean(v, source, "bip", false));
  assert(!v);
  assert(!validateBoolean(v, source, "bip", true));

  assert(validateBoolean(v, source, "zip", false));
  assert(v);
  assert(validateBoolean(v, source, "zip", true));
  assert(v);
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.


bool validateSingleEnumerated
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

//-----------------------------------------------

bool validateSingleEnumerated
(
  ref strstr value,
  StrHash source,
  string name,
  bool required,
  string[] options
)
{
  string v;
  bool x = validateSingleEnumerated(v, source, name, required, options);
  if (x) value[name] = v;
  return x;
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validateMultipleEnumerated
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

  assert(!validateSingleEnumerated(v, source, "tip", true, options));
  assert(validateSingleEnumerated(v, source, "tip", false, options));
  assert(v is null);
  assert(!validateSingleEnumerated(v, source, "zip", false, options));
  assert(validateSingleEnumerated(v, source, "quip", true, options));
  assert(v == "honk");
  assert(validateSingleEnumerated(v, source, "strip", true, options));
  assert(v == "beetle");

  assert(!validateMultipleEnumerated(vv, source, "tip", options, 1));
  assert(validateMultipleEnumerated(vv, source, "tip", options, 0));
  assert(vv == []);
  assert(!validateMultipleEnumerated(vv, source, "zip", options, 1));
  assert(!validateMultipleEnumerated(vv, source, "zip", options, 0));

  assert(validateMultipleEnumerated(vv, source, "quip", options, 1));
  assert(vv == ["honk"]);
  assert(!validateMultipleEnumerated(vv, source, "quip", options, 2));

  assert(!validateMultipleEnumerated(vv, source, "strip", options, 1));
  assert(validateMultipleEnumerated(vv, source, "strat", options, 1));
  assert(vv == source("strat"));
  assert(validateMultipleEnumerated(vv, source, "strat", options, 2));
  assert(vv == source("strat"));
  assert(!validateMultipleEnumerated(vv, source, "strat", options, 3));
  assert(!validateMultipleEnumerated(vv, source, "strat", options, 0,1));
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

import std.datetime;

bool validateOptionalDate
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
    return validateRequiredDate(value.get(),source,name);
  }
}

//----------------------------------------------------------------------------
// Returns - whether the validation succeded.

bool validateRequiredDate
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
// Validates and records into a string[string].

bool validateDate
(
  ref strstr value,
  StrHash source,
  string name,
  bool required
)
{
  if (name !in source || source[name].empty)
  {
    if (required)
      return false;
    value[name] = null;
  }
  else try
  {
    Date.fromISOExtString(source[name]);
    value[name] = source[name];
  }
  catch (DateTimeException e)
  {
    return false;
  }
  return true;
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
  strstr d3;

  assert(!validateRequiredDate(d2,source,"rip"));
  assert(!validateRequiredDate(d2,source,"wip"));
  assert(!validateRequiredDate(d2,source,"zip"));
  assert(!validateRequiredDate(d2,source,"quip"));
  assert(validateRequiredDate(d2,source,"towick"));
  assert(d2.toISOExtString() == "2001-05-22");
  assert(validateRequiredDate(d2,source,"strip"));
  assert(d2.toISOExtString() == "2022-07-13");
  assert(!validateRequiredDate(d2,source,"strat"));

  assert(validateDate(d3,source,"towick", true));
  assert(d3["towick"] == "2001-05-22");
  assert(!validateDate(d3,source,"quip", true));
  assert(!validateDate(d3,source,"rip", true));
  assert(!validateDate(d3,source,"zip", true));
  assert(!validateDate(d3,source,"wip", true));
  assert(validateDate(d3,source,"towick", false));
  assert(d3["towick"] == "2001-05-22");
  assert(!validateDate(d3,source,"quip", false));
  assert(validateDate(d3,source,"rip", false));
  assert(d3["rip"] is null);
  assert(validateDate(d3,source,"wip", false));
  assert(d3["wip"] is null);
  assert(!validateDate(d3,source,"zip", false));

  assert(validateOptionalDate(d1,source,"rip"));
  assert(d1.isNull);
  assert(validateOptionalDate(d1,source,"wip"));
  assert(d1.isNull);
  assert(!validateOptionalDate(d1,source,"zip"));
  assert(!validateOptionalDate(d1,source,"quip"));
  assert(validateOptionalDate(d1,source,"towick"));
  assert(d1.get().toISOExtString() == "2001-05-22");
  assert(validateOptionalDate(d1,source,"strip"));
  assert(d1.get().toISOExtString() == "2022-07-13");
  assert(!validateOptionalDate(d1,source,"strat"));

}

//----------------------------------------------------------------------------
// Validates and records into a string[string].

bool validateTime
(
  ref strstr value,
  StrHash source,
  string name,
  bool required
)
{
  if (name !in source || source[name].empty)
  {
    if (required)
      return false;
    value[name] = null;
  }
  else try
  {
    TimeOfDay.fromISOExtString(source[name]);
    value[name] = source[name];
  }
  catch (DateTimeException e)
  {
    return false;
  }
  return true;
}
