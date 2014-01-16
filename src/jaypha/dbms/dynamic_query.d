

module jaypha.dbms.dynamic_query;

import std.array;
import std.algorithm;
import std.conv;

struct DynamicQuery
{
  //-------------------------------------------------------------------------

  enum JoinType:string { Left = "left", Right = "right", Inner = "inner" };

  struct Table
  {
    string name;
    JoinType join;
    string condition;
  }

  enum SortType:string { Asc = "asc", Desc = "desc" };

  struct SortClause
  {
    string column;
    SortType dir;
  }

  //-------------------------------------------------------------------------

  string table = null;

  bool distinct = true;

  string[] columns = [];
  string[] wheres = [];
  SortClause[] sorting = [];

  SortClause[] groups = [];
  string[] havings = [];

  ulong limit = 0;
  ulong offset = 0;

  string query = null;

  //-------------------------------------------------------------------------

  void add_table(string name, JoinType join = JoinType.Inner, string condition=null)
  {
    tables~= Table(name, join, condition);
  }

  //-------------------------------------------------------------------------

  void add_sorting(string name, SortType dir = SortType.Asc)
  {
    sorting ~= SortClause(name, dir);
  }

  //-------------------------------------------------------------------------

  void add_grouping(string name, SortType dir = SortType.Asc)
  {
    sorting ~= SortClause(name, dir);
  }

  //-------------------------------------------------------------------------

  string get_count_query()
  {
    return "select count(*) from ("~get_query(false)~") as tmp";
  }

  //-------------------------------------------------------------------------

  string get_query(bool get_limits = true)
  in
  {
    assert (table !is null || query !is null);
  }
  body
  {
    if (query !is null)
    {
      if (get_limits) return query ~ get_limit_sql();
      else return query;
    }

    auto sql = appender!string();

    sql.put("select ");
    sql.put(get_columns_sql());
    sql.put(" from ");
    sql.put(get_tables_sql());
    sql.put(get_wheres_sql());
    sql.put(get_grouping_sql());
    sql.put(get_having_sql());
    sql.put(get_sorting_sql());
    if (get_limits) sql.put(get_limit_sql());

    return sql.data;
  }

  //-------------------------------------------------------------------------

  protected string get_columns_sql()
  {
    if (columns.length == 0)
      return "*";

    return "distinct (" ~ join(columns,"),(") ~ ")";
  }

  //-------------------------------------------------------------------------

  protected string get_tables_sql()
  {
    auto sql = appender!string();

    sql.put(table);
    foreach (t; tables)
    {
      sql.put(" ");
      sql.put(t.join);
      sql.put(" join ");
      sql.put(t.name);
      if (t.condition)
      {
        sql.put(" on (");
        sql.put(t.condition);
        sql.put(")");
      }
    }
    return sql.data;
  }

  //-------------------------------------------------------------------------

  protected string get_wheres_sql()
  {
    if (wheres.length == 0)
      return "";

    return " where (" ~ join(wheres,") and (") ~ ")";
  }

  //-------------------------------------------------------------------------

  protected string get_sorting_sql()
  {
    if (sorting.length == 0)
      return "";

    auto sql = appender!string();
    sql.put(" order by ");

    sql.put
    (
      join
      (
        map!(a => a.column ~ " " ~ a.dir)(sorting),
        ","
      )
    );

    return sql.data;
  }

  //-------------------------------------------------------------------------

  protected string get_grouping_sql()
  {
    if (groups.length == 0)
      return "";

    auto sql = appender!string();
    sql.put(" group by ");

    sql.put
    (
      join
      (
        map!(a => a.column ~ " " ~ a.dir)(groups),
        ","
      )
    );

    return sql.data;
  }

  //-------------------------------------------------------------------------

  protected string get_having_sql()
  {
    if (havings.length == 0)
      return "";

    return " having (" ~ join(havings,") and (") ~ ")";
  }

  //-------------------------------------------------------------------------

  protected string get_limit_sql()
  {
    if (limit == 0) return "";

    auto sql = " limit "~to!string(limit);
    if (offset != 0)
      sql ~= " offset "~to!string(offset);
    return sql;
  }

  //-------------------------------------------------------------------------

  private:
    Table[] tables;
}

unittest
{
  import std.stdio;

  DynamicQuery dq;

  dq.table = "members";
  dq.add_table("ww", DynamicQuery.JoinType.Left, "members.x = ww.y");
  dq.add_table("zz");
  dq.wheres ~= "x = 1";
  dq.havings ~= "y = 4";
  dq.add_grouping("zz.g");
  dq.add_sorting("y");
  dq.add_sorting("z",DynamicQuery.SortType.Desc);
  dq.limit = 5;
  dq.offset = 10;

  writeln(dq.get_query(false));
  writeln(dq.get_query());

  dq.query = "select rt from by";
  writeln(dq.get_query(false));
  writeln(dq.get_query());
}
