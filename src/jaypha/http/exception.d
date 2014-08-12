/*
 * HTTP exception
 *
 * Copyright 2009 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

module jaypha.http.exception;

class HttpException : Exception
{
  private ulong code_;
  
  this(string msg, ulong code = 400)
  {
    code_ = code;
    super(msg);
  }
  
  @property ulong code() { return code_; }
}
