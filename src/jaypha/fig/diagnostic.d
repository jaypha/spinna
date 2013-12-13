/*
 * Dumps a fig tree to an output range.
 *
 * Part of the Fig configuration language project.
 *
 * Copyright Jaypha 2013.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.fig.diagnostic;

import jaypha.fig.value;

import io = jaypha.io.print;

void dump_figs(Writer)(Writer w, Figtree figs)
{
  foreach (s,f; figs)
  {
    io.println(w,"-- record --");
    io.printfln(w,"Name: '%s'", s);
    w.dump_fig(f);
  }
}

void dump_fig(Writer)(Writer w, Fig_Value f)
{
  io.println(w,"Type: ",f.type());

  switch(f.type())
  {
    case Fig_Type.Bool:  io.println(w,"Bool - ",(f.get_bool()?'T':'F'));  break;
    case Fig_Type.Int:   io.println(w,"Int - ",f.get_int());   break;
    case Fig_Type.Float: io.println(w,"Float - ",f.get_float()); break;
    case Fig_Type.Str:   io.printfln(w,"Str - '%s'",f.get_string()); break;
    case Fig_Type.List:  io.println(w,"List");  break;
    case Fig_Type.Array: io.println(w,"Array"); break;
    default: io.println(w,"Unknown ", f.type());
  }
  if (f.type() == Fig_Type.List)
  {
    io.println(w,"---- start list -----");
    w.dump_figs(f.get_list());
    io.println(w,"---- end list -------");
  }
  else if (f.type() == Fig_Type.Array)
  {
    io.println(w,"---- start array -----");
    foreach (fig; f.get_array())
    {
      w.dump_fig(fig);
    }
    io.println(w,"---- end array -------");
  }
}
