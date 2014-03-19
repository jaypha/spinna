
module jaypha.mime.multipart_reader;

import jaypha.range;
import jaypha.read_until;
import jaypha.types;
import jaypha.algorithm;

import jaypha.mime.entity;

import std.string;
import std.range;
import std.traits;
import std.array;
import std.algorithm;
import std.ascii;
import std.exception;
import std.typecons;


auto get_multipart_reader(Reader)(ref Reader r, string boundary)
  if (isByteRange!Reader)
{
  string full_boundary = "\r\n--"~boundary;

  find_split(r, full_boundary[2..$]);
  find_split(r, "\r\n"); // skip over whitespace, but don't bother checking.

  auto entity = mime_entity_reader(read_until(r, full_boundary));

  alias typeof(entity) T;

  struct MR
  {
    @property bool empty() { return r.empty; }

    @property T front() { return entity; }

    void popFront()
    {
      if (!entity.content.empty) entity.content.drain(); // In case the user pops before fully reading the entity

      auto rem = find_split(r, "\r\n"); // skip over whitespace, but don't bother checking.
      bool last_time = startsWith(rem[0], "--");
      if (!last_time)
      {
        enforce(rem[1] == "\r\n");
        entity = mime_entity_reader(read_until(r, full_boundary));
      }
      else
      {
        r.drain(); // Skip epilogue;
      }
    }
  }
  return MR();
}
/+
auto get_multipart_reader(Reader)(ref Reader r, string boundary)
  if (isByteRange!Reader)
{
  string full_boundary = "\r\n--"~boundary;

  if (!skip_over_anyway(r, full_boundary[2..$]))
    skip_over_until(r,full_boundary);
  jaypha.range.munch(r, " \t");
  skip_over_anyway(r,"\r\n");

  auto entity = mime_entity_reader(read_until(r, full_boundary));

  alias typeof(entity) T;

  struct MR
  {
    @property bool empty() { return r.empty; }

    @property T front() { return entity; }

    void popFront()
    {
      bool last_time = false;

      if (!entity.content.empty) entity.content.drain();
      if (skip_over_anyway(r, "--"))  // terminating boundary
        last_time = true;
      jaypha.range.munch(r, " \t");
      if (!last_time)
      {
        skip_over_anyway(r,"\r\n");
        entity = mime_entity_reader(read_until(r, full_boundary));
      }
      else
      {
        r.drain(); // Skip epilogue;
      }
    }
  }
  return MR();
}
+/
//----------------------------------------------------------------------------

private bool skip_over_until(Reader)(ref Reader r, string sentinel)
{
  while (true)
  {
    if (cast(char)r.front == sentinel[0])
      for (uint i=0; i<=sentinel.length; ++i)
      {
        if (i == sentinel.length)
          return true;
        if (r.empty)
          return false;

        if (cast(char)r.front != sentinel[i])
          break;

        r.popFront();
        if (r.empty)
          return false;
      }
    else
    {
      r.popFront();
      if (r.empty)
        return false;
    }
  }
}


unittest
{

  string preamble =
    "This is the preamble.  It is to be ignored, though it\r\n"
    "is a handy place for composition agents to include an\r\n"
    "explanatory note to non-MIME conformant readers.\r\n"
    "\r\n"
    "--simple boundary  \t  \t\t \r\n"
    "\r\n"
    "This is implicitly typed plain US-ASCII text.\r\n"
    "It does NOT end with a linebreak.\r\n"
    "--simple boundary\r\n"
    "Content-type: text/plain; charset=us-ascii\r\n"
    "\r\n"
    "This is explicitly typed plain US-ASCII text.\r\n"
    "It DOES end with a linebreak.\r\n"
    "\r\n"
    "--simple boundary--\r\n"
    "\r\n"
    "This is the epilogue.  It is also to be ignored.\r\n";

  string preamble2 = "--simple boundary\r\nZBC";

  auto buff = appender!(ubyte[]);

  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;

  string y = "abc";

  auto r1 = inputRangeObject(txt);

  auto x = r1.skip_over_until("cbx");
  assert(x);
  r1.copy(buff);
  assert(cast(char[])(buff.data) == "yz");

  buff.clear();

  txt = cast(ubyte[]) "acabacbxyz".dup;
  r1 = inputRangeObject(txt);

  assert(!r1.skip_over_until("c1bx"));
  assert(r1.empty);

  txt = cast(ubyte[]) preamble.dup;
  r1 = inputRangeObject(txt);

  auto r2 = get_multipart_reader(r1, "simple boundary");


  assert(r1.front == cast(ubyte)'T');
  auto r3 = r2.front;

  assert(r3.headers.length == 0);
  put(buff,r3.content);
  assert(buff.data == "This is implicitly typed plain US-ASCII text.\r\n"
    "It does NOT end with a linebreak.");
  assert(r3.content.empty);
  assert(r1.front == cast(ubyte)'\r');

  buff.clear();
  r2.popFront();
  r3 = r2.front;
  assert(r3.headers.length == 1);
  
  r3.content.copy(buff);

  assert(buff.data ==
    "This is explicitly typed plain US-ASCII text.\r\n"
    "It DOES end with a linebreak.\r\n");
  assert(r3.content.empty);
  r2.popFront();
  assert(r2.empty);
  assert(r1.empty);

}




/+
private struct MultipartReader(Reader)
{
  this (Reader _r, string _boundary) { r = _r; boundary = _boundary; }

  bool empty = false;

  @property ubyte[] front() { return buffer.data; }
  
  void popFront()
  {
    buffer.clear();
    if (last_time)
      empty = true;
    else
    {
      bool do_continue = true;
      while (do_continue)
      {
        r.popFront();
        enforce(!r.empty);
        if (r.front == boundary[0])
        {
          do_continue = false;
          foreach(i; 0..boundary.length)
          {
            if (r.front != boundary[i])
            {
              buffer.put(boundary[0..i]);
              do_continue = true;
              break;
            }
            r.popFront();
            enforce(!r.empty);
          }
        }
        else
          buffer.put(r.front);
      }

      if (skip_over_ignore(r, "--"))
        last_time = true;
      munch(r, " \t");
      if (!last_time);
        skip_over_ignore(r,"\r\n");
    }
  }

  
  private:
    Reader r;
    bool last_time;
    string boundary;
    Appender!(ubyte[]) buffer;
}
+/