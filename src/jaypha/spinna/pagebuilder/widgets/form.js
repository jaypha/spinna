/*
 * Form submission functions for use with Spinna widgets.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

//----------------------------------------------------------------------------
// validate form using spinna widgets
// 

function form_validate(form_id, invalid_callback)
{
  var invalid_widgets = [];

  $(".widget", "#"+form_id).each(function()
  {
    var wgt = $(this).data("widget");

    if (!wgt.validate())
    {
      invalid_widgets.push(wgt);
    }
  });

  if (invalid_widgets.length)
  {
    invalid_callback(form_id,invalid_widgets);
    return false;
  }
  return true;
}

//----------------------------------------------------------------------------
// Default callback for form validation failure.
// 

function form_validate_fail(form_id, invalid_widgets)
{
  var messages = [];
  for (x in invalid_widgets)
    messages.push(invalid_widgets[x].label+": "+invalid_widgets[x].msg);

  //alert(messages.join("\n"));
  $("#message-dialog .dialog-content").html("<h4>Form submission is not acceptable</h4>"+messages.join("<br/>"));
  $("#message-dialog").jqmShow();
}

//----------------------------------------------------------------------------
// Set up forms to use validation.

$(function()
{
  $("form").submit(function(event) { return form_validate($(this).attr('id'),form_validate_fail); });
});
