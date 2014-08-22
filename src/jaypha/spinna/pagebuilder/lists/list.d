module jaypha.spinna.pagebuilder.lists.list;

public import jaypha.datasource;

interface TableSource : DataSource!(string[])
{
  @property SourceType headers();
}

alias DataSource!(string[string]) ObjSource;

public import jaypha.spinna.pagebuilder.component;

interface ListComponent : Component
{
  void set_start(ulong start);
  void set_limit(ulong limit);
}
