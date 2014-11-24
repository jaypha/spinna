//Written in the D programming language
/*
 * MIME Content-Disposition header.
 *
 * Copyright: Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/*
 * RFCs: 2183
 */

module jaypha.inet.mime.content_disposition;

import jaypha.inet.mime.reading;
import jaypha.inet.imf.writing;

import std.array;

//-----------------------------------------------------------------------------


struct MimeContentDisposition
{
  enum headerName = "Content-Disposition";

  string type = "inline";
  string[string] parameters;
}

//-----------------------------------------------------------------------------
// extracts the content of a Content-Disposition MIME header.
 
MimeContentDisposition extractMimeContentDisposition(string s)
{
  MimeContentDisposition cd;

  skipSpaceComment(s);
  cd.type = extractToken(s);
  skipSpaceComment(s);
  extractMimeParams(s,cd.parameters);
  return cd;
}

MimeHeader toMimeHeader(ref MimeContentDisposition cd, bool asImf = false)
{
  auto a = appender!string;
  a.put(cd.type);
  foreach (i,v;cd.parameters)
    a.put("; "~i~"=\""~v~"\"");

  if (asImf)
    return unstructuredHeader(MimeContentDisposition.headerName,a.data);
  else
    return MimeHeader(MimeContentDisposition.headerName,a.data);
}