//Written in the D programming language
/*
 * Converts a text file in D code.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.embed;

enum TplDState { Code, Text, Short, Dot };

@trusted pure nothrow bool is_it(const(char)[] s, uint pos, dchar c)
{
  return  (pos < s.length && s[pos] == c);
}

string embedD(string s, string fn = "write")
{
  string out_s = "";
  string temp = "";

  TplDState state = TplDState.Text;

  uint i=0;

  while (i<s.length)
  {
    auto ch = s[i];

    if (state == TplDState.Text)
    {
      if (ch == '<' && is_it(s, i+1,'%'))
      {
        /* switching to embedded D */

        if (temp.length)
        {
          out_s ~= fn ~ "(\"" ~ temp ~ "\");\n";
          temp = "";
        }
        i+=2;
        
        if (is_it(s, i,'='))
        {
          state = TplDState.Short;
          ++i;
        }
        else if (is_it(s, i,'.'))
        {
          state = TplDState.Dot;
          ++i;
        }
        else
          state = TplDState.Code;
      }
      else
      {
        if (ch == '\n')
          temp ~= "\\n";
        else if (ch == '\r')
          temp ~= "\\r";
        else
        {
          if (ch == '"')
            temp ~= r"\";
          temp ~= ch;
        }
        ++i;
      }
    }
    else
    {
      if (ch == '%' && is_it(s, i+1,'>'))
      {
        /* embedded D gets printed, switching back to text */
        if (temp.length)
        {
          switch(state)
          {
            case TplDState.Short:
              out_s ~= fn ~ "(" ~ temp ~ ");\n";
              break;
            case TplDState.Dot:
              out_s ~= fn ~ "." ~ temp ~ ";\n";
              break;
            case TplDState.Code:
              out_s ~= temp ~ "\n";
            default:
              break;
          }
          temp = "";
        }
        state = TplDState.Text;
        i += 2;
      }
      else
      {
        temp ~= ch;
        ++i;
      }
    }
  }
  out_s ~= fn ~ "(\"" ~ temp ~ "\");\n";
  return out_s;
}

debug(embed)
{
  import std.stdio;

  void main()
  {
    //string ss = tpl_to_d!("abcd \"<%=a%>\" cdf","write")();

    //writeln(ss);
    auto count = 12;
    auto x = true;
    auto title = "Heaven";

    mixin(embedD(import("embed_test.tpl")));
  }
}
