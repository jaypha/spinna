/*****************************************************************************
 *
 * Date Picker Widget
 *
 * requires calendar.js
 *
 ****************************************************************************/

function DatePickerWidget(jqo, jqr, options)
{
  var defs = 
  {
    label: null,
    requried: false,
  };
  this.optns = jQuery.extend({}, defs, options);
  this.jqo = jqo;
  this.jqr = jqr;
  this.name = jqr.attr("name");
  this.valid = true;
  this.msg = null;
  this.required = this.optns.required;
  this.label = this.optns.label;

  var self = this;

  var d = this.get();
  if (d)
  {
    this.jqo.val(d.format("jS M Y"));
  }

  this.x = new Calendar();
  this.x.on_select = function(date) { self.set(date); };
  this.jqr.click(function(){ self.x.show(get_position(self.jqo), self.get()); });
  this.jqo.click(function(){ self.x.show(get_position(self.jqo), self.get()); });
  this.jqo.focus(function(){ self.x.show(get_position(self.jqo), self.get()); });

  jqo.data("widget", this);
}

DatePickerWidget.prototype.get = function(date)
{
  if (this.jqr.val() != "")
    return new Date(this.jqr.val().replace(/-/g,'/'));
  else
    return null;
}

DatePickerWidget.prototype.set = function(date)
{
  if (date)
  {
    this.jqr.val(date.format("Y-m-d"));
    this.jqo.val(date.format("jS M Y"));
  }
  else
  {
    this.jqr.val("");
    this.jqo.val("");
  }
}

DatePickerWidget.prototype.validate = function()
{
  this.msg = null;

  if (this.jqr.val() == "")
  {
    if (this.required)
      this.msg = 'Must have a value';
  }

  this.valid = (this.msg === null)

  if (this.on_validate) this.on_validate();
  return this.valid;
}
