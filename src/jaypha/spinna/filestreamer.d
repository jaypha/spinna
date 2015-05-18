//Written in the D programming language
/*
 * Special handler for streaming files.
 *
 * Copyright 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.filestreamer;

import jaypha.spinna.global;

import jaypha.inet.mime.types;
import jaypha.inet.http.exception;

import std.stdio;
import std.file;
import std.range;
import std.conv;

//----------------------------------------------------------------------------

void streamFile(string fileName)
{
  try
  {
    auto f = File(fileName,"r");
    response.stream = new FileStreamer(fileName, 4096);
    response.contentType(fileMimeType(fileName));
    response.header("Content-Length", to!string(getSize(fileName)));
  }
  catch (Exception e)
  {
    throw new HttpException("File not found",404);
  }
}

//----------------------------------------------------------------------------

// Would have preferred to use inputRangeObject, but this screws up ByChunk, which
// doesn't like being copied.

class FileStreamer : InputRange!ByteArray
{
  private File.ByChunk chunks;

  this(string fileName, size_t chunkSize = 4096) { this.chunks = File(fileName, "r").byChunk(chunkSize); }
  this(ref File file, size_t chunkSize = 4096) { this.chunks = file.byChunk(chunkSize); }
  
  @property ByteArray front() { return cast(ByteArray) chunks.front; }

  ByteArray moveFront() { scope(exit) { popFront(); } return cast(ByteArray) chunks.front; }

  void popFront() { chunks.popFront(); }

  @property bool empty() { return chunks.empty; }

  int opApply(int delegate(ByteArray) f)
  {
    int result = 0;
    foreach (buffer; chunks)
    {
      result = f(cast(ByteArray)buffer);
      if (result) break;
    }

    return result;
  }

  /// Ditto
  int opApply(int delegate(size_t, ByteArray) f)
  {
    int result = 0;
    size_t count = 0;
    foreach (buffer; chunks)
    {
      result = f(count++, cast(ByteArray)buffer);
      if (result) break;
    }
    return result;
  }
}

//----------------------------------------------------------------------------
