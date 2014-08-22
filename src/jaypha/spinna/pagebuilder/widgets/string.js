/*
 * JS for string widgets.
 *
 * Copyright 2013-4 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

function make_string_widget(name, options)
{
  var jq = $("<input type='text' class='widget string-widget' name='"+name+" id='"+name+"'/>");
  new StringWidget(jq,options);
  return jq;
}

function StringWidget(jqo, options)
{
  var defs = 
  {
    label: null,
    requried: false,
    minLen: 0,
    maxLen: 0,
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
      msg = this.required_msg();
  }
  else
  {
    if (this.optns.minLen != 0)
    {
      if (v.length < this.optns.minLen)
        msg = this.violate_min_msg(this.optns.minLen);
    }
    if (msg === null &&  this.optns.maxLen != 0)
    {
      if (v.length > this.optns.maxLen)
        msg = this.violate_max_msg(this.optns.maxLen);
    }

    if (msg === null && this.optns.regex !== null)
      if (!(regex.test(v)))
        msg = this.invalid_msg();
  }

  this.msg = msg;
  this.valid = msg === null;

  if (this.on_validate) this.on_validate();
  return this.valid;
}

/*
 * Default functions.
 */

StringWidget.prototype.required_msg = function()
{
  return 'Cannot be empty';
}

StringWidget.prototype.invalid_msg = function()
{
  return 'Must be valid';
}

StringWidget.prototype.violate_min_msg = function(minLen)
{
  return 'Must be at least ' + minLen + ' characters';
}

StringWidget.prototype.violate_max_msg = function(maxLen)
{
  return 'Cannot be more than ' + maxLen + ' characters';
}
