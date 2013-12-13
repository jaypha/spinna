module jaypha.spinna.pagebuilder.widgets.ckfinder;

public import jaypha.spinna.pagebuilder.widgets.string_widget;


class CKFinderWidget : StringWidget
{
  this(HtmlForm _form, string _name)
  {
    super(_form, _name);
    add_class("ckfinder");
  }

  override void copy(TextOutputStream output)
  {
    form.doc.page_head.script_files["ckfinder"] = "/thirdparty/ckfinder/ckfinder.js";
    super.copy(output);
		output.print("<input type='button' class='button' value='Browse Server' onclick='use_ckfinder( \"Images:/\", \""~id~"\");'/>";
  }
}
