/*
 * Base class for dynamic widgets
 */
 
module jaypha.spinna.pagebuilder.widgets.widget;

public import jaypha.spinna.pagebuilder.htmlelement;
public import jaypha.spinna.pagebuilder.htmlform;


 
abstract class Widget : HtmlElement
{
  string label;
  bool required;

  @property { string value(); void value(string); }
  @property { string name(); void name(string); }

  HtmlForm form;

  //bool validate(string value);

  this(HtmlForm _form, string _name, string _tag_name = "div")
  {
    super(_tag_name);
    form = _form;
    name = _name;
    add_class("widget");
    if (!(form is null))
      id = form.id~"-"~name;
    else
      id = name;
  }

  override void copy(TextOutputStream output)
  {
    if (!(form is null) && name in form.values)
      value = form.values[name];
    super.copy(output);
  }
}

class LabelWidget : Widget
{
  @property { override string value() { return null; } override void value(string) {}; }
  @property { override string name() { return null; } override void name(string) {}; }

  this(string _label)
  {
    super(null, null);
    label = _label;
  }

  override void copy(TextOutputStream output)
  {
    if (!(form is null) && name in form.values)
      value = form.values[name];
    super.copy(output);
  }
}

class WidgetComponent(string tpl = "jaypha/spinna/pagebuilder/widgets/default_widgets.tpl") : Component
{
  Widget[] widgets;

  mixin TemplateCopy!tpl;
}

/+
Widget create_widget(string widget_type)
{
  switch (widget_type)
  {
    case "string":
      return new StringWidget();
    default
      throw new Exception("Unknown widget: "~widget_type);
  }
}


Widget get_widget(Variant[string] metadata)
{
  ensure("name" in metadata);
  ensure("type" in metadata);
  auto w = create_widget(metadata["type"].get!string());
  w.name = metadata["name"].get!string();
  w.label = def["label"].get!string();

  //w.set_constraints(metadata["constraints"].get!strstr());
  //w.set_properties(metadata["properties"].get!strstr());
}


Widget[] get_widgets(Htmlform _form, Variant[string][] metadata)
{
  auto widgets = appender!(Widget[]);

  foreach (def; metadata)
  {
    widgets.put(get_widget(def));
  }
  return widgets.data;
}



/+
class TemplateComponent(string tpl, S...) : Component
{
  foreach (i,T;S)
    mixin(typeid(T)~" a"~i);
  
  override void copy(TextOutputStream output)
  {
    mixin(TemplateComponent!tpl);
  }
}

template HtmlWidgetName()
{
  @property
  {
    string name() { return attributes["name"]; }
    void name(string v) { attributes["name"] = v; }
  }
}


+/
+/
