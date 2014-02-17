
module jaypha.spinna.modules.estore.item_cart;

import jaypha.spinna.session;

struct ItemCart
{
  @property empty() { return items.length == 0; }

 // void clear() { items = cast(ulong[ulong])[]; }

  //---------------------------------------------------------------------------

  void load(ref Session s)
  {
    items = s["itemcart"].get!(ulong[ulong])("items");
  }

  void save(ref Session s)
  {
    s["itemcart"].set("items",items);
  }

  //---------------------------------------------------------------------------

  @property ulong size()
  {
    ulong qty = 0;
    foreach (i;items)
      qty += i;
    return qty;
  }

  //---------------------------------------------------------------------------

  ulong opIndex(ulong i) { return (i in items?items[i]:0); }

  ulong opIndexAssign(ulong v, ulong i)
  {
    if (v == 0) items.remove(i);
    else items[i] = v; 
    return v;
  }

  ulong opIndexOpAssign(string op)(ulong v, ulong i)
  {
    ulong x = opIndex(i);
    mixin("x"~op~"=v;");
    return opIndexAssign(x,i);
  }

  int opApply(int delegate(ulong i, ref ulong j) dg)
  {
    int result = 0;
    foreach (a,ref ulong b; items)
    {
      result = dg(a,b);
      if (result) break;
    }
    return result;
  }

  //---------------------------------------------------------------------------

  private:
    ulong[ulong] items;
 
}
