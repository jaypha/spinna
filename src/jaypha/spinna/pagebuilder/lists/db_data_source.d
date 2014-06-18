
module jaypha.spinna.pagebuilder.lists.db_data_source;

import jaypha.spinna.pagebuilder.lists.data_source;
public import jaypha.dbms.dynamic_query;

import std.conv;

abstract class DBDataSource(Database) : DataSource
{
  this(DynamicQuery q, ref Database db) { query = q; database = db; }

  @property ulong size()
  {
    return to!ulong(database.query_value(query.get_count_query()));
  }

  void set_start(ulong s) { start = s; }
  void set_limit(ulong s) { limit = s; }

  @property ulong num_pages()
  {
    auto count = to!ulong(database.query_value(query.get_count_query()));
    return (count + size - 1)/size;
  }

  void reset()
  {
    if (limit != 0)
    {
      query.limit = limit;
      query.offset = start;
    }
    result = database.query(query.get_query());
    if (!result.empty) prepare_front();
  }

  protected:
    ulong start = 0;
    ulong limit = 0;

    DynamicQuery query;
    Database database;

    Database.ResultType result;
    abstract void prepare_front();
}

abstract class DBListSource(Database) : DBDataSource!Database, ListSource
{
  this(DynamicQuery q, ref Database db) { super(q,db); }

  @property string[string] front() { return _front; }
  @property bool empty() { return result.empty; }
  void popFront() { result.popFront(); if (!result.empty) prepare_front(); }

  protected:
    string[string] _front;
}

abstract class DBTableSource(Database) : DBDataSource!Database, TableSource
{
  this(DynamicQuery q, ref Database db) { super(q,db); }

  @property string[] front() { return _front; }
  @property bool empty() { return result.empty; }
  void popFront() { result.popFront(); if (!result.empty) prepare_front(); }

  protected:
    string[] _front;
}
