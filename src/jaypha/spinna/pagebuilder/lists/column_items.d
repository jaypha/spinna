
module jaypha.spinna.pagebuilder.lists.column_items;

import jaypha.types;
import jaypha.spinna.pagebuilder.lists.column;

string yes_no_column_item(ref Column c, strstr r)
{
  return r[c.name]?"Yes":"No";
}


string create_link(string url, string p)(ref Column c, strstr r, string txt)
{
  return "<a href='"~url~"?"~p~"="~r[p]~"'>"~txt~"</a>";
}

string edit_icon_column_item(ref Column c, strstr r)
{
  return "<img class='inline-icon' src='/images/icons/inline/edit.png' alt='edit icon' title='Click to edit'/>";
}

string currency_column_item(string code)(ref Column c, strstr r)
{
  return "$"~r[c.name];
}