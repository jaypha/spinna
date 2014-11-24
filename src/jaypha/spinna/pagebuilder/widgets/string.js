// Written in Javascript
/*
 * JS for string widgets.
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

function makeStringWidget(id, name, def, value)
{
  var jq = $("<input type='text' class='widget string-widget' name='"+name+"' id='"+id+"'/>");
  new StringWidget(jq,def);
  if (typeof value != 'undefined')
    jq.val(value);
  return jq;
}

function makeTextAreaWidget(id, name, def, value)
{
  var jq = $("<textarea class='widget text-widget' name='"+name+"' id='"+id+"'></textarea>");
  new StringWidget(jq,def);
  if (typeof value != 'undefined')
    jq.text(value);
  return jq;
}


//----------------------------------------------------------------------------

function StringWidget(jqo, options)
{
  var defs = 
  {
    label: null,
    requried: false,
    minLength: 0,
    maxLength: 0,
    regex: null
  };
  this.optns = jQuery.extend({}, defs, options);
  this.jqo = jqo;
  this.name = jqo.attr("name");
  this.valid = true;
  this.required = this.optns.required;
  this.label = this.optns.label;

  jqo.data("widget", this);
}

StringWidget.prototype.set = function(v)
{
  this.jqo.val(v);
}

StringWidget.prototype.get = function()
{
  return this.jqo.val();
}

StringWidget.prototype.validate = function()
{
  var msg = null;

  var v = this.jqo.val();

  if (v == "")
  {
    if (this.required)
      msg = this.requiredMsg();
  }
  else
  {
    if (this.optns.minLength != 0)
    {
      if (v.length < this.optns.minLength)
        msg = this.violateMinMsg(this.optns.minLength);
    }
    if (msg === null &&  this.optns.maxLength != 0)
    {
      if (v.length > this.optns.maxLength)
        msg = this.violateMaxMsg(this.optns.maxLength);
    }

    if (msg === null && this.optns.regex !== null)
      if (!(regex.test(v)))
        msg = this.invalidMsg();
  }

  this.msg = msg;
  this.valid = msg === null;

  if (this.onValidate) this.onValidate();
  return this.valid;
}

/*
 * Default functions.
 */

StringWidget.prototype.requiredMsg = function()
{
  return 'Cannot be empty';
}

StringWidget.prototype.invalidMsg = function()
{
  return 'Must be valid';
}

StringWidget.prototype.violateMinMsg = function(minLen)
{
  return 'Must be at least ' + minLen + ' characters';
}

StringWidget.prototype.violateMaxMsg = function(maxLen)
{
  return 'Cannot be more than ' + maxLen + ' characters';
}
