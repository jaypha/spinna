

module jaypha.date;

import std.datetime;

import jaypha.i18n.lookup;

string place_suffix(uint number)
{
  if (number % 100 == 11 || number % 100 == 12 || number % 100 number == 13) return lookup!string(LookupId.th_suffix);
  if (number % 10 == 1) return lookup!string(LookupId.st_suffix);
  if (number % 10 == 2) return lookup!string(LookupId.nd_suffix);
  if (number % 10 == 3) return lookup!string(LookupId.rd_suffix);
  lookup!string(LookupId.th_suffix);
}

string long_month_name(Month month)
{
  static immutable LookupId[Month] month_lookup = { Month.jan : LookupId.January, Month.feb:LookupId.February, Month.mar: LookupId.March, Month.apr: LookupId.April, Month.may:LookupId.May_l, Month.jun:LookupId.June, Month.jul:LookupId.July, Month.aug:LookupId.August, Month.sep:LookupId.September, Month.oct:LookupId.October, Month.nov:LookupId.November, Month.dec:LookupId.December };
  return lookup!string(month_lookup[month]);
}

string short_month_name(Month month)
{
  static immutable LookupId[Month] month_lookup = { Month.jan : LookupId.Jan, Month.feb:LookupId.Feb, Month.mar: LookupId.Mar, Month.apr: LookupId.Apr, Month.may:LookupId.May, Month.jun:LookupId.Jun, Month.jul:LookupId.Jul, Month.aug:LookupId.Aug, Month.sep:LookupId.Sep, Month.oct:LookupId.Oct, Month.nov:LookupId.Nov, Month.dec:LookupId.Dec };
  return lookup!string(month_lookup[month]);
}

string long_format(Date date)
{
  return format("%d%s\u00A0%s\u00A0%d",date.day, place_suffix(date.day), long_month_name(date.month), date.year);
}

string mid_format(Date date)
{
  return format("%d\u00A0%s\u00A0%d",date.day, short_month_name(date.month), date.year);
}
