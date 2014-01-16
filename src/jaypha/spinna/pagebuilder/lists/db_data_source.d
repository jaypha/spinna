
module jaypha.spinna.pagebuilder.lists.db_data_source;

import jaypha.spinna.pagebuilder.lists.data_source;
public import jaypha.dbms.dynamic_query;

import std.conv;

/*
abstract class DBTableSource(Database) : TableSource
{
  this(DynamicQuery q, ref Database db) { query = q; database = db; }

  void set_page_size(ulong s) { size = s; }
  void set_page(ulong p) { page = p; }
  @property ulong num_pages()
  {
    auto count = to!ulong(database.query_value(query.get_count_query()));
    return (count + size - 1)/size;
  }

  @property string[] front() { return _front; }
  @property bool empty() { return result.empty; }
  void popFront() { result.popFront(); if (!result.empty) prepare_front(); }

  void reset()
  {
    query.limit = size;
    query.offset = (page-1)*size;
    result = database.query(query.get_query());
    if (!result.empty) prepare_front();
  }

  protected:
    ulong page = 1;
    ulong size = 0;
    DynamicQuery query;
    Database database;

    Database.ResultType result;
    string[] _front;
    abstract void prepare_front();
}

abstract class DBListSource(Database) : ListSource
{
  this(DynamicQuery q, ref Database db) { query = q; database = db; }

  void set_page_size(ulong s) { size = s; }
  void set_page(ulong p) { page = p; }
  @property ulong num_pages()
  {
    auto count = to!ulong(database.query_value(query.get_count_query()));
    return (count + size - 1)/size;
  }

  @property string[string] front() { return _front; }
  @property bool empty() { return result.empty; }
  void popFront() { result.popFront(); if (!result.empty) prepare_front(); }

  void reset()
  {
    query.limit = size;
    query.offset = (page-1)*size;
    result = database.query(query.get_query());
    if (!result.empty) prepare_front();
  }

  protected:
    ulong page = 1;
    ulong size = 0;
    DynamicQuery query;
    Database database;

    Database.ResultType result;
    string[string] _front;
    abstract void prepare_front();
}
*/

abstract class DBDataSource(Database) : DataSource
{
  this(DynamicQuery q, ref Database db) { query = q; database = db; }

  void set_page_size(ulong s) { size = s; }
  void set_page(ulong p) { page = p; }
  @property ulong num_pages()
  {
    auto count = to!ulong(database.query_value(query.get_count_query()));
    return (count + size - 1)/size;
  }

  void reset()
  {
    query.limit = size;
    query.offset = (page-1)*size;
    result = database.query(query.get_query());
    if (!result.empty) prepare_front();
  }

  protected:
    ulong page = 1;
    ulong size = 0;
    DynamicQuery query;
    Database database;

    Database.ResultType result;
    abstract void prepare_front();
}

abstract class DBListSource(Database) : DBDataSource!Database, ListSource
{
  @property string[string] front() { return _front; }
  @property bool empty() { return result.empty; }
  void popFront() { result.popFront(); if (!result.empty) prepare_front(); }

  protected:
    string[string] _front;
}

abstract class DBTableSource(Database) : DBDataSource!Database, TableSource
{
  @property string[] front() { return _front; }
  @property bool empty() { return result.empty; }
  void popFront() { result.popFront(); if (!result.empty) prepare_front(); }

  protected:
    string[] _front;
}
