
module console;

import jaypha.spinna.main.console;

import std.conv;


void errorFn(ulong code, string message, WriteOut err)
{
  err.put(cast(immutable(ubyte)[])("Spinna Error: "~to!string(code)~": message\n"));
  err.put(cast(immutable(ubyte)[])(message~"\n"));
}

bool preProcess()
{
  return true;
}

void postProcess()
{
}

static this()
{
  consoleSpinnaRequestProcessor.errorHandler = &errorFn;
}
