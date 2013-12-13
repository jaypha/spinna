

module jaypha.dbmake.codegen;

import jaypha.dbmake.dbdef;

import jaypha.common.io.print;
import jaypha.common.string;

import std.string;

string db_type = "MySqlDatabase";

string generate_table_module(ref TableDef table_def, string owner, string package)
{
  auto s = appender!(string)();

  auto struct_name = to_camel_case(table_def.name);

  s.println("/*");
  s.println(" * Database structure for ", table_def.name);
  s.println(" * Copyright (C) ",owner);
  s.println(" */");
  s.println;
  s.println("/********************************************************************");
  s.println(" *                                                                  *");
  s.println(" * THIS FILE IS GENERATED CODE. DO NOT EDIT                         *");
  s.println(" *                                                                  *");
  s.println(" ********************************************************************/");
  s.println;
  s.println("module ",package_name,".",table_def.name,";");
  s.println;
  s.println("import jaypha.dbms.recordbase;");

  s.println("import jaypha.dbms.exception;");

  auto set = add_imports(table_def.columns);
  foreach (im; set)
    s.println(im);

  s.println("alias ",db_type," DB;");

  s.println("//-------------------------------------------------------------------");

  //-----------------------------
  // Structure

  s.println("struct ",struct_name);
  s.println("{");

  s.println("  mixin RecordBase!(",struct_name,", DB, \"",table_def.name,"\");");
  s.println;
  s.println("  this(DB db) { db_=db; isNew_=true; }");
  s.println("  this(DB db, uint i)");
  s.println("  {");
  s.println("    db_ = db;");
  s.println("    if (!load(i))");
  s.println("      throw new Exception(\"cannot find ",struct_name," record \",to!string(i));");
  s.println("  }");
  s.println;
  s.println("  private this(DB db, strstr r) { db_=db; set(r); }");
  s.println;
  s.println("  //-----------------------------------------------------------------");
  s.println;

  //-----------------------------
  // Accessors

  s.println("  /*");
  s.println("   * Accessor functions");
  s.println("   */");
  s.println;

    if (!table_def.no_id)
    s.println("  uint id() { return id_; }");
  s.println;

  foreach (column; tableDef.columns)
  {
    s.println(getter(column));
    s.println(setter(column));
    s.println;
  }

  s.println("  //-----------------------------------------------------------------");
  s.println;

  //-----------------------------
  // Load and Save

  s.println("  /*");
  s.println("   * I/O functions");
  s.println("   */");

    // Load

    /+
  s.println("  bool load(uint id)");
  s.println("  {");
  s.println("    strmap r = db_.queryRow(Format(\"select * from ")(tableDef.name)(" where id={}\",id));");
  s.println("    if (r is null)");
  s.println("      return false;");
  s.println("    set(r);");
  s.println("    return true;");
  s.println("  }");
    +/

    // Set

  s.println("  private void set(strstr r)");
  s.println("  {");
    
  foreach (column; tableDef.columns)
    s.println("    ",convert_to(column));

  if (!table_def.no_id)
    s.println("    id_ = to!int(r[`id`]);");
  s.println("    isNew_ = false;");
  s.println("  }");

  s.println("  ulong save()");
  s.println("  {");
  s.println("    strstr values;");

  foreach (column ;tableDef.columns)
  {
    print_save(column);
  }
  s.println;

  s.println("    if (isNew_)");
  s.println("    {");
  s.println("      id_ = db_.quick_insert(\"",tableDef.name,"\", values);");
  s.println("      isNew_ = false;");
  s.println;
  s.println("    }");
  s.println("    else");
  s.println("    {");
  s.println("      db_.quick_update(\"",tableDef.name,"\", values,\"id=\"~to!string(id_)));";
  s.println("    }");
  s.println;
  s.println("    return id_;");
  s.println("  }");
  s.println;


  s.println("  //-----------------------------------------------------------------");
  s.println;
  s.println("  private:");
  s.println;
  s.println("    mixin RecordVars!DB;");
  s.println;
  foreach (column; table_def.columns)
    s.println(member_decl(column));
  s.println;

  s.println("}");

  return s.data;
}



string member_decl(ref ColumnDef def)
{
  return format("    %s %s_;",d_type(def), def.name);
}

string d_type(ref ColumnDef def)
{
  switch (def.type)
  {
    case ColumnDef.Type.Bool:
      return "bool";
    case ColumnDef.Type.Int:
      return def.unsigned?"uint":"int";
    case ColumnDef.Type.BigInt:
      return "BigInt";
    case ColumnDef.Type.Decimal:
      return "decimal!"~to!string(def.scale);
    case ColumnDef.Type.String:
    case ColumnDef.Type.Text:
    case ColumnDef.Type.Custom:
      return "string";
    case ColumnDef.Type.Time:
      return "TimeOfDay";
    case ColumnDef.Type.DateTime:
      return "DateTime";
    case ColumnDef.Type.Date:
      return "Date";
    case ColumnDef.Type.Timestamp:
      return "SysTime";
    case ColumnDef.Type.Float:
    case ColumnDef.Type.Double:
      return "double";
    case ColumnDef.Type.Enum:
      return to_camel_case(def.name);
  }
}

Set!string add_imports(ColumnDef[] columns)
{
  Set!string s;
  foreach (def; columns)
    switch (def.type)
    {
      case ColumnDef.Type.BigInt:
        s.put("import std.bigint;");
        break;
      case ColumnDef.Type.Decimal:
        s.put("import jaypha.decimal;");
        break;
      case ColumnDef.Type.Time:
      case ColumnDef.Type.DateTime:
      case ColumnDef.Type.Date:
      case ColumnDef.Type.Timestamp:
        s.put("import std.datetime;");
        break;
      defaut:
        break;
    }
  return s;
}

string getter(ref ColumnDef def)
{
  return format("  %s %s() { return %s_; }", d_type(def), def.name, def.name);
}

string setter(ref ColumnDef def)
{
  return format("  void %s(%s v) { %s_ = v; }", def.name, d_type(def), def.name);
}




string convert_to(ref ColumnDef def)
{
  switch (def.type)
  {
    case ColumnDef.Type.Timestamp:
      return "SysTime";
    case ColumnDef.Type.Enum:
      return to_camel_case(def.name);

    case ColumnDef.Type.Bool:
      return format("%s = (r[\"%s\"]=="0");",def.name,def.name);
    case ColumnDef.Type.Int:
      if (def.unsigned)
        return format("%s = to!uint(r[\"%s\"]);",def.name,def.name);
      else
        return format("%s = to!int(r[\"%s\"]);",def.name,def.name);
    case ColumnDef.Type.Date:
      return format("%s = Date.fromISOExtString(r[\"%s\"]);",def.name,def.name);
    case ColumnDef.Type.Time:
      return format("%s = TimeOfDay.fromISOExtString(r[\"%s\"]);",def.name,def.name);
    case ColumnDef.Type.DateTime:
      return format("%s = DateTime.fromISOExtString(r[\"%s\"]);",def.name,def.name);
    case ColumnDef.Type.Float:
    case ColumnDef.Type.Double:
      return format("%s = to!double(r[\"%s\"]);",def.name,def.name);
    default:
      return format("%s = r[\"%s\"];",def.name,def.name);
  }
}


string print_save(ref ColumnDef def)
{
  switch (def.type)
  {
    case ColumnDef.Type.Date:
    case ColumnDef.Type.Time:
      return "values["~def.name~"] = "~def.name~"_.toISOExtString();";
    case ColumnDef.Type.Bool:
      return "values["~def.name~"] = ("~def.name~"_?\"1\":\"0\");";
    case ColumnDef.Type.String:
      return "values["~def.name~"] = "~def.name~"_;";
    default:
      return "values["~def.name~"] = to!string("~def.name~"_);";
  }
}
