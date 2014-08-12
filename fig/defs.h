/*
 * Internal declarations and data types for the figparser.
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

#include "figparser.h"

struct fig_parse_context
{
  Fig_Record* content;
  int         err_line_no;
  int         err_column;
  char*       err_message;
  char*       err_filename;
  void*       scanr;
};

typedef struct fig_parse_context fig_parse_context;

#define MAX_FNAME_DEPTH 10
extern char* include_stack[MAX_FNAME_DEPTH];
extern int include_stack_ptr;
