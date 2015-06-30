// Written in Javascript
/*
 * JS for integer widgets.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

function makeIntegerWidget(id, name, def, value)
{
  var jq = $("<input type='text' class='widget integer-widget' name='"+name+" id='"+id+"'/>");
  new IntegerWidget(jq,def);
  if (typeof value != 'undefined')
    jq.val(value);
  return jq;
}

function IntegerWidget(jqo, options)
{
  var defs =
  {
    required: false,
    label: null,
    stepInc: 1,
    pageInc: 10,
    min: 0,
    max: 100000,
    spinner: true
  }

  var self = this;

	this.optn = jQuery.extend({}, defs, options);

  this.jqo = jqo;
  this.name = jqo.attr("name");
  this.valid = true;
  this.required = this.optn.required;
  this.label = this.optn.label;

  jqo.bind('keypress', function(event) { self.keyPress(event); });
  jqo.bind('keydown', function(event) { self.keyDown(event); });

  if (this.optn.spinner)
  $(function() {
    var spin_up = $("<a class='spin-up' style='visibility:hidden'>&#9650;</a>");
    var spin_dn = $("<a class='spin-dn' style='visibility:hidden'>&#9660;</a>");
    $("body").append(spin_up);
    $("body").append(spin_dn);
    var pos = jqo.offset();
    spin_up.offset({top:pos.top,left: pos.left + jqo.outerWidth() - spin_up.outerWidth()});
    spin_dn.offset({top:pos.top + jqo.outerHeight() - spin_dn.outerHeight(),left: pos.left + jqo.outerWidth() - spin_up.outerWidth()});
    jqo.css("padding-right",parseInt(jqo.css("padding-right"))+spin_up.outerWidth()+"px");
    jqo.css("width",parseInt(jqo.css("width"))-spin_up.outerWidth()+"px");
    spin_up.click(function() { self.increment(self.optn.stepInc); } );
    spin_dn.click(function() { self.increment(-self.optn.stepInc); } );
    spin_up.css('visibility','');
    spin_dn.css('visibility','');
  });

  jqo.data("widget", this);
}

IntegerWidget.prototype.set = function(v)
{
  this.jqo.val(v);
}

IntegerWidget.prototype.get = function()
{
  return this.jqo.val();
}

IntegerWidget.prototype.increment = function(diff)
{
  var v = this.jqo.val();
  if (v === '')
    v = 0;
  else
    v = parseInt(v);
  v += diff;
  if (v < this.optn.min) v = this.optn.min;
  if (v > this.optn.max) v = this.optn.max;
  this.jqo.val(v);
}


IntegerWidget.prototype.keyPress = function(event)
{
  var c = event.which;
  if (c == 0) return; // Home. End, Arrows etc.
  if (c == '\b'.charCodeAt(0)) return; // Backspace
  if (event.ctrlKey) return; // Allow control keys (paste, cut, etc);
  if (this.jqo.val() == '' && (c == '-'.charCodeAt(0) || c == '+'.charCodeAt(0))) return;
  if (c < '0'.charCodeAt(0) || c > '9'.charCodeAt(0))
    event.preventDefault();
}

IntegerWidget.prototype.keyDown = function(event)
{
  switch (event.which)
  {
    case 38: // Up key
      this.increment(this.optn.stepInc);
      break;
    case 40: // Down key
      this.increment(-this.optn.stepInc);
      break;
    case 33: //pgUp key
      this.increment(this.optn.pageInc);
      break;
    case 34: // pgDn key
      this.increment(-this.optn.pageInc);
      break;
    default: // All others.
      break;
  }
}

IntegerWidget.prototype.validate = function()
{
  var msg = null;
  var v = this.jqo.val();

  if (v == "")
  {
    if (this.required)
      msg = "non";
  }
  else
  {
    if (!(/^(\+|-)?(\d+)$/.test(v)))
      msg = "invalid";

    v = parseInt(v,10); // Explicity give radix, just in case.

    if (v < this.optn.min)
      msg = "low";
    if (v > this.optn.max)
      msg = "high";
  }

  this.msg = msg;
  this.valid = (msg === null);

  if (this.onValidate) this.onValidate();
  return this.valid;
}

