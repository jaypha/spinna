/*
 * Content Type header handling
 *
 * Copyright: Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.mime.header;

import std.string;
import std.ascii;
import std.c.string;
import std.array;
import std.exception;
import std.algorithm;

import jaypha.range;
import jaypha.read_until;
import jaypha.types;

/*
 * Handles MIME related content headers in accordance with RFC's
 *
 * RFC2183 - Content Disposition header
 * RFC2045 - MIME
 * RFC2822  - Defines header syntax
 */

/*
 * TODO
 *
 * More header types
 * Parse and store whole or part of MIME file.
 */

struct MimeHeader
{
  string name;
  string field_body;
}

struct MimeContentType
{
  string original;
  string type = "text/plain";
  string[string] parameters;
}

struct MimeContentDisposition
{
  string type = "inline";
  string[string] parameters;
}

//-----------------------------------------------------------------------------
// extracts the content of a Content-Type MIME header. Covered by rfc 2045.

MimeContentType get_mime_content_type(const(char)[] s)
{
  MimeContentType c;
  auto p = std.string.indexOf(s,'/');
  if (p == -1) throw new Exception("malformed MIME Content-Type header");
  auto type = s[0..p];
  ++p;
  auto q = my_index_of(s[p..$],';')+p;
  c.type = (strip(type) ~ '/' ~ strip(s[p..q])).idup;

  if (q == s.length)
    return c;

  p=q+1;
  do
  {
    q = my_index_of(s[p..$],';')+p;
    extract_mime_params(s[p..q], c.parameters);
    p=q+1;
  } while (p < s.length);
  return c;
}

//-----------------------------------------------------------------------------
// extracts the content of a Content-Disposition MIME header.
// Covered by rfc 2183.
 
MimeContentDisposition get_mime_content_disposition(const(char)[] s)
{
  MimeContentDisposition c;
  auto p = std.string.indexOf(s,';');
  if (p == -1)
  {
    c.type = strip(s).idup;
    return c;
  }

  c.type = strip(s[0..p]).idup;

    ++p;
    ulong q;
    do
    {
      q = std.string.indexOf(s[p..$],';');
      if (q == -1) q = s.length;
      else q = q+p;
      extract_mime_params(s[p..q], c.parameters);
      p=q+1;
    } while (p < s.length);

  return c;
}

//-----------------------------------------------------------------------------
// A version of indexof that is easier to work with.

auto my_index_of(const(char)[] s, char c)
{
  auto p = cast(char*)memchr(s.ptr, c, s.length);  //foreach (i,sc;s)
  return (p?p - s.ptr:s.length);
}

//-----------------------------------------------------------------------------

S1 grab(S1, S2)(ref S1 s, S2 pattern)
{
  size_t j = s.length;
  foreach (i, c; s)
  {
    if (inPattern(c, pattern))
    {
      j = i;
      break;
    }
  }
  scope(exit) s = s[j .. $];
  return s[0 .. j];
}

//-----------------------------------------------------------------------------

void extract_mime_params(const(char)[] pair, ref string[string] parameters)
{
  auto r = std.string.indexOf(pair,'=');
  if (r == -1) throw new Exception("malformed MIME Content-Type header");
  else
  {
    auto index = strip(pair[0..r]);
    if (index.length == 0) throw new Exception("malformed MIME Content-Type header");
    auto v = stripLeft(pair[r+1..$]);
    if (v[0] == '"')
    {
      auto i = std.string.indexOf(v[1..$],'"');
      if (i == -1) throw new Exception("malformed MIME Content-Type header");
      parameters[index.idup] = v[1..i+1].idup;
    }
    else
    {
      parameters[index.idup] = grab(v,whitespace).idup;
    }
  }
}

//-----------------------------------------------------------------------------

const(char)[] get_mime_header_type(const(char)[] s)
{
  auto p = std.string.indexOf(s,':');
  if (p == 0 || p == s.length) throw new Exception("malformed MIME header string");
  return s[0..p];
}

//-----------------------------------------------------------------------------

MimeHeader[] parse_headers(BR)(ref BR r)
  if (isByteRange!BR)
{
  MimeHeader[] headers;
  /* Read headers until we get to a blank line */

  while (!r.skip_over_anyway("\r\n",true))
  {
    auto name = appender!string();
    auto field_body = appender!string();

    while (!r.empty && r.front != ':')
    {
      name.put(r.front);
      r.popFront();
    }
    enforce(!r.empty);
    r.popFront();
    enforce(!r.empty);

    do
    {
      while (!r.empty && r.front != '\r')
      {
        field_body.put(r.front);
        r.popFront();
      }
      enforce(!r.empty);
      r.popFront();
      enforce(!r.empty);
      enforce(r.front=='\n');
      r.popFront();
      enforce(!r.empty);
    } while(r.front == ' ' || r.front == '\t');
    headers ~= MimeHeader(name.data, field_body.data);
  }
  return headers;
}

//-----------------------------------------------------------------------------

unittest
{
  auto c = get_mime_content_type("text / plain ; two = a; three=\"z l\"");
  assert(c.type=="text/plain");
  assert(c.parameters.length == 2);
  assert("two" in c.parameters);
  assert(c.parameters["two"] == "a");
  assert("three" in c.parameters);
  assert(c.parameters["three"] == "z l");

  auto d = get_mime_content_disposition("form-data; two=a (not this); three=z");
  assert(d.type=="form-data");
  assert(d.parameters.length == 2);
  assert("two" in d.parameters);
  assert(d.parameters["two"] == "a");
  assert("three" in d.parameters);
  assert(d.parameters["three"] == "z");

  auto e = get_mime_content_type("text / html");
  assert(e.type=="text/html");
  assert(e.parameters.length == 0);

  import std.range;
  string entity_text =
    "Content-type: text/plain; charset=us-ascii\r\n"
    "Content-disposition: blah blah \r\n"
    "\tblah\r\n"
    "\r\n"
    "This is explicitly typed plain US-ASCII text.\r\n"
    "It DOES end with a linebreak.\r\n";

  auto r1 = inputRangeObject(cast(ubyte[]) entity_text.dup);

  auto headers = parse_headers(r1);
  assert(headers.length == 2);
  assert(headers[0].name == "Content-type");
  assert(headers[0].field_body == " text/plain; charset=us-ascii");
  assert(headers[1].name == "Content-disposition");
  assert(headers[1].field_body == " blah blah \tblah");
  assert(r1.front == 'T');
}

