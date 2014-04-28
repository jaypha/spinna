/*
 * Parses a Fig configuration file into a fig tree.
 *
 * Part of the Fig configuration language project.
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.fig.figparser;

public import jaypha.fig.value;

import jaypha.fig.c.figparser;

import std.conv;
import std.string;

import std.stdio;
import std.exception;

Figtree read_fig_file(const (char)[] filename)
{
  Fig_Context* context = read_figfile(toStringz(filename));
  assert(context !is null, "No config context returned");
  scope(exit) { free_fig_context(context); }

  if (context.err_message !is null)
  {
    throw new Exception(format("Error reading fig file '%s': line %d, column %d: %s\n",to!string(context.err_filename), context.err_line_no, context.err_column, to!string(context.err_message)));
  }
  return convert_list(context.content);
}

private:

Fig_Value convert(Fig_Record* val, string prefix = null)
{
  Fig_Value v;
  
  v.type_ = cast(Fig_Type) val.type;

  if (val.name !is null)
  {
    v.name = to!string(val.name);
    if (prefix !is null)
      v.full_name = prefix ~"."~v.name;
    else
      v.full_name = v.name;
  }

  switch (v.type_)
  {
    case Fig_Type.Bool:
      v.value_.bval = val.value.lval == 1;
      break;

    case Fig_Type.Int:
      v.value_.lval = val.value.lval;
      break;

    case Fig_Type.Float:
      v.value_.dval = val.value.dval;
      break;

    case Fig_Type.Str:
      v.value_.sval = to!string(val.strval);
      break;

    case Fig_Type.Array:
      v.value_.fig_array = convert_array(val.value.list);
      break;

    case Fig_Type.List:
      v.value_.fig_list = convert_list(val.value.list, v.full_name);
      break;

    default:
      assert(false);
  }

  return v;
}

Figtree convert_list(Fig_Record* val, string prefix = null)
{
  Figtree list;

  Fig_Record* current = val;
  do
  {
    enforce(to!string(current.name) !in list);
    list[to!string(current.name)] = convert(current, prefix);
    current = current.next;
  } while (current !is null);

  return list;
}

Fig_Value[] convert_array(Fig_Record* val)
{
  Fig_Value[] list;

  Fig_Record* current = val;
  do
  {
    list ~= convert(current);
    current = current.next;
  } while (current !is null);

  return list;
}

debug(figparser)
{
  import std.stdio;
  import jaypha.fig.diagnostic;
  
  void main(char[][] args)
  {
    writeln("figparser test program");
    if (args.length < 2)
    {
      writeln("usage: ",args[0]," <configfile>");
      return;
    }

    Figtree figs = read_fig_file(args[1]);
    
    stdout.lockingTextWriter.dump_figs(figs);
    writeln("Test program finished");
  }
}