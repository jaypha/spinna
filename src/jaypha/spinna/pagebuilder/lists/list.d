//Written in the D programming language
/*
 * Interface for list components
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.lists.list;

public import jaypha.spinna.pagebuilder.component;

interface ListComponent : Component
{
  @property void start(size_t);
  @property void limit(size_t);
  @property ulong length();
}

