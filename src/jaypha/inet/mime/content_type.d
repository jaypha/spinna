//Written in the D programming language
/*
 * MIME Content-Type header.
 *
 * Copyright: Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/*
 * RFCs : 2045
 */

module jaypha.inet.mime.content_type;

import jaypha.inet.mime.reading;
import jaypha.inet.imf.writing;

import std.array;

//-----------------------------------------------------------------------------
// Content Type info

struct MimeContentType
{
  enum headerName = "Content-Type";

  string type = "text/plain";
  string[string] parameters;
}

//----------------------------------------------------------------------------
// extracts the content of a Content-Type MIME header.

MimeContentType extractMimeContentType(string s)
{
  MimeContentType ct;

  skipSpaceComment(s);
  auto type = extractToken(s);
  skipSpaceComment(s);
  if (s.cfront != '/') throw new Exception("malformed MIME header");
  s.popFront();
  skipSpaceComment(s);
  auto subType = extractToken(s); // TODO, the delimiter in this case is whitespace.
  ct.type = type~"/"~subType;
  extractMimeParams(s,ct.parameters);
  return ct;
}

//----------------------------------------------------------------------------

MimeHeader toMimeHeader(ref MimeContentType ct, bool asImf = false)
{
  auto a = appender!string;
  a.put(ct.type);
  foreach (i,v;ct.parameters)
    a.put("; "~i~"=\""~v~"\"");

  if (asImf)
    return unstructuredHeader(MimeContentType.headerName,a.data);
  else
    return MimeHeader(MimeContentType.headerName,a.data);
}

//----------------------------------------------------------------------------
