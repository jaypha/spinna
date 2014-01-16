
module jaypha.spinna.pagebuilder.lists.data_source;

public import jaypha.spinna.pagebuilder.component;

interface DataSource
{
  void set_page_size(ulong size);
  void set_page(ulong num);
  @property ulong num_pages();
  void reset();
}

interface TableSource : DataSource
{
  @property string[] headers();
  @property string[] front();
  @property bool empty();
  void popFront();
}

interface ListSource : DataSource
{
  @property string[string] front();
  @property bool empty();
  void popFront();
}

interface ListComponent : Component
{
  @property DataSource data_source();
}

