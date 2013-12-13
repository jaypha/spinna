

module jaypha.i18n.i18n;


struct i18n
{
  enum Format { UTF8, UTF16, UTF32 };

  string locale;
  Format format;
  dchar decimal_point;
  dchar thousand_sep;
  string date_format;
  Currency currency;
  string lookup_db;
}
