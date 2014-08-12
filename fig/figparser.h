/*
 * Defines the interface for the Fig parser.
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

#include <stdio.h>

/*--------------------------------------------------------------------------
 * Record for values and lists */

enum Fig_Type { Bool=0, Int, Float, Str, List, Array };

struct Fig_Record
{
  enum Fig_Type type;
  char*         name;
  char*         strval;

  union
  {
    long int           lval;
    double             dval;
    struct Fig_Record* list;
  } value;

  struct Fig_Record*   next;
};

typedef struct Fig_Record Fig_Record;

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

typedef struct Fig_Context Fig_Context;


/*--------------------------------------------------------------------------
 * Recommended functions to use for freeing fig structures. */

extern void free_fig_record(Fig_Record* record);
extern void free_fig_context(Fig_Context* context);


/*--------------------------------------------------------------------------
 * Reads a fig file and return a result context structure. */

extern Fig_Context* read_figfile(char* filename);
extern Fig_Context* read_fig(FILE* in);
