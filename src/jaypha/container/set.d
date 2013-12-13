
module jaypha.container.set;

struct Set(T)
{
  this() { the_set = []; }

  void put(T t)
  {
    foreach (e; the_set)
      if (t == e) return;
    
    the_set ~= t;
  }

  ulong size() { return the_set.length; }

  auto range()
  {
    return the_set;
  }

  private:

    T[] the_set;
}
