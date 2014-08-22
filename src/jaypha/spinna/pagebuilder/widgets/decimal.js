/*
 * JS for decimal widgets.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

function DecimalWidget(jqo, options)
{
  var defs =
  {
    required: false,
    label: null,
    scale: 2,
    min: -10000,
    max: +10000
  }
  this.optn = jQuery.extend({}, defs, options);
	
  this.jqo = jqo;
  this.name = jqo.attr['name'];
  this.required = options.required;
  this.jqo.data("widget",this);
  var self = this;


  this.jqo.bind('keypress', function(event)
  {
    var c = event.which;
    if (c == 0) return; // Home. End, Arrows etc.
    if (c == '\b'.charCodeAt(0)) return; // Backspace
    if (event.ctrlKey) return; // Allow control keys (paste, cut, etc);
    var crt_pos = $(this).caret();
    if (crt_pos == 0 && (c == '-'.charCodeAt(0) || c == '+'.charCodeAt(0))) return;
    var dot_pos = $(this).val().indexOf('.');
    if (c == '.'.charCodeAt(0))
    {
      if (dot_pos == -1) return;
      else event.preventDefault();
    }
    if (c < '0'.charCodeAt(0) || c > '9'.charCodeAt(0))
      event.preventDefault();
    if (dot_pos != -1 && crt_pos > dot_pos && $(this).val().length >= dot_pos+1+self.optn.scale)
      event.preventDefault();
  });

}

DecimalWidget.prototype.validate = function()
{
  var v = this.jqo.val();
  var msg = null;

  if (v == "")
  {
    msg = "non";
  }
  else
  {
    if (!(/^(\+|-)?(\d*)(\.)?(\d*)$/.test(v)))
      msg = "invalid";
    else if (v == '.' || v == '-.' || v == '+.')
      msg = "invalid";
    else
    {
      var dot_pos = v.indexOf('.');

      if (dot_pos != -1 && v.length > dot_pos+1+this.optn.scale)
        msg = "invalid";
      else
      {
        v = parseFloat(v);

        if (v < this.optn.min)
          msg = "low";
        else if (v > this.optn.max)
          msg = "high";
      }
    }
  }

  this.msg = msg;
  this.valid = (msg === null);
  if (this.on_validate) this.on_validate();
  return this.valid;
}
