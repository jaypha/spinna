// Written in Javascript.
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

function formValidate(formId, invalidCallback)
{
  var invalidWidgets = [];

  // Call the validate method of the object attached to each widget.

  $(".widget", "#"+formId).each(function()
  {
    var wgt = $(this).data("widget");

    if (!wgt.validate())
    {
      invalidWidgets.push(wgt);
    }
  });

  if (invalidWidgets.length)
  {
    invalidCallback(formId,invalidWidgets);
    return false;
  }
  return true;
}

//----------------------------------------------------------------------------
// Default callback for form validation failure.
// 

function formValidateFail(formId, invalidWidgets)
{
  var messages = [];
  for (x in invalidWidgets)
    messages.push(invalidWidgets[x].label+": "+invalidWidgets[x].msg);

  $("#message-dialog .dialog-content").html("<h4>Form submission is not acceptable</h4>"+messages.join("<br/>"));
  $("#message-dialog").jqmShow();
}

//----------------------------------------------------------------------------
// Set up forms to use validation.

$(function()
{
  $("form").submit(function(event) { return formValidate($(this).attr('id'),formValidateFail); });
});
