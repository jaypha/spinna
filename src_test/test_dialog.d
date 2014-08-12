
module test_dialog;

import jaypha.spinna.pagebuilder.useful_stuff.dialog_box;

import jaypha.spinna.pagebuilder.htmlelement;


void dialog_test(WO)(WO wo)
{
  auto x = new DialogBox!("jaypha/spinna/pagebuilder/useful_stuff/dialog_default.tpl")("x");
  x.add("hello");

  x.copy(new TextOutputStream(output_range_stream(wo)));
}
