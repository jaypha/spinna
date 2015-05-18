//Written in the D programming language
/*
 * Server adapter for Vibe-d.
 *
 * Copyright 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

//---------------------------------------------------------------------------
// vibedRequestProcessor
//---------------------------------------------------------------------------
// This module defines a RequestProcessor instance that interfaces with
// Vibe-d.
//---------------------------------------------------------------------------

module jaypha.spinna.main.vibe;

import vibe.appmain;
import vibe.core.net;
import vibe.core.log;

import vibe.stream.wrapper;
import vibe.stream.stdio;

import jaypha.types;
import jaypha.range;
import jaypha.spinna.process;

import std.conv;

//---------------------------------------------------------------------------

alias RequestProcessor!(StreamInputRange,StreamOutputRange)
  vibedRequestProcessor;

//---------------------------------------------------------------------------

void startVibeD(string host = null)
{
  startVibeD(80, host);
}

void startVibeD(ushort port, string host = null)
{
  if (host !is null)
    listenTCP_s(8080, &processVibeD, host);
  else
    listenTCP_s(8080, &processVibeD);
	logInfo("VibeD/Spinna listening on '"~(host?host:"local")~"', port: "~to!string(port));
}

//---------------------------------------------------------------------------

void processVibeD(TCPConnection conn)
{
  strstr env;

  auto iRange = StreamInputRange(conn);
  auto oRange = StreamOutputRange(conn);
  auto eRange = StreamOutputRange(new StderrStream());

  vibedRequestProcessor.run
  (
    env,
    iRange,
    oRange,
    eRange
  );

  oRange.flush();
  eRange.flush();
}
