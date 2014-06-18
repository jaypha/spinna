
module jaypha.spinna.pagebuilder.lists.data_source;

public import jaypha.spinna.pagebuilder.component;

interface DataSource
{
  @property ulong size(); // Size of source without applying limits.

  void set_start(ulong start);
  void set_limit(ulong limit);

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

