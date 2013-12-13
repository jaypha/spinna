module jaypha.spinna.response;

import std.array;
import std.range;
import std.conv;
import std.algorithm;
import std.datetime;
import std.string;

alias immutable(ubyte)[] ByteArray;

immutable string basic_error_response = "Content-Type: text/plain\r\nStatus: 500 Internal Error\r\n\r\n";

struct HttpResponse
{
  ByteArray entity;

  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // HttpResponse as an input range
  //---------------------------------------------------------------------------

  uint step = 0;

  @property bool empty() { return step >=3; }

  ByteArray front()
  {
    if (step == 0)
    {
      if (!response_start)
        response_start = get_response_start();

      return cast(ByteArray) response_start;
    }
    else if (step == 1)
    {
      return cast(ByteArray) (headers.data ~ "\r\n");
    }
    else if (step == 2)
      return entity;
    else
      return null;
  }
  void popFront()
  {
    ++step;
  }

  string response_start = null;

  string get_response_start()
  {
    auto b = appender!string();
    b.put("Content-Type: ");
    b.put(mime_type);
    b.put("\r\n");
    b.put("Status: ");
    b.put(to!string(http_status));
    if (http_status_msg !is null)
    {
      b.put(" ");
      b.put(http_status_msg);
    }
    b.put("\r\n");
    return b.data;
  }

  //---------------------------------------------------------------------------
  // Response headers.
  //---------------------------------------------------------------------------

  void status(int http_status, string msg = null)
  {
    this.http_status = http_status;
    this.http_status_msg = msg.dup;
  }

  //---------------------------------------------------------------------------

  void set_session_cookie(string name, string value, string path = "/", string domain = null)
  {
    headers.put("Set-Cookie: ");
    headers.put(name);
    headers.put("=");
    headers.put(value);
    headers.put(";");
    if (path !is null) { headers.put(" path="); headers.put(path); headers.put(";"); }
    if (domain !is null) { headers.put(" domain="); headers.put(domain); headers.put(";"); }
    headers.put("\r\n");
  }

  //---------------------------------------------------------------------------

  void header(string name, const string value)
  {
    headers.put(name);
    headers.put(": ");
    headers.put(value);
    headers.put("\r\n");
  }

  //---------------------------------------------------------------------------

  void content_type(string type)
  {
    mime_type = type;
  }

  //---------------------------------------------------------------------------
  // Ensures that the page will not be cached

  void no_cache()
  {
    // Date in the past
    header("Expires", "Mon, 26 Jul 1997 05:00:00 GMT");

    // always modified
    auto d = Clock.currTime(UTC());
    header("Last-Modified",format("%d, %d %s %d %02d:%02d:%02d GMT", d.dayOfWeek,d.day, d.month, d.year, d.hour, d.minute,d.second));

    // HTTP/1.1
    header("Cache-Control", "no-store, no-cache, must-revalidate");
    header("Cache-Control", "post-check=0, pre-check=0");

    // HTTP/1.0
    //header("Pragma", "no-cache");
  }

  //---------------------------------------------------------------------------

  void redirect(string url)
  {
    status(303);
    header("Location",url);
  }

  private:
    string mime_type;
    int http_status = 200;
    string http_status_msg = "OK";
    private Appender!string headers;
}

unittest
{
  import std.range;
  import std.stdio;

  auto napp = appender!ByteArray;
  HttpResponse response;

  response.entity = cast(ByteArray)("Hello Goodbye\n");

  response.content_type("text/plain");
  response.status(202, "yahoo");
  response.header("X-Content", "just");
  response.no_cache();
  response.copy(napp);

  write(cast(string)napp.data);

//  assert(napp.data == cast(ByteArray)("HTTP/1.1 202 yahoo\r\nContent-Type: text/plain\r\nX-Content: just\r\n\r\nHello Goodbye\n"));
}