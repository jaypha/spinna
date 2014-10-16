// Written in javascript
/*
 * JS for boolean widgets
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


function BooleanWidget(jqo, options)
{
  var defs = 
  {
    label: null,
    requried: false,
  };
  this.optns = jQuery.extend({}, defs, options);
  this.jqo = jqo;
  this.bol = $("input", jqo);
  this.name = jqo.attr("name");
  this.valid = true;
  this.required = this.optns.required;
  this.label = this.optns.label;

  jqo.data("widget", this);

  if (this.get())
    $(".false-setting",this.jqo).hide();
  else
    $(".true-setting",this.jqo).hide();
}

BooleanWidget.prototype.set = function(v)
{
  this.bol.val(v?'1':'0');
  if (v)
  {
    $(".true-setting",this.jqo).show();
    $(".false-setting",this.jqo).hide();
  }
  else
  {
    $(".true-setting",this.jqo).hide();
    $(".false-setting",this.jqo).show();
  }
}

BooleanWidget.prototype.get = function()
{
  return (this.bol.val() == '1')?true:false;
}

BooleanWidget.prototype.validate = function()
{
  var msg = null;

  var v = this.bol.val();

  if (this.required)
  {
    if (v == "0")
    {
      msg = 'Must be set to "Yes"';
    }
  }

  this.msg = msg;
  this.valid = (msg === null);

  if (this.onValidate) this.onValidate();
  return this.valid;
}

$(function()
{
  $(".boolean-widget").click
  (
    function()
    {
      $(".true-setting",$(this)).toggle(); $(".false-setting",$(this)).toggle();
      $("input",$(this)).val(1-$("input",$(this)).val());
    }
  );
});
