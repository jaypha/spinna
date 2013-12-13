
module jaypha.dbms.recordbase;


public import std.conv;


template RecordBase(RecordType, DBType, string table)
{
  //-----------------------------------------------------------------

  static bool exists(DBType db, uint id)
  {
    return (db.query_value("select count(*) from "~table~" where id="~to!string(id)) != "0");
  }
  
  static auto get_records(DBType db, char[] where)
  {
    auto range = db.query_range("select * from "~table~" where "~where);

    struct RecordResult
    {
      RecordType record;
      @property bool empty() { return range.empty; }
      @property RecordType front() { return record; }
      void popFront()
      {
        range.popFront();
        record = new RecordType(range.front);
      }
    }
    return RecordResult(query_result(sql));
  }

  static RecordType get_record(DBType db, string where)
  {
    strmap r = db.query_row("select * from "~table~" where "~where);
    if (r is null) return null;
    return new RecordType(db, r);
  }

  static RecordType get_record(DBType db, uint id)
  {
    strmap r = db.query_row("select * from "~table~" where id="~to!string(id));
    if (r is null) return null;
    return new RecordType(db, r);
  }

  static void remove_record(DBType db, uint id)
  {
    db.query("delete from "~table~" where id = "~to!string(id));
  }

  static void remove_records(DBType db, uint[] ids)
  {
    if (ids.length)
      db.query("delete from "~table~" where id in ("~join(map!(to!string)(ids),",")~")"));
  }

  static void remove_records(DBType db, string where)
  {
    db.query("delete from "~table~" where "~where);
  }

  //-----------------------------------------------------------------


  //-----------------------------------------------------------------

  /* Accessor functions */

  DBType db() { return db_; }

  uint id() { return id_; }

  @property bool is_new() { return is_new_; }

  //-----------------------------------------------------------------

  /* I/O functions */

  bool load(uint id)
  {
    string[string] r = db_.query_row("select * from "~table~" where id="~to!string(id));
    if (r is null)
      return false;
    set(r);
    return true;
  }

  void remove()
  {
    db_.query("delete from "~table~" where id="~to!string(id));
    id_ = 0;
    isNew_ = true;
  }

  //-----------------------------------------------------------------
}

template RecordVars(DBType)
{
  uint id_;
  bool is_new_;
  DBType db_;
}

