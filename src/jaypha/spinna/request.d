//Written in the D programming language
/*
 * Server side HTTP request.
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/*
 * RFC2965 - Cookies
 * RFC2045 - MIME headers
 */

module jaypha.spinna.request;

import jaypha.types;
import jaypha.string;
import jaypha.range;
import jaypha.container.hash;
import jaypha.io.lines;

public import jaypha.inet.http.exception;
import jaypha.inet.http.cookie;

import jaypha.inet.mime.reading;
import jaypha.inet.mime.contenttype;
import jaypha.inet.mime.contentdisposition;

import std.uri;
import std.array;
import std.algorithm;
import std.stdio;
import std.string;
import std.traits;
import std.range;
import std.conv;

// In D2, Files in structures in associative arrays, causes a crash.

class HttpFileUpload
{
  ulong size;
  File file;
  string fileName;
  MimeContentType type;
  deprecated @property string clientName() { return fileName; }

  this() { file = File.tmpfile(); }
  ~this() { file.close(); }
}

alias Hash!HttpFileUpload FileHash;

//-----------------------------------------------------------------------------
struct HttpRequest
//-----------------------------------------------------------------------------
{
  strstr environment;

  StrHash gets;
  StrHash posts;
  @property StrHash request() { if (isPost()) return posts; else return gets; }

  HttpCookie[string] cookies;
  FileHash files;

  ByteArray rawInput;

  //---------------------------------------------------------------------------

  @property string uri() { return environment["REQUEST_URI"]; }

  @property string path()
  {
    if ("SCRIPT_URL" in environment)
      return environment["SCRIPT_URL"];
    else
      return environment["SCRIPT_NAME"];
  }

  //---------------------------------------------------------------------------

  @property string referer()
  {
    if ("HTTP_REFERER" in environment) return environment["HTTP_REFERER"];
    else return null;
  }

  //---------------------------------------------------------------------------

  @property string method() { return environment["REQUEST_METHOD"]; }
  @property bool isPost() { return environment["REQUEST_METHOD"] == "POST"; }
  @property bool isGet() { return environment["REQUEST_METHOD"] == "GET"; }

  void clear()
  {
    gets.clear();
    posts.clear();
    cookies = cookies.init;
    files.clear();
    rawInput = rawInput.init;
    environment = environment.init;
  }
}


//-----------------------------------------------------------------------------
// Parsing and extracting routines.

void prepare(IRange)(ref HttpRequest request, strstr env, IRange input)
  if (isByteRange!IRange)
{
  try
  {
    request.environment = env;

    if ("QUERY_STRING" in env && env["QUERY_STRING"].length)
      request.gets = extractGets(env["QUERY_STRING"]);

    if ("HTTP_COOKIE" in env)
      request.cookies = extractCookies(env["HTTP_COOKIE"]);

    if ("CONTENT_LENGTH" in env && env["CONTENT_LENGTH"] != "0")
    {
      if ("CONTENT_TYPE" !in env)
        throw new HttpException("Missing Content-Type");
        
      auto contentType = extractMimeContentType(env["CONTENT_TYPE"]);

      // Not all inputs terminate after the content has ended, so we 
      // artificially end it.
      auto t = take(input, to!(size_t)(env["CONTENT_LENGTH"]));

      if (contentType.mimeType == "multipart/form-data")
      {
        if (!("boundary" in contentType.parameters))
          throw new HttpException("malformed Content-Type");
        parseForm(request, t, contentType.parameters["boundary"]);
      }
      else
      {
        auto a = appender!(immutable(ubyte)[])();
        t.copy(a);
        
        if (contentType.mimeType == "application/x-www-form-urlencoded")
        {
          request.posts = extractPosts(cast(string)a.data);
        }
        else
        {
          request.rawInput = a.data;
        }
      }
    }
  }
  catch(Exception e)
  {
    throw new HttpException(e.msg);
  }
}

//-----------------------------------------------------------------------------
// Extract parameters from a query string.

StrHash extractGets(string s)
{
  StrHash gets;
  auto pairs = splitter(s, '&');
  foreach (pair; pairs)
    extractParam(pair, gets);
  return gets;
}

//-----------------------------------------------------------------------------
// Extract parameters from a x-www-form-urlencoded string.

StrHash extractPosts(string s)
{
  StrHash posts;
  auto pairs = splitter(s, '&');
  foreach (pair;pairs)
    extractParam(pair, posts);
  return posts;
}

//-----------------------------------------------------------------------------
// Extract a parameter from a url encoded string.

void extractParam(string pair, ref StrHash p)
{
  // TODO should split only once.
  auto r = split(pair,'=');
  auto x = decodeComponent(replace(r[0],"+"," ").idup);
  string y;
  if (r.length > 1)
    y = decodeComponent(replace(r[1],"+"," ").idup);
  else
    y = null;
  p.add(x,y);
}

//-----------------------------------------------------------------------------

/*
 * Parses multipart/form-data form. Covered by rfcs 2045 (MIME),
 * 2183 (Content-Disposition), 2388 (form-data).
 *
 * TODO: check for unexpected end of file
 */
void parseForm(IRange)(ref HttpRequest request, IRange input, string boundary)
  if (isByteRange!IRange)
{
  auto reader = mimeMultipartReader!IRange(input, boundary);

  while(!reader.empty)
  {
    MimeContentType ct;
    MimeContentDisposition disp;

    auto partReader = reader.front; // partReader is a MimeEntityReader

    /* Look for content type and disposition in the header */
    foreach (header; partReader.headers)
    {
      switch (header.name)
      {
        case "Content-Type":
          ct = extractMimeContentType(header.fieldBody);
          break;
        case "Content-Disposition":
          disp = extractMimeContentDisposition(header.fieldBody);
          break;
        default:
          ; // ignore all others. 
      }
    }

    if (disp.type != "form-data")
      throw new HttpException("malformed Content-Disposition, wrong value '"~disp.type~"'");
    if (!("name" in disp.parameters))
      throw new HttpException("malformed Content-Disposition, no name");

    string name = disp.parameters["name"];

    if ("filename" in disp.parameters)
    {
      auto upload = new HttpFileUpload();
      
      upload.fileName = disp.parameters["filename"];
      //upload.file.rawWrite(array(partReader.content));
      foreach (chunk; partReader.content.byChunk(4096))
        upload.file.rawWrite(array(chunk));
      //partReader.content.copy(upload.file.lockingTextWriter);
      upload.file.flush();
      upload.file.rewind();
      upload.size = upload.file.size;
      upload.type = ct;
      request.files.add(name, upload);
    }
    else
    {
      auto data = appender!(ByteArray)();
      partReader.content.copy(data);
      request.posts.add(name, cast(string)(data.data));
    }
    reader.popFront();
  }
}

//---------------------------------------------------------------------------
