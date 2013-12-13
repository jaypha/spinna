
module jaypha.spinna.pagebuilder.lists.column;

import std.array;
import jaypha.types;


struct Column
{
  string name;
  string label;

  string delegate(ref Column, strstr) itemfn = null;
  string delegate(ref Column, strstr, string) linkfn = null;

  @property header() { return label; }

  this(string n, string l, string delegate(ref Column, strstr) i = null, string delegate(ref Column, strstr, string) lk = null )
  { 
    name = n;
    label = l;
    itemfn = i;
    linkfn = lk;
  }

  string content(strstr data)
  {
    string item = replace(itemfn?itemfn(this,data):data[name],"\n","<br/>");

    if (linkfn) { return linkfn(this,data,item); }
    else return item;
  }
}
