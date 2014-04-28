/*
 * D bindings for the Fig parser.
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

module jaypha.fig.c.figparser;

//version (linux) {
//	pragma (lib, "libfig.a");
//}

extern (C):

/*--------------------------------------------------------------------------
 * Record for values and lists */

enum Fig_Type_ { Bool=0, Int, Float, Str, List, Array };

struct Fig_Record
{
  Fig_Type_ type;
  char*     name;
  char*     strval;

  union V
  {
    long               lval;
    double             dval;
    Fig_Record* list;
  }
  V value;

  Fig_Record*   next;
};

/*--------------------------------------------------------------------------
 * Structure returned by the parser. */

struct Fig_Context
{
  Fig_Record* content;
  int         err_line_no;
  int         err_column;
  char*       err_filename;
  char*       err_message;
};

/*--------------------------------------------------------------------------
 * Recommended functions to use for freeing fig structures. */

void free_fig_record(Fig_Record* record);
void free_fig_context(Fig_Context* context);


/*--------------------------------------------------------------------------
 * Reads a fig file and return a result context structure. */

Fig_Context* read_figfile(const(char)* filename);
