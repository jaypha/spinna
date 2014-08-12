module jaypha.properties;


import std.algorithm;
import std.array;
import std.string;

string[string] extract_props(string source)
{
  import std.string : splitLines, indexOf, strip;

  string[string] props;
  foreach (l; splitLines(source))
  {
    auto v = indexOf(l,'#');
    if (v != -1)
      l = l[0..v];
    auto ind = indexOf(l,':');
    if (ind >0)
    {
      auto name = strip(l[0..ind]);
      if (name.length)
        props[name] = strip(l[ind+1..$]);
    }
  }
  return props;
}
