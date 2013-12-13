

module jaypha.spinna.pagebuilder.lists.defined_table;

public import jaypha.spinna.pagebuilder.lists.column;

public import std.functional;

template DefinedTable(string v, string source)
{
  enum DefinedTable = v~".columns = "~import_defined_table("Column",import(source))~";";
}

string import_defined_table(string x, string y)
{
  char[] z = "[".dup;
  ulong j=0;
  while (j < y.length)
  {
    auto i = j;
    while (j != y.length && y[j] != ';') ++j;
    z ~= x.dup~y[i..j].dup~",".dup;
    ++j;
  }
  z[$-1] = ']';
  return z.idup;
}

unittest
{
  import std.stdio;
  writeln(DefinedTable!("list","test.imp.txt"));
  //auto s = "[Column!(uint)(a,b,c),Column!(uint)(d,e,f),Column!(uint)(g,h,i)]";
}
