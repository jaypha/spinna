//Written in the D programming language
/*
 * Definitions for enumerated widgets.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.enumerated;

struct EnumeratedOption
{
  string label;
  string value;
}

alias EnumeratedOption SelectorOption;
alias EnumeratedOption SortOption;
