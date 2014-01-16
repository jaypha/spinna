
module jaypha.spinna.modules.invoicing.gst;

import jaypha.decimal;


dec2 get_gst_from_full(dec2 amount) { return amount/11; }
dec2 get_gst_from_sans(dec2 amount) { return amount/10; }
dec2 less_gst(dec2 amount) { return amount - get_gst_from_full(amount); }
dec2 plus_gst(dec2 amount) { return amount + get_gst_from_sans(amount); }


unittest
{
  dec2 base = 11;

  assert(get_gst_from_full(base) == 1);
  assert(get_gst_from_sans(base) == 1.1);

  assert(less_gst(base) == 10);
  assert(plus_gst(base) == 12.1);
}