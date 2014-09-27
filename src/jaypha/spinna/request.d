/*
 * Server side HTTP request context
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

/*
 * RFC2965 - Cookies
 * RFC2045 - MIME headers
 */

module jaypha.spinna.request;

import jaypha.types;
import jaypha.string;
import jaypha.container.hash;
import jaypha.io.lines;
import jaypha.mime.header;
import jaypha.mime.multipart_reader;
public import jaypha.http.exception;
import jaypha.http.cookie;

import std.uri;
import std.array;
import std.algorithm;
import std.stdio;
import std.string;
import std.traits;
import std.range;

// In D2, Files in structures in associative arrays, causes a crash.

class HttpFileUpload
{
  ulong size;
  File file;
  string file_name;
  string client_name;
  MimeContentType type;
}

//-----------------------------------------------------------------------------
//
// HttpRequest
//
//-----------------------------------------------------------------------------

struct HttpRequest
{
  public strstr environment;
  public StrHash gets;
  public StrHash posts;
  public HttpCookie[string] cookies;
  public HttpFileUpload[string] files;

  public immutable(ubyte)[] raw_input;

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
  @property bool is_post() { return environment["REQUEST_METHOD"] == "POST"; }
  @property bool is_get() { return environment["REQUEST_METHOD"] == "GET"; }
  @property StrHash request() { if (is_post()) return posts; else return gets; }
}


//-----------------------------------------------------------------------------
//
// Parsing and extracting routines.
//
//-----------------------------------------------------------------------------


void prepare(IRange)(ref HttpRequest request, strstr env, IRange input)
  if (isByteRange!IRange)
{
  request.gets.clear();
  request.cookies.clear();
  request.posts.clear();
  request.files = request.files.init;
  request.raw_input = request.raw_input.init;

  try
  {
    request.environment = env;

    if ("QUERY_STRING" in env && env["QUERY_STRING"].length)
      request.gets = extract_gets(env["QUERY_STRING"]);

    if ("HTTP_COOKIE" in env)
      request.cookies = extract_cookies(env["HTTP_COOKIE"]);

    if ("CONTENT_LENGTH" in env && env["CONTENT_LENGTH"] != "0")
    {
      if ("CONTENT_TYPE" !in env)
        throw new HttpException("Missing Content-Type");
        
      auto content_type = get_mime_content_type(env["CONTENT_TYPE"]);
      if (content_type.type == "multipart/form-data")
      {
        if (!("boundary" in content_type.parameters))
          throw new HttpException("malformed Content-Type");
        parse_form!IRange(request, input, content_type.parameters["boundary"]);
      }
      else
      {
        auto a = appender!(immutable(ubyte)[])();
        input.copy(a);
        
        if (content_type.type == "application/x-www-form-urlencoded")
        {
          request.posts = extract_posts(cast(string)a.data);
        }
        else
        {
          request.raw_input = a.data;
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
/* Extract parameters from a query string.
 * According to RFC1866, the query components can be separated by either '&'
 * or ';' */

StrHash extract_gets(cstring getstr)
{
  StrHash gets;
  auto t = splitup(getstr, "&;");
  foreach (tt;t)
    extract_param(tt, gets);
  return gets;
}

//-----------------------------------------------------------------------------
// Extract parameters from a x-www-form-urlencoded string.

StrHash extract_posts(cstring poststr)
{
  StrHash posts;
  auto t = splitup(poststr, "&");
  foreach (tt;t)
    extract_param(tt, posts);
  return posts;
}

//-----------------------------------------------------------------------------

// Extract a parameter from a url encoded string.

void extract_param(cstring pair, ref StrHash p)
{
  auto r = split(pair,"=");
  auto x = decodeComponent(replace(r[0],"+"," ").idup);
  auto y = decodeComponent(replace(r[1],"+"," ").idup);
  p.add(x,y);
}

//-----------------------------------------------------------------------------

/*
 * Parses multipart/form-data form. Covered by rfcs 2045 (MIME),
 * 2183 (Content-Disposition), 2388 (form-data).
 *
 * TODO: check for unexpected end of file
 */
void parse_form(IRange)(ref HttpRequest request, IRange input, string boundary)
  if (isByteRange!IRange)
{
  auto reader = get_multipart_reader!IRange(input, boundary);

  while(!reader.empty)
  {
    MimeContentType ct;
    MimeContentDisposition disp;

    auto part_reader = reader.front; // part_reader is a MimeEntityReader

    /* Look for content-type and disposition in the header */
    foreach (header; part_reader.headers)
    {
      switch (header.name)
      {
        case "Content-Type":
          ct = get_mime_content_type(header.field_body);
          break;
        case "Content-Disposition":
          disp = get_mime_content_disposition(header.field_body);
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
      request.files[name] = new HttpFileUpload();
      request.files[name].client_name = disp.parameters["filename"];
      request.files[name].file = File.tmpfile();
      part_reader.content.copy(request.files[name].file.lockingTextWriter);
      request.files[name].file.flush();
      request.files[name].size = request.files[name].file.size;
      request.files[name].type = ct;
    }
    else
    {
      auto data = appender!(immutable(ubyte[]))();
      part_reader.content.copy(data);
      request.posts.add(name, cast(string)(data.data));
    }
    reader.popFront();
  }
}

//---------------------------------------------------------------------------

debug(http_request)
{
  import std.stdio;
  import std.range;
  import std.conv;

  void main()
  {
    string[string] env;
    string txt = "r=5&q=10&t=3+12&n=8";

    env["QUERY_STRING"] = "a=5&b=10;j=3+12&a=8";
    env["REQUEST_METHOD"] = "POST";
    env["CONTENT_LENGTH"] = to!string(txt.length);
    env["CONTENT_TYPE"] = "application/x-www-form-urlencoded";
    ubyte[] bytes = cast(ubyte[])txt.dup;
    auto r1 = inputRangeObject(bytes);
    //auto context = new Http_Context!(typeof(r1))(env, r1);
    HttpRequest request;

    request.prepare(env,r1);
    writeln(request.method());
    request.gets.dump(stdout.lockingTextWriter);
    request.posts.dump(stdout.lockingTextWriter);
  }
}