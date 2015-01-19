// Written in Javascript
/*
 * JS for droplist widgets.
 *
 * Part of the Spinna framework
 *
 * Copyright 2013-4 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

function makeDropdownListWidget(id,name,def,options,value)
{
  var jq = $("<select class='widget dropselect-widget' name='"+name+"' id='"+id+"'></select>");
  for (i in options)
  {
    var op = $("<option value='"+options[i].value+"'>"+options[i].label+"</option>");
    jq.append(op);
  }
  new DropdownListWidget(jq,options);
  if (typeof value != 'undefined')
    jq.val(value);
  return jq;
}

//----------------------------------------------------------------------------

function DropdownListWidget(jqo,options)
{
  var defs =
  {
  }

  this.optn = jQuery.extend({}, defs, options);

  this.jqo = jqo;	
  this.required = this.optn.required;
  this.valid = true;
  this.msg = null;
  this.label = this.optn.label;

  this.jqo.data("widget",this);
}

DropdownListWidget.prototype.validate = function()
{
  var msg = null;

  if (this.required)
  {
    if (this.jqo.val() == '')
    {
      msg = 'Must have a value selected';
    }
  }

  this.msg = msg;
  this.valid = (msg === null);
  if (this.onValidate) this.onValidate();
  return this.valid;
}
