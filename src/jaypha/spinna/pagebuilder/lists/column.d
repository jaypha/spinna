
module jaypha.spinna.pagebuilder.lists.column;

import std.array;
import jaypha.types;


struct Column(T = strstr)  // T must have op[](string) defined
{
  string name;
  string label;

  string delegate(ref Column!T, T) itemfn = null;
  string delegate(ref Column!T, T, string) linkfn = null;

  @property header() { return label; }

  this(string n, string l, string delegate(ref Column!T, T) i = null, string delegate(ref Column!T, T, string) lk = null )
  { 
    name = n;
    label = l;
    itemfn = i;
    linkfn = lk;
  }

  string content(T data)
  {
    string item = replace(itemfn?itemfn(this,data):data[name],"\n","<br/>");

    if (linkfn) { return linkfn(this,data,item); }
    else return item;
  }
}
