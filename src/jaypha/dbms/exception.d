

module jaypha.dbms.exception;

import std.conv;

class DBException : Exception
{
 	this () { super("Unknown Error.");	}

	this (string msg, int code, string sql)
  {
		super(msg~" ("~to!string(code)~"), SQL: \""~sql~"\"");
    code_ = code;
    sql_ = sql;
  }

  @property int error_code() { return code_; }
  @property string sql() { return sql_; }

  private:
    int code_;
    string sql_;
}
