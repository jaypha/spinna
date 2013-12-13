
module jaypha.dbmake.dbdef;

//--------------------------------
struct DatabaseDef
//--------------------------------
{
  TableDef[string] tables;
  ViewDef[string] views;
  FunctionDef[string] functions;
}

//--------------------------------
struct TableDef
//--------------------------------
{
  string name;
  string old_name;

  string engine;
  string charset;

  bool no_id;

  string is_a;
  string[] has_a;
  string[] belongs_to;
  string[] has_many;

  string[] primary;

  ColumnDef[string] columns;
  IndexDef[string] indicies;
}

//--------------------------------
struct ColumnDef
//--------------------------------
{
  enum Type { Bool, Int, BigInt, Decimal, String, Text, Time, Date, DateTime, Timestamp, Float, Double, Enum, Custom };

  string name;
  string old_name;

  Type type = Type.String;
  string custom_type;

  uint size;  // for char array and decimal
  uint scale; // decimal places
  string[] values; // for enums

  string default_value = null;

  bool nullable;
  bool unsigned;
  bool auto_increment;
}

//--------------------------------
struct IndexDef
//--------------------------------
{
  string name;
  bool unique;
  bool fulltext;
  string[] columns;
}

//--------------------------------
struct FunctionDef
//--------------------------------
{
  string name;
  string def;
}

//--------------------------------
struct ViewDef
//--------------------------------
{
  string name;
  string[][string] columns;  // table, columns
  string[string][string] aliases;  // table, column, alias
  string[string] joins;
}

