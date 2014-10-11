

module jaypha.inet.imf.writing;

public import jaypha.inet.mime.header;

import std.array;
import std.string;

enum ImfMaxLineLength = 998;
enum ImfRecLineLength = 76;

//-----------------------------------------------------------------------------
// Mailbox type used in address based headers (from, to, cc, etc)

struct Mailbox
{
  string address;
  string name;
  @property string asString()
  { 
    if (name.empty) return address;
    else return name ~ " <" ~ address ~ ">";
  }
}


//-----------------------------------------------------------------------------
// Performs folding to keep lines to a certian maximum length.
//-----------------------------------------------------------------------------

string imfFold(string content, ulong additional, out ulong lastLineLength)
{
  auto a = appender!string();
/*

  auto i = lastIndexOfAny(content[0..(MaxLineLength-additional)],ImfWsp);
  enforce(i != 0);

  app.put(content[0..i]);
  app.put(ImfEoln);
  content = content[i..$];
  while (content.length > MaxLineLength)
  {
    i = lastIndexOfAny(content[0..MaxLineLength],ImfWsp);
    enforce(i != 0);

    app.put(content[0..i]);
    app.put(ImfEoln);
    content = content[i..$];
  }
  app.put(content);
*/
  while (content.length+additional > ImfMaxLineLength)
  {
    //auto i = lastIndexOfAny(content[0..MaxLineLength-additional],ImfWsp);
    auto i = lastIndexOf(content[0..MaxLineLength-additional],' ');
    assert(i != 0);

    a.put(content[0..i]);
    a.put(ImfEoln);
    content = content[i..$];
    additional = 0;
  }
  a.put(content);
  lastLineLength = content.length;

  return a.data;
}

//-----------------------------------------------------------------------------
// Standard function for unstructured headers.

MimeHeader unstructuredHeader(string name, string fieldBody)
{
  MimeHeader header;
  header.name = name;
  ulong len;

  if (name.length + fieldBody.length + 1 > ImfMaxLineLength)
    header.fieldBody = imfFold(fieldBody,name.length+1, len);
  else
    header.fieldBody = fieldBody;
  return header;
}

//-----------------------------------------------------------------------------
// Standard function for address (from,to,cc,bcc) headers.

MimeHeader addressHeader(string name, Mailbox[] addresses)
{
  MimeHeader header;
  header.name = name;

  string[] list;
  ulong runningLength = name.length+1;
  foreach (r;addresses)
  {
    string n = " ";
    n ~= r.asString;

    if (runningLength + n.length > ImfMaxLineLength)
    {
      runningLength = -2;
      n = ImfEoln ~ n;
    }
    list ~= n;
    runningLength += n.length+1;
  }
  header.field_body = list.join(",");
  return header;
}
