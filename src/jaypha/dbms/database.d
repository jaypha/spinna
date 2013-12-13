

module jaypha.dbms.database;


interface Database
{
  void connect();
  void close();

  char[] quote(char[] s);

  void query(char[] sql);
  char[] queryValue(char[] sql);
  long queryIntValue(char[] sql);
  char[][char[]] queryRow(char[] sql);
  char[][char[]][] queryData(char[] sql);
  char[][] queryColumn(char[] sql);

  //
  // constraints
  // idColumn must be in result table, be integral and unique.
  //

  char[][char[]][int] queryIndexedData(char[] sql, char[] idColumn="id");
  char[][int] queryIndexedColumn(char[] sql, char[] idColumn="id");

  //---------------------------------------------------------------------------

  //
  // constraints
  // values are assumed to be already fully processed, validated and, for
  // strings, escaped and quoted.
  //
  
  int quickInsert(char[] tablename, char[][char[]] values);
  int quickInsert(char[] tablename, char[][] columns, char[][] values);
  void quickUpdate(char[] tablename, char[][char[]] values, char[][] wheres);
  void quickUpdate(char[] tablename, char[][char[]] values, char[] where);
  void quickUpdate(char[] tablename, char[][] columns, char[][] values, char[][] wheres);
  void quickUpdate(char[] tablename, char[][] columns, char[][] values, char[] where);

  bool tableExists(char[] tableName);

  char[][] getTables();

  long getInsertID();

  bool hasConnection();

  bool identifierOK(char[] idName);

}
