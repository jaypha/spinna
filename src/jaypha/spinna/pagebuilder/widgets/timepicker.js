// Written in javascript
/*
 * JS for time picker
 *
 * Copyright (C) 2015 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

function TimePickerWidget(jqo, jqr, options)
{
  var defs = 
  {
    label: null,
    requried: false,
    minuteStep: 5
  };

  this.optns = jQuery.extend({}, defs, options);
  this.jqo = jqo;
  this.jqr = jqr;
  this.name = jqr.attr("name");
  this.msg = null;
  this.required = this.optns.required;
  this.label = this.optns.label;

  var self = this;

  jqo.html(this.constructHourButton()+this.constructMinuteButton()+this.constructAMPMButton());
  $('#'+this.name+'-hour').change(function() { self.onChange(); });
  $('#'+this.name+'-minute').change(function() { self.onChange(); });
  $('#'+this.name+'-ampm').change(function() { self.onChange(); });

  jqo.data("widget", this);
}

TimePickerWidget.prototype.constructHourButton = function()
{
	var hourOptions = [12,1,2,3,4,5,6,7,8,9,10,11];

  var html = "<select id='"+this.name+"-hour'>";
  for (i in hourOptions)
    html += "<option>"+hourOptions[i]+"</option>";
  html += "</select>";
  return html;
}

TimePickerWidget.prototype.constructMinuteButton = function()
{
	var minuteOption = 0;

  var html = "<select id='"+this.name+"-minute'>";
  while (minuteOption < 60)
  {
    var x = (minuteOption < 10) ? "0"+minuteOption : minuteOption;
    html += "<option>"+x+"</option>";
    minuteOption += this.optns.minuteStep;
  }
  html += "</select>";
  return html;
}

TimePickerWidget.prototype.constructAMPMButton = function()
{
  return "<select id='"+this.name+"-ampm'><option>am</option><option>pm</option></select>";
}

TimePickerWidget.prototype.onChange = function()
{
  var hours = parseInt($('#'+this.name+'-hour').val());
  var min = $('#'+this.name+'-minute').val();
  var ampm = $('#'+this.name+'-ampm').val();
  if (ampm == "pm")
    hours += 12;
  this.jqr.val(hours+":"+min+":00");
}

TimePickerWidget.prototype.get = function()
{
  if (this.jqr.val() != "")
    return new Date(this.jqr.val()); // TODO
  else
    return null;
}

TimePickerWidget.prototype.set = function(time)
{
  if (time)
  {
    var hours = time.getHours();
    var min = time.getMinutes();
    min = Math.floor(min/this.optns.minuteStep) * this.optns.minuteStep;
    this.jqr.val(hours+":"+min+":00");
    var ampm = hours>=12?"pm":"am";
    hours = hours%12;

    $('#'+this.name+'-hour').val(hours);
    $('#'+this.name+'-minute').val(min);
    $('#'+this.name+'-ampm').val(ampm);
  }
  else
  {
    this.jqr.val("");
  }
}

TimePickerWidget.prototype.validate = function()
{
  this.msg = null;

  if (this.jqr.val() == "")
  {
    if (this.required)
      this.msg = 'Must have a value';
  }

  this.valid = (this.msg === null)

  if (this.onValidate) this.onValidate();
  return this.valid;
}
