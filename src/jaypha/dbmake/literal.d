module jaypha.dbmake.literal;

import jaypha.dbmake.dbdef;

import jaypha.io.print;
import jaypha.algorithm;
import std.algorithm;

import std.array;

string literal(ref DatabaseDef database_def)
{
  auto w = appender!string;
  w.print("DatabaseDef([");
  w.print(database_def.tables.meld!((a,b) => ("\""~a~"\":"~b.literal()))().join(","));
  w.print("],");
  if (database_def.views.length)
    w.print("[",database_def.views.meld!((a,b) => ("\""~a~"\":"~b.literal()))().join(","),"]");
  else
    w.print("null");
  w.print(",");
  if (database_def.functions.length)
    w.print("[",database_def.functions.meld!((a,b) => ("\""~a~"\":"~b.literal()))().join(","),"]");
  else
    w.print("null");
  w.print(")");
  return w.data;
}


string literal(ref TableDef table_def)
{
  auto w = appender!string;
  w.print("TableDef( ");
  w.print(quote_str(table_def.name));
  w.print(",");
  w.print(quote_str(table_def.old_name));
  w.print(",");
  w.print(quote_str(table_def.engine));
  w.print(",");
  w.print(quote_str(table_def.charset));
  w.print(",");
  w.print(table_def.no_id);
  w.print(",");
  w.print(quote_str(table_def.is_a));
  w.print(",[");
  w.print(table_def.has_a.map!quote_str().join(","));
  w.print("],[");
  w.print(table_def.belongs_to.map!quote_str().join(","));
  w.print("],[");
  w.print(table_def.has_many.map!quote_str().join(","));
  w.print("],[");
  w.print(table_def.primary.map!quote_str().join(","));
  w.print("],[");
  w.print(table_def.columns.meld!((a,b) => ("\""~a~"\":"~b.literal()))().join(","));
  w.print("],");
  if (table_def.indicies.length)
    w.print("[",table_def.indicies.meld!((a,b) => ("\""~a~"\":"~b.literal()))().join(","),"]");
  else
    w.print("null");
  w.print(")");
  return w.data;
}


string literal(ref ColumnDef column_def)
{
  auto w = appender!string;
  w.print("ColumnDef(");
  w.print(quote_str(column_def.name));
  w.print(",");
  w.print(quote_str(column_def.old_name));
  w.print(",");
  w.print("ColumnDef.Type.",column_def.type);
  w.print(",");
  w.print(quote_str(column_def.custom_type));
  w.print(",");
  w.print(column_def.size);
  w.print(",");
  w.print(column_def.scale);
  w.print(",[");
  w.print(column_def.values.map!quote_str().join(","));
  w.print("],");
  w.print(quote_str(column_def.default_value));
  w.print(",");
  w.print(column_def.nullable);
  w.print(",");
  w.print(column_def.unsigned);
  w.print(",");
  w.print(column_def.auto_increment);
  w.print(")");
  return w.data;
}

string literal(ref IndexDef index_def)
{
  auto w = appender!string;
  w.print("IndexDef(");
  w.print(quote_str(index_def.name)),
  w.print(",");
  w.print(index_def.unique);
  w.print(",");
  w.print(index_def.fulltext);
  w.print(",[");
  w.print(index_def.columns.map!quote_str().join(","));
  w.print("])");
  return w.data;
}

string literal(ref ViewDef view_def)
{
  return "";
}

string literal(ref FunctionDef function_def)
{
  return "";
}

string quote_str(string s)
{
  if (s is null)
    return "null";
  else
    return "\""~s~"\"";
}
