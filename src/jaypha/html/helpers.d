

module jaypha.html.helpers;

import jaypha.html.entity;

import std.array;

string hidden(string name, string value)
{
  return "<input type='hidden' name='"~name~"' value='"~encode_special(value)~"'/>";
}

//-----------------------------------------------------------------------------

string truncated_text(string text, uint length)
{
  if (text.length <= length) return text;
  else
  {
    return "<span title='"~text~"'>"~text[0..length-2]~"..</span>";
  }
}

string nltobr(string text)
{
  return replace(text, "\n", "<br>");
}

//-----------------------------------------------------------------------------

/+

char[] mini_form(char[] id, char[] contents, char[] action)
{
  return Format
  (
    "<form id='{}' style='display:inline' action='{}' method='post'>{}{}</form>",
    hidden("formid", id),
    contents
  );
}

//-----------------------------------------------------------------------------

char[] javascript(char[] script)
{
  return Format("<script type='text/javascript'>\n<!--\n{}\n//-->\n</script>", script);
}

//-----------------------------------------------------------------------------

char[] gap(float ems, char[] clear = "both")
{
  char[] s = Format("<div style='height:{}em;", ems);
  if (!(clear is null))
  {
    assert(clear=="left" || clear=="right" || clear=="both");
    s ~= "clear:"~clear~";";
  }
  s ~= "'></div>";
  return s;
}

//-----------------------------------------------------------------------------

char[] required(char[] css_class = "form-required")
{
  return "<span class='"~css_class~"'>*</span> denotes required field";
}

//-----------------------------------------------------------------------------

char[] clear(char[] clear = "both")
{
  assert(clear=="left" || clear=="right" || clear=="both");

  return "<div style='clear: "~clear~"'></div>";
}

//-----------------------------------------------------------------------------

char[] h1(char[] content) { return "<h1>"~content~"</h1>"; }
char[] h2(char[] content) { return "<h2>"~content~"</h2>"; }
char[] h3(char[] content) { return "<h3>"~content~"</h3>"; }
char[] h4(char[] content) { return "<h4>"~content~"</h4>"; }
char[] p(char[] content) { return "<p>"~content~"</p>"; }
char[] b(char[] content) { return "<b>"~content~"</b>"; }
char[] i(char[] content) { return "<i>"~content~"</i>"; }

//-----------------------------------------------------------------------------

char[] image(char[] src, char[] alt="", char[] cssClass=null)
{
  if (cssClass is null)
    return Format("<img src='{}' alt='{}' title='{}'/>", src, alt, alt);
  else
    return Format("<img src='{}' alt='{}' title='{}' class='{}'/>", src, alt, alt, cssClass);
}

//-----------------------------------------------------------------------------

char[] link(char[] link, char[] label=null, char[] tooltip=null)
{
  return Format
  (
    "<a href='{}'{}>{}</a>",
    toEntity(link),
    (tooltip is null)?"":Format(" title='{}'",toEntity(tooltip)),
    (label?label:toEntity(link))
  );
}

//-----------------------------------------------------------------------------

HtmlElement linkElement(char[] link, char[] label=null, char[] tooltip=null)
{
  auto e = new HtmlElement("a");
  e.attributes["href"] = link;
  if (tooltip) e.attributes["title"] = tooltip;
  e.content = (label?label:toEntity(link));
  return e;
}

//-----------------------------------------------------------------------------

char[] hidden(char[] name, char[] value, char[] id=null)
{
  if (id is null)
    return Format("<input type='hidden' name='{}' value='{}'/>",name, toEntity(value));
  else
    return Format("<input type='hidden' name='{}' value='{}' id='{}'/>",name, toEntity(value), id);
  
}

//-----------------------------------------------------------------------------

public static char[] nospamMailto = "&#x6d;&#x61;&#105;&#108;&#116;&#111;&#x3a;";

char[] email_link(char[] email, char[] label = null, bool nospam = true)
{
  if (nospam)
  {
    char[] s = nospam_email(email);
    return Format
    (
      "<a href='{}{}'>{}</a>",
      nospamMailto, s, (label?toEntity(label):s)
    );
  }
  else
    return Format
    (
      "<a href='mailto:{}'>{}</a>",
      toEntity(email), (label?toEntity(label):toEntity(email))
    );
}  

//-----------------------------------------------------------------------------


char[] nospam_email(char[] email)
{
  char[] s;
  int n;
  
  foreach (i;email)
    s ~= Format("&#{};",cast(int)i);
  return s;
}
+/