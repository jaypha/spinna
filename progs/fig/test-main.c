/*
 * Test program for the Fig parser.
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
#include "assert.h"
#include <stdio.h>

/*--------------------------------------------------------------------------*/

void print_value(Fig_Record *output)
{
  printf("-- record --\n");
  printf("Name: '%s'\n", output->name != NULL?output->name: "");
  printf("Type: ");
  switch(output->type)
  {
    case Bool:  printf("Bool - %c\n",(output->value.lval?'T':'F'));  break;
    case Int:   printf("Int - %ld\n",output->value.lval);   break;
    case Float: printf("Float - %f\n",output->value.dval); break;
    case Str:   printf("Str\n");   break;
    case List:  printf("List\n");  break;
    case Array: printf("Array\n"); break;
    default: printf("Unknown %d\n", output->type);
  }
  if (output->type == List)
  {
    printf("---- start list -----\n");
    if (output->value.list != NULL)
      print_value(output->value.list);
    printf("---- end list -------\n");
  }
  else if (output->type == Array)
  {
    printf("---- start array -----\n");
    assert(output->value.list != NULL);
    print_value(output->value.list);
    printf("---- end array -------\n");
  }
  else
  {
    assert(output->strval != NULL);
    printf("original value: '%s'\n", output->strval);
  }

  if (output->next != NULL)
  {
    printf("-- next ");
    print_value(output->next);
  }
}

/*--------------------------------------------------------------------------*/

int main(int argc, char** argv)
{
  Fig_Context* context = read_figfile(argv[1]);
  assert(context != NULL);
  
  if (context->content == NULL)
  {
    printf("No content\n");
    if (context->err_message != NULL)
      printf("Error: line %d, column %d: %s\n", context->err_line_no, context->err_column, context->err_message);
  }
  else
  {
    print_value(context->content);
  }
  free_fig_context(context);
}

/*--------------------------------------------------------------------------*/
