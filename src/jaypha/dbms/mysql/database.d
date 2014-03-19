/*
 * MySQL database connection tool
 *
 * Copyright 2009-2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.dbms.mysql.database;

import jaypha.dbms.mysql.c.mysql;
import jaypha.dbms.exception;
import jaypha.algorithm;

import std.conv;
import std.string;
import std.array;
import std.algorithm;


//-----------------------------------------------------------------------------
//
// Database
//
//-----------------------------------------------------------------------------

final class MySqlDatabase
{
  alias MySQLRange ResultType;

  string host;
  string dbname;
  string username;
  string password = null;
  uint port = 0;

  //---------------------------------------------------------------------------

  ~this() { close(); }

  //---------------------------------------------------------------------------

  void connect()
  {
    if (mysql is null)
    {
      mysql = mysql_init(mysql);
      if
      (
        mysql_real_connect
        (
          mysql,
          toStringz(host),
          toStringz(username),
          toStringz(password),
          toStringz(dbname),
          port,
          null,
          0
        ) is null
      )
      {
        throw new DBException(to!string(mysql_error(mysql)), mysql_errno(mysql), null);
      }
    }
  }

  //---------------------------------------------------------------------------

  void close()
  {
    if (mysql !is null)
    {
      mysql_close(mysql);
      mysql = null;
    }
  }

  //---------------------------------------------------------------------------

  string quote(string s)
  {
		if (s == "") { return "''"; }
    if (s is null) { return "null"; }

		char[] result;
		result.length = s.length * 2+1;

    if (mysql is null) connect();
		// string doesn't need to be 0-term
    result.length = mysql_real_escape_string
    (
      mysql,
      result.ptr,
      s.ptr,
      s.length
    );

    if (mysql_errno(mysql) != 0)
      throw new DBException(to!string(mysql_error(mysql)), mysql_errno(mysql), s);

		return "'"~result.idup~"'";
  }

  //---------------------------------------------------------------------------

  string in_list(T)(T[] list)
  {
    if (list.length == 0) return ("0");
    static if (is(T == string))
      return "("~map!(quote)(list).join(",")~")";
    else
      return "("~map!(to!string)(list).join(",")~")";
  }

  //---------------------------------------------------------------------------
  // General query function. Can be used with both retrieval and modification.
  //---------------------------------------------------------------------------

  ResultType query(string sql)
  {

    MYSQL_RES* res = query_raw(sql);

    return ResultType(res);
  }

  //---------------------------------------------------------------------------
  // Retireval functions
  //---------------------------------------------------------------------------

  string query_value(string sql)
  {
    MYSQL_RES* res = query_raw(sql);
    scope(exit) { mysql_free_result(res); }
    string result;
    
    if (!get_single(res, result))
      return null;
    
    while (mysql_fetch_row(res) !is null) {}
    return result;
  }

  //---------------------------------------------------------------------------

  string[string] query_row(string sql)
  {
    MYSQL_RES* res = query_raw(sql);
    scope(exit) { mysql_free_result(res); }
    string[string] result = get_row(res);
    
    while (mysql_fetch_row(res) !is null) {}
    return result;
  }

  //---------------------------------------------------------------------------

  string[string][] query_data(string sql)
  {
    MYSQL_RES* res = query_raw(sql);
    scope(exit) { mysql_free_result(res); }

    auto data = appender!(string[string][])();
    //string[string][] data;
    string[string] row;
    
    while ((row = get_row(res)) !is null)
      data.put(row);
    return data.data;
  }

  //---------------------------------------------------------------------------


  //---------------------------------------------------------------------------

  T[] query_column(T = string)(string sql)
  {
    MYSQL_RES* res = query_raw(sql);
    scope(exit) { mysql_free_result(res); }

    auto data = appender!(T[])();
    //string[] data;
    string v;
    
    while (get_single(res,v))
      data.put(to!T(v));
    return data.data;
  }

  //---------------------------------------------------------------------------

  //
  // constraints
  // first column is used as the index.
  // first column must be unique, and of the correct type.
  //

  string[string][T] query_indexed_data(T = ulong)(string sql)
  {
    MYSQL_RES* res = query_raw(sql);
    scope(exit) { mysql_free_result(res); }
    
    bool ok = false;
    int numFields = mysql_num_fields(res);
    MYSQL_FIELD* fields = mysql_fetch_fields(res);
    auto id_column = to!string(fields[0].name);

    // TODO test type of id_column
    
    string[string][T] data;

    string[string] row;
    
    while ((row = get_row(res)) !is null)
      data[to!(T)(row[id_column])] = row;
    return data;
  }

  //---------------------------------------------------------------------------

  //
  // constraints
  // first column is used as the index.
  // first column must be unique, and of the correct type.
  //

  U[T] query_indexed_column(T = ulong,U = string)(string sql)
  {
    MYSQL_RES* res = query_raw(sql);
    scope(exit) { mysql_free_result(res); }

    U[T] data;

    if (mysql_num_fields(res) != 2)
      throw new DBException
      (
        "query_indexed_column must be called with a query that returns "
        "two columns",0, sql
      );

    // TODO test type of id_column

    MYSQL_ROW row;

    while ((row = mysql_fetch_row(res)) !is null)
    {
      uint* lengths = mysql_fetch_lengths(res);

      data[to!(T)(row[0][0..lengths[0]])] = to!U(row[1][0..lengths[1]]);
    }

    return data;
  }

  //---------------------------------------------------------------------------

  
  //---------------------------------------------------------------------------
  // Database write methods
  //---------------------------------------------------------------------------

  //
  // constraints
  // values are expected to be already vetted. Functions will enquote.
  //
  
  ulong quick_insert(string tablename, string[string] values)
  {
    return quick_insert(tablename, values.keys, values.values);
  }

  ulong quick_insert(string tablename, string[] columns, string[] values)
  {
    query
    (
      "insert into `"~tablename~"` (" ~
      columns.join(",") ~
      ") values (" ~
      values.map!((a) => quote(a)).join(",") ~
      ")"
    );
    return get_insert_id();
  }

  ulong get_insert_id() { return mysql_insert_id(mysql); }

  //---------------------------------------------------------------------------


  void quick_update(string tablename, string[string] values, string where)
  {
    quick_update(tablename, values, [ where ]);
  }

  void quick_update(string tablename, string[string] values, string[] wheres)
  {
    query
    (
      "update `"~tablename~"` set "~
      meld!
      (
        (a,b) => (a~"="~quote(b))
      )
      (values).join(",")~" where "~wheres.join(" and ")
    );
  }

  void quick_update(string tablename, string[] columns, string[] values, string where)
  {
    quick_update(tablename, columns, values, [ where ]);
  }

  void quick_update(string tablename, string[] columns, string[] values, string[] wheres)
  {
    string[] s;

    for (int i=0; i<columns.length; ++i)
      s~= columns[i] ~ "=" ~ quote(values[i]);

    
    query("update `"~tablename~"` set "~join(s,",")~" where "~wheres.join(" and "));
  }

  void replace(string tablename, string[string] values)
  {
    query
    (
      "replace into  `"~tablename~"` set "~
      meld!
      (
        (a,b) => (a~"="~quote(b))
      )
      (values).join(",")
    );
  }

  //---------------------------------------------------------------------------
  // Shortcuts for use with ids
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------

  string[string] get(string table, ulong id)
  {
    return query_row("select * from "~table~" where id="~to!string(id));
  }

  //---------------------------------------------------------------------------

  void set(string tablename, string[string] values, ulong id)
  {
    quick_update(tablename, values, [ "id="~to!string(id) ]);
  }

  //---------------------------------------------------------------------------

  void remove(string tablename, ulong id)
  {
    query("delete from "~tablename~" where id="~to!string(id));
  }

  //---------------------------------------------------------------------------
  // Database reflection methods
  //---------------------------------------------------------------------------

  bool table_exists(string tablename)
  {
    return (query_value("show tables like "~quote(tablename)) !is null);
  }
  
  //---------------------------------------------------------------------------

  string[] get_tables()
  {
    return query_column("show tables");
  }
  
  //---------------------------------------------------------------------------

  bool has_connection() { return mysql !is null; }

  //---------------------------------------------------------------------------

  bool identifier_ok(string name) { return true; }

  //---------------------------------------------------------------------------

  // The following allow direct access, use with caution
  
  MYSQL* get_handle() { return mysql; }

  MYSQL_RES* query_raw(string sql)
  {
    if (mysql is null) connect();
    
    if (mysql_real_query(mysql, sql.ptr, sql.length) != 0)
      throw new DBException(to!string(mysql_error(mysql)), mysql_errno(mysql), sql);
    
    MYSQL_RES* res = mysql_use_result(mysql);
    if (mysql_errno(mysql) != 0)
      throw new DBException(to!string(mysql_error(mysql)), mysql_errno(mysql), sql);

    return res;
  }

  struct MySQLRange
  {
    this(MYSQL_RES* r)
    {
      res = r;

      if (r !is null)
        popFront();
    }
    @property bool empty() { return row is null; }
    @property string[string] front() { return row; }

    void popFront()
    {
      row = get_row(res);
      if (row is null)
      {
        mysql_free_result(res);
        res = null;
      }
    }

    private:
      MYSQL_RES* res;
      string[string] row = null;
  }

  void cancel(ref ResultType r)
  {
    mysql_free_result(r.res);
  }

  private:

    MYSQL* mysql = null;

    int error_code;

    //-------------------------------------------------------------------------
}

package:


bool get_single(MYSQL_RES* res, ref string v)
{
  MYSQL_ROW row = mysql_fetch_row(res);
  if (row is null)
  {
    if (mysql_errno(res.handle) != 0)
      throw new DBException(to!string(mysql_error(res.handle)), mysql_errno(res.handle),"");
    else
      return false;
  }
  auto lengths = mysql_fetch_lengths(res);
  if (row[0] is null)
    v = null;
  else
    v = row[0][0..lengths[0]].idup;
  return true;
}

//-------------------------------------------------------------------------

string[string] get_row(MYSQL_RES* res)
{
  string[string] r;


  MYSQL_ROW row = mysql_fetch_row(res);

  if (row is null)
  {
    if (mysql_errno(res.handle) != 0)
      throw new DBException(to!string(mysql_error(res.handle)), mysql_errno(res.handle),"");
    else
      return null;
  }

  uint numFields = mysql_num_fields(res);

  MYSQL_FIELD* fields = mysql_fetch_fields(res);

  auto lengths = mysql_fetch_lengths(res);

  for (int i = 0; i < numFields; ++i)
  {
    auto s = fields[i].name[0..fields[i].name_length].idup;

    if (row[i] is null)
      r[s] = null;
    else
      r[s] = row[i][0..lengths[i]].idup;
  }
  return r;
}
