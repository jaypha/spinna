//Written in the D programming language
/*
 * Test module for dialog widgets.
 *
 * Copyhright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module testdialog;

import jaypha.spinna.pagebuilder.widgets.dialogbox;

import jaypha.spinna.pagebuilder.htmlelement;

import std.stdio;
import std.range;

static assert(isOutputRange!(File.LockingTextWriter,dchar));

void main()
{
  auto dlg = new DialogBox!("jaypha/spinna/pagebuilder/widgets/dialogdefault.tpl")("Dialog Test");
  dlg.add("hello");

  auto o = stdout.lockingTextWriter;
  dlg.copy(new TextOutputStream(outputRangeStream(o)));
}
