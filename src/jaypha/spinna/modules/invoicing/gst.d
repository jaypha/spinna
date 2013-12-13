
module jaypha.spinna.modules.invoicing.gst;

import jaypha.decimal;


Currency get_gst_from_full(Currency amount) { return amount/11; }
Currency get_gst_from_sans(Currency amount) { return amount/10; }
Currency less_gst(Currency amount) { return amount - get_gst_rom_full(amount); }
Currency with_gst(Currency amount) { return amount + get_gst_rom_sans(amount); }
