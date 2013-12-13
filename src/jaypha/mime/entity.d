/*
 * Extracts a MIME entity, separating the headers form the content.
 *
 * Copyright 2009-2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

module jaypha.mime.entity;

import jaypha.mime.header;

import jaypha.types;


struct MimeEntity
{
  MimeHeader[] headers;

  ubyte[] content;
}

struct MimeEntityReader(BR)
{
  alias BR MET;
  MimeHeader[] headers;
  BR content;
}

auto mime_entity_reader(BR)(BR reader)
  if (isByteRange!BR)
{
  return MimeEntityReader!(BR)(parse_headers(reader),reader);
}


unittest
{
  import std.stdio;
  import std.exception;
  import std.array;
  import std.algorithm;
  import std.range;

  string entity_text =
    "Content-type: text/plain; charset=us-ascii\r\n"
    "Content-disposition: blah blah \r\n"
    "\tblah\r\n"
    "\r\n"
    "This is explicitly typed plain US-ASCII text.\r\n"
    "It DOES end with a linebreak.\r\n";

  auto r1 = inputRangeObject(cast(ubyte[]) entity_text.dup);

  auto entity = mime_entity_reader(r1);

  static assert(is(typeof(entity.content) == entity.MET));
  assert(entity.headers.length == 2);
  assert(entity.headers[0].name == "Content-type");
  assert(entity.headers[0].field_body == " text/plain; charset=us-ascii");
  assert(entity.headers[1].name == "Content-disposition");
  assert(entity.headers[1].field_body == " blah blah \tblah");

  auto buff = appender!(ubyte[]);

  entity.content.copy(buff);
  assert(buff.data == 
    "This is explicitly typed plain US-ASCII text.\r\n"
    "It DOES end with a linebreak.\r\n");
}
