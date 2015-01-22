// Written in the D programming language.

module pages;

import jaypha.spinna.pagebuilder.document;
import jaypha.spinna.global;

import jaypha.spinna.json;
import std.array;

//import jaypha.spinna.pagebuilder.widgets.icon;
//import jaypha.spinna.pagebuilder.widgets.icon_button;
//import jaypha.spinna.pagebuilder.widgets.wide_button;
//import jaypha.spinna.pagebuilder.widgets.toolbar_ex;
import jaypha.spinna.pagebuilder.widgets.tabbed;

void getHome()
{
  response.entity ~= cast(ByteArray)"This page constructed directly.\n\n";
  response.entity ~= cast(ByteArray)"Hello World!\n";
}

void getHtml()
{
  auto doc = new Document("home-page");
  doc.docBody.addClass("special");

  doc.docBody.put("<h1>This page constructed using the HTML Document Builder.</h1>");

  auto hw = new HtmlElement("p");
  hw.cssStyles["color"] = "red";
  hw.put("Hello World!");
  doc.docBody.put(hw);

  doc.copy(response);
}

void getJson()
{
  auto ret = JSONValue
    (
      [
        "success" : JSONValue(true),
        "message" : JSONValue("This page constructed using the JSON Document Builder"),
        "hello_world" : JSONValue("Hello World!")
      ]
    );

  ret.copy(response);
}

/*
void get_icon()
{
  auto doc = new Document("home-page", ["icons"]);
  doc.docHead.addScriptFile("/src/jaypha/spinna/pagebuilder/widgets/icon.js");
  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/icon.scss");

  doc.docBody.put(new Icon("Dial",32));
  transfer(doc, response, false);
}

void get_icon_btn()
{
  auto doc = new Document("home-page", ["icon-btns"]);
  doc.docHead.useJquery = true;
  doc.docHead.addScriptFile("/src/jaypha/spinna/pagebuilder/widgets/icon.js");
  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/icon.scss");

  doc.docHead.addScriptFile("/src/jaypha/spinna/pagebuilder/widgets/icon_button.js");
  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/icon_button.scss");

  auto btn = new IconButton();
  btn.icon = new Icon("Navigation",32);
  btn.label = "Nav";
  //btn.script = "alert('pressed')";
  
  doc.docBody.put(btn);
  transfer(doc, response, false);
}


void get_toolbar()
{
  auto doc = new Document("home-page", ["icon-btn-row"]);
  doc.docHead.use_jquery = true;
  doc.docHead.addScriptFile("/src/jaypha/spinna/pagebuilder/widgets/icon.js");
  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/icon.scss");

  doc.docHead.addScriptFile("/src/jaypha/spinna/pagebuilder/widgets/icon_button.js");
  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/icon_button.scss");

  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/toolbar.scss");

  doc.docHead.add_script("$('.toolbar .inner').equalise();", true);
  auto toolbar = new Toolbar();
  toolbar.groups.length = 1;

  auto btn = new IconButton("nav");
  btn.icon = new Icon("Navigation",32);
  btn.label = "Navigate Website";
  btn.script = "alert('pressed')";
  toolbar.groups[0].components ~= btn;

  btn = new IconButton("phone");
  btn.icon = new Icon("Dial",32);
  btn.label = "Phone";
  btn.link = "/";
  toolbar.groups[0].components ~= btn;

  btn = new IconButton("mail");
  btn.icon = new Icon("Mail",32);
  btn.label = "Mail";
  btn.link = "/";
  toolbar.groups[0].components ~= btn;
  
  doc.docBody.put(toolbar);
  transfer(doc, response, false);
}

void get_widebutton()
{
  auto doc = new Document("home-page", ["icon-btn-row"]);
  doc.docHead.use_jquery = true;
  doc.docHead.addScriptFile("/src/jaypha/spinna/pagebuilder/widgets/icon.js");
  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/icon.scss");

  doc.docHead.addScriptFile("/src/jaypha/spinna/pagebuilder/widgets/icon_button.js");
  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/icon_button.scss");

  doc.docHead.addScriptFile("/src/jaypha/spinna/pagebuilder/widgets/wide_button.js");
  doc.docHead.addCssFile("/src/jaypha/spinna/pagebuilder/widgets/wide_button.css");

  auto btn = new WideButton("x");
  btn.left = new Icon("Navigation",32);
  btn.link = "/";
  btn.put("Press This");
  btn.css_styles["width"] = "500px";
  doc.docBody.put(btn);

  btn = new WideButton();
  btn.left = new Icon("Dial",32);
  btn.put("Not available");
  btn.css_styles["text-align"] = "center";
  btn.css_styles["width"] = "500px";
  doc.docBody.put(btn);

  btn = new WideButton();
  btn.addClass("washout");
  btn.right = new Icon("Dial",32);
  btn.put("Click");
  btn.css_styles["text-align"] = "center";
  btn.css_styles["width"] = "500px";
  btn.script = "alert('pressed');";
  doc.docBody.put(btn);

  transfer(doc, response, false);
}


void get_tabbed()
{
  auto doc = new Document("home-page", ["tabbed"]);
  doc.docHead.useJquery = true;
  doc.docHead.addScriptFile("/scripts/tabbed.js");

  doc.docHead.addCssFile("/css/tabbed.css");

  auto tabbed = new Tabbed("tabby");
  auto p = tabbed.addPanel("Page 1");
  p.add("Page 1 content");
  p = tabbed.addPanel("Page 2");
  p.add("Page 2 content");
  p = tabbed.addPanel("Page 3");
  p.add("Page 3 content");
  doc.docBody.put(tabbed);
  transfer(doc, response, false);

}

*/
