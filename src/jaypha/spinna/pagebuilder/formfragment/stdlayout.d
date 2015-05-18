//Written in the D programming language
/*
 * Default layout for form fragments. Should cover the vast majority of cases.
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.formfragment.stdlayout;

public import jaypha.spinna.pagebuilder.widgets.widget;

alias WidgetComponent!("jaypha/spinna/pagebuilder/formfragment/stdlayout.tpl")
  StdFormFragment;
