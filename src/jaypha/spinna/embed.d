//Written in the D programming language
/*
 * Converts text with embedded code into pure code.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.embed;

enum TplDState { Code, Text, Short, Dot };

@trusted pure nothrow bool isIt(const(char)[] s, uint pos, dchar c)
{
  return  (pos < s.length && s[pos] == c);
}

string embedD(string s, string fn = "write")
{
  string outString = "";
  string temp = "";

  TplDState state = TplDState.Text;

  uint i=0;

  while (i<s.length)
  {
    auto ch = s[i];

    if (state == TplDState.Text)
    {
      if (ch == '<' && isIt(s, i+1,'%'))
      {
        /* switching to embedded D */

        if (temp.length)
        {
          outString ~= fn ~ "(\"" ~ temp ~ "\");\n";
          temp = "";
        }
        i+=2;
        
        if (isIt(s, i,'='))
        {
          state = TplDState.Short;
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
      if (ch == '%' && isIt(s, i+1,'>'))
      {
        /* embedded D gets printed, switching back to text */
        if (temp.length)
        {
          switch(state)
          {
            case TplDState.Short:
              outString ~= fn ~ "(" ~ temp ~ ");\n";
              break;
            case TplDState.Code:
              outString ~= temp ~ "\n";
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
  outString ~= fn ~ "(\"" ~ temp ~ "\");\n";
  return outString;
}
