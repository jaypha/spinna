

module jaypha.i18n.lookup;

public import jaypha.i18n.lookup_id;

S lookup(S)(LookupId id)
  if (isSomeString!S)
{
  return value[(uint) id];
}
