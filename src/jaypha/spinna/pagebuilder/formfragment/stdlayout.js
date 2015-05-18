// Written in Javascript
/*
 * Fill (or augmnent) a standard form fragment.
 *
 * Part of the Spinna framework.
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


function makeStdFormFragment(fragId, def, clear)
{
  var jqo = $('tbody', $('#'+fragId));

  if (clear) jqo.html("");

  for (i in def)
    jqo.append(makeStdFormRow(fragId, def[i]));
}

//----------------------------------------------------------------------------

function makeStdFormRow(fragId,def)
{
  var w = makeWidgetFromMeta(fragId, def);

  var tr = $("<tr></tr>");
  tr.addClass(name+"-valid-indicator");

  var td1 = $("<td class='label'></td>");
  if (def.required)
    td1.html("<span class='required'>*</span>");
  var td2 = $("<td class='label'>"+def.label+"</td>");
  var td3 = $("<td class='field'></td>");
  var td4 = $("<td class='label' style='display:none'>&lt;-- <span></span></td>");
  td4.addClass(name+"-invalid-msg");

  td3.append(w);
  tr.append(td1);
  tr.append(td2);
  tr.append(td3);
  tr.append(td4);

  w.data("widget").onValidate = function()
  {
    if (this.valid)
    {
      $("."+def.name+"-valid-indicator").removeClass("bad-input");
      $("."+def.name+"-invalid-msg").hide();
    }
    else
    {
      $("."+def.name+"-valid-indicator").addClass("bad-input");
      $("."+def.name+"-invalid-msg span").text(this.msg);
      $("."+def.name+"-invalid-msg").show();
    }
  }

  return tr;
}
