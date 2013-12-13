
module jaypha.spinna.modules.menu;
import jaypha.spinna.pagebuilder.component;

struct MenuItem
{
  enum LinkType { link, script };
  string label;
  string link;
  LinkType type;
  MenuItem[] sub_menu;
}

class MenuComponent(string S) : Component
{
  MenuItem[] menu;

  this(MenuItem[] m) { menu = m; }

  mixin TemplateCopy!S;
}
