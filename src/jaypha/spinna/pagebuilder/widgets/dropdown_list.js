
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
  if (this.on_validate) this.on_validate();
  return this.valid;
}