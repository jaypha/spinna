

module db;

import jaypha.dbms.mysql.database;

alias MySqlDatabase DB;

DB database;

static this()
{
  database = new DB();
}
