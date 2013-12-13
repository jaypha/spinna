module jaypha.spinna.pagebuilder.widgets.markitup;

public import jaypha.spinna.pagebuilder.widgets.text;

class CKEditorWidget : TextWidget
{
  this(HtmlForm _form, string _name)
  {
    super(_form, _name);
    add_class("ckeditor");
  }

  override void copy(TextOutputStream output)
  {
    form.doc.page_head.script_files["ckeditor"] = "/thirdparty/ckeditor/ckeditor.js";
    super.copy(output);
  }
}
