
module jaypha.dbmake.build;

import jaypha.dbmake.dbdef;
import jaypha.fig.value;
import std.exception;


/*************************************************************************
 *
 * Table Definition builders
 *
 *************************************************************************/

void build_table_def(ref TableDef table, Fig_Value source)
in
{
  assert(source.is_list());
}
body
{
  auto list = source.get_list();
  foreach (n,v; list)
  {
    switch (n)
    {
      case "old_name":
        table.old_name = v.get_string();
        break;
      case "engine":
        table.engine = v.get_string();
        break;
      case "charset":
        table.charset = v.get_string();
        break;
      case "no_id":
        table.no_id = true;
        break;
      case "is_a":
        table.is_a = v.get_string();
        auto def = ColumnDef();
        def.name = table.is_a~"_id";
        def.type = ColumnDef.Type.Int;
        def.unsigned =true;
        table.primary = [def.name];
        table.no_id = true;
        table.columns[def.name] = def;
        break;
      case "has_a":
        table.has_a = extract_values(v);
        foreach(name;table.has_a)
        {
          auto def = ColumnDef();
          def.name = name~"_id";
          def.type = ColumnDef.Type.Int;
          def.unsigned =true;
          table.columns[def.name] = def;
        }
        break;
      case "belongs_to":
        table.belongs_to = extract_values(v);
        foreach(name;table.belongs_to)
        {
          auto def = ColumnDef();
          def.name = name~"_id";
          def.type = ColumnDef.Type.Int;
          def.unsigned =true;
          table.columns[def.name] = def;
        }
        break;
      case "has_many":
        table.has_many = extract_values(v);
        break;
      case "primary":
        table.primary = extract_values(v);
        break;
      default:
        break;
    }
  }
  extract_columns(table, list["columns"]);
  if ("indicies" in list)
    extract_indicies(table, list["indicies"]);
}

//--------------------------------------------------------------------------

void extract_columns(ref TableDef table, Fig_Value value)
in
{
  assert(value.is_list());
}
body
{
  foreach (n,v; value.get_list())
  {
    table.columns[n] = ColumnDef();
    table.columns[n].name = n;
    if (v.is_list())
      build_column_def(table.columns[n],v);
    else
      enforce(v.is_bool());
  }
}

//--------------------------------------------------------------------------

void extract_indicies(ref TableDef table, Fig_Value value)
in
{
  assert(value.is_list());
}
body
{
  foreach (n,v; value.get_list())
  {
    table.indicies[n] = IndexDef();
    table.indicies[n].name = n;
    if (v.is_list())
      build_index_def(table.indicies[n],v);
    else
    {
      enforce(v.is_bool());
      table.indicies[n].columns = [ n ];
    }
  }
}


/*************************************************************************
 *
 * Column Definition builders
 *
 *************************************************************************/

void build_column_def(ref ColumnDef column, Fig_Value source)
in
{
  assert(source.is_list());
}
body
{
  Figtree list = source.get_list();
  foreach (n,v; list)
  {
    switch (n)
    {
      case "type":
        extract_type(column, v.get_string());
        break;
      case "old_name":
        column.old_name = v.get_string();
        break;
      case "size":
        column.size = cast(uint) v.get_int();
        break;
      case "scale":
        column.scale = cast(uint) v.get_int();
        break;
      case "values":
        column.values = extract_values(v);
        break;
      case "default":
        column.default_value = v.get_string();
        break;
      case "nullable":
        column.nullable = true;
        break;
      case "unsigned":
        column.unsigned = true;
        break;
      default:
        throw new Exception("column trait "~n~" not supported");
    }
    
  }
}

//--------------------------------------------------------------------------

void extract_type(ref ColumnDef column, string type)
{
  switch (type)
  {
    case "boolean":
    case "bool":
      column.type = ColumnDef.Type.Bool;
      break;
    case "int":
      column.type = ColumnDef.Type.Int;
      break;
    case "uint":
      column.type = ColumnDef.Type.Int;
      column.unsigned =true;
      break;
    case "bigint":
      column.type = ColumnDef.Type.BigInt;
      break;
    case "decimal":
      column.type = ColumnDef.Type.Decimal;
      break;
    case "time":
      column.type = ColumnDef.Type.Time;
      break;
    case "date":
      column.type = ColumnDef.Type.Date;
      break;
    case "datetime":
      column.type = ColumnDef.Type.DateTime;
      break;
    case "timestamp":
      column.type = ColumnDef.Type.Timestamp;
      break;
    case "float":
      column.type = ColumnDef.Type.Float;
      break;
    case "double":
      column.type = ColumnDef.Type.Double;
      break;
    case "enum":
      column.type = ColumnDef.Type.Enum;
      break;
    case "foreign":
      column.type = ColumnDef.Type.Int;
      column.unsigned =true;
      break;
    case "string":
      column.type = ColumnDef.Type.String;
      break;
    case "text":
      column.type = ColumnDef.Type.Text;
      break;
    default:
      column.type = ColumnDef.Type.Custom;
      column.custom_type = type;
  }
}

//--------------------------------------------------------------------------

void extract_enum_values(ref ColumnDef column, Fig_Value values)
in
{
  assert(values.is_array());
}
body
{
  foreach (v; values.get_list())
  {
    if (!v.is_string())
    {
      throw new Exception("Enum values must be strings");
    }
    column.values ~= v.get_string();
  }
}

//--------------------------------------------------------------------------

string[] extract_values(Fig_Value values)
in
{
  assert(values.is_array() || values.is_string());
}
body
{
  string[] list;
  if (values.is_string())
    list ~= values.get_string();
  else foreach (v; values.get_array())
  {
    if (!v.is_string())
    {
      throw new Exception("Values must be strings");
    }
    list ~= v.get_string();
  }
  return list;
}

/*************************************************************************
 *
 * Index Definition builders
 *
 *************************************************************************/

void build_index_def(ref IndexDef index, Fig_Value source)
{
  auto list = source.get_list();
  if ("columns" in list)
    index.columns = extract_values(list["columns"]);
  else
    index.columns = [ index.name ];

  if ("fulltext" in list)
    index.fulltext = true;
  else if ("unique" in list)
    index.unique = true;
}
