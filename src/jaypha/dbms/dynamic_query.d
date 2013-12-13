

module jaypha.dbms.dynamic_query;



struct DynamicQuery(DB)
{
  struct Table
  {
    string name;
    string join;
    string condition;
  }

  DB database;
  Table[] tables;

  this(DB db) { dataabse = db; }

  void add_table(string name, string join = ',', string condition=null)
  {
    if (tables.length == 0) join = null;
    tables~= { name, join, condition };
  }

  void add_columns
  
  void add_clause
  
  void add_group_by
  
  void set_limit

  void add_sort
}
