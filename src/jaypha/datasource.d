module jaypha.datasource;

interface DataSource(T = string)
{
  alias T SourceType;

  @property ulong size(); // Size of source without applying limits.

  void set_start(ulong start);
  void set_limit(ulong limit);

  void reset();

  @property T front();
  @property bool empty();
  void popFront();
}
