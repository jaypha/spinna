module jaypha.spinna.pagebuilder.widgets.markitup;

public import jaypha.spinna.pagebuilder.widgets.text;

class MarkItUpWidget : TextWidget
{
  override void copy(TextOutputStream output)
  {
    form.doc.page_head.script_files["markitup"] = "/thirdparty/markitup/jquery.markitup.js";
    form.doc.page_head.script_files["markitupset"] = "/thirdparty/markitup/sets/default/set.js";
    form.doc.page_head.css_files["markitup"] = "/thirdparty/markitup/skins/markitup/style.css";
    form.doc.page_head.css_files["markitupset"] = "/thirdparty/markitup/sets/default/style.css";
    form.doc.page_head.add_script("$('"~id~").markItUp(mySettings);", true);
    super.copy(output);
  }
}
