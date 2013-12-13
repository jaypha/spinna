
module jaypha.spinna.pagebuilder.htmlform;

import jaypha.spinna.pagebuilder.htmlelement;
import jaypha.spinna.pagebuilder.document;

import jaypha.types;
import jaypha.html.helpers;
import jaypha.algorithm;

import std.array;

class HtmlForm : HtmlElement
{
  strstr hiddens;
  Document doc;

  strstr values;
  
  this(Document d, string _id, string action = null)
  {
    super("form");
    assert(_id !is null, "Trying to create a form with no ID");
    id = _id;
    doc = d;
    if (action !is null) attributes["action"] = action;
    attributes["method"] = "post";
    hiddens["formid"] = id;
  }
  
  override void copy(TextOutputStream output)
  {
    assert(doc.current_form is null, "cannot nest forms");

    doc.current_form = this;
    scope(exit) { doc.current_form = null; }

    auto composite = new Composite();
    composite.add("<div class='form-wrapper'>");

    if (content !is null)
      composite.add(content);

    composite.add("</div>");
    composite.add(meld!(hidden)(hiddens).join());
    content = composite;

    doc.page_head.add_script("widgets['"~id~"'] = [];");
    doc.page_head.add_script("$('#"~id~"').submit(function(event) { return form_validate('"~id~"',no_valid); });",true);

    super.copy(output);

    // We delete the form session at this point on the basis that, if a person
    // reloads the form, they probably want to cleanse it.

    //if (Global.session.has("forms"~id));
    //  Global.session.remove("forms"~id);
  }
}

  /*
   * Checks to see if the HTTP request is a form submission of the correct type.
   */
  /+
  static void check_form_submission(HttpContext context, string formid)
  {
    // Check that this file is called by the appropriate webform.

    // 1. Submission must be post
    
    if (!context.isPost())
      throw new HttpException("Form submissions must be POST. Is "~context.method);

    // 2. The form identifier needs to be set

    auto id = ("formid" in context.posts);
    if (!id)
      throw new HttpException("Form submissions must include a formid");

    if ((*id)[0] != formid)
      throw new HttpException(Format("Wrong form '{}' vs '{}'",(*id)[0], formid));

    // 3. There needs to be a referer
    
    if (context.referer is null)
      throw new HttpException("No referer for form submission");
  }
  +/
