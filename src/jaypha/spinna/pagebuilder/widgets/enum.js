function EnumGroupWidget(jqo,name,options)
{
  var defs =
  {
    label : null,
    minSel : 1,
    maxSel : 0
  }
	this.optn = jQuery.extend({}, defs, options);

  var obj = this;

  this.label = this.optn.label
  this.valid = true;
  this.msg = null;
  this.required = this.optn.minSel > 0;

  this.jqo = jqo;
  this.name = name;

  this.ps = {};

  $("label",jqo).each(function()
  {
    var p = $("#"+$(this).attr("for"))
    var val = p.val();
    if (p.prop("checked"))
      $(this).addClass("selected");
    p.change(function() { if ($(this).prop("checked")) obj.ps[$(this).attr("value")][0].addClass("selected"); else obj.ps[$(this).attr("value")][0].removeClass("selected"); });
    obj.ps[val] = [$(this), p ];
  });
  jqo.data("widget", this);
}

EnumGroupWidget.prototype.select = function(val)
{
  this.ps[val][1].prop("checked",true);
  this.ps[val][1].change();
}

EnumGroupWidget.prototype.unselect = function(val)
{
  this.ps[val][1].prop("checked",false);
  this.ps[val][1].change();
}

EnumGroupWidget.prototype.toggle = function(val)
{
  this.ps[val][1].prop("checked",!this.ps[val][1].prop("checked"));
  this.ps[val][1].change();
}

EnumGroupWidget.prototype.validate = function()
{
  this.msg = null;

  var numSel = 0;

  for (i in this.ps)
  {
    if (this.ps[i][1].prop("checked"))
      ++numSel;
  }

  if (this.optn.minSel == this.optn.maxSel && numSel != this.optn.minSel)
  {
    this.msg = 'Must have '+this.optn.minSel+' selected';
  }
  else if (numSel < this.optn.minSel)
  {
    this.msg = 'Must have at least '+this.optn.minSel+' selected';
  }
  else if (numSel > this.optn.maxSel && this.optn.maxSel != 0)
  {
    this.msg = 'Must have at most '+this.optn.maxSel+' selected';
  }

  this.valid = (this.msg === null);

  if (this.on_validate) this.on_validate();
  return this.valid;
}
