/*****************************************************************************
 *
 * Selector Widget
 *
 ****************************************************************************/

function SelectorWidget(jqo, options)
{
  var defs =
  {
    label: null,
    min: 0,
    max: 0
  };

  var obj = this;

  this.optn = jQuery.extend({}, defs, options);
  this.jqo = jqo;

  this.name = jqo.attr("name");
  this.valid = true;
  this.msg = null;
  this.label = this.optn.label;

  jqo.data("widget", this);

  var html = "";
  var u = $(".unselected", jqo);
  var s = $(".selected", jqo);

  $("input[name='"+this.name+"']",jqo).each(function()
  {
    var v = $(this).val();
    var uv = $(".unselected-"+v, jqo);
    uv.click(function() { obj.sel(v); });
    uv.get(0).selector_value = v;
    var sv = $(".selected-"+v, jqo);
    sv.click(function() { obj.unsel(v); });
    sv.get(0).selector_value = v;
    if ($(this).prop("checked"))
      sv.show();
    else
      uv.show();
  });

  var x = $(".selector-search", jqo);
  x.bind('keyup', function() { obj.search(); });
  x.bind('blur', function() { if ($(this).val() == "") { $(this).val("Search"); $(this).addClass("selector-search-empty"); this.has_content = false; } });
  x.bind('focus', function() { if (!this.has_content) { $(this).val(""); $(this).removeClass("selector-search-empty"); this.has_content = true; } });
  x.val("Search");

  $(".selector-clear", jqo).bind("click", function() { obj.clear(); });
  $(".selector-all", jqo).bind("click", function() { obj.selectall(); });

}

//----------------------------------------------------------------------------

SelectorWidget.prototype.sel = function(v)
{
  $(".selected-"+v, this.jqo).show();
  $(".unselected-"+v, this.jqo).hide();
  $("input[value='"+v+"']", this.jqo).prop("checked",true);
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.unsel = function(v)
{
  $(".selected-"+v, this.jqo).hide();
  $(".unselected-"+v, this.jqo).show();
  $("input[value='"+v+"']", this.jqo).prop("checked",false);
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.search = function()
{
  var txt = $(".selector-search", this.jqo).val();
  var jqo = this.jqo;
  $(".selected li:hidden", this.jqo).each(function()
  {
    var v = $(this).attr("class");
    {
      var x = $(".un"+v,jqo);
      if (x.text().toLowerCase().indexOf(txt) != -1)
        x.show();
      else
        x.hide();
    }
  });
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.clear = function()
{
  var obj = this;
  $(".selected li", this.jqo).each(function()
  {
    obj.unsel($(this).attr("class").substring(9));
  });
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.selectall = function()
{
  var obj = this;
  $(".unselected li", this.jqo).each(function()
  {
    obj.sel($(this).attr("class").substring(11));
  });
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.addButton = function(label, list)
{
  var obj = this;
  var x = $("<button>"+label+"</button><br/>");
  x.get(0).list = list;
  x.click(function()
  {
    var button = this;
    $(".unselected li", obj.jqo).each(function()
    {
      if (in_array(this.selector_value, button.list))
      {
        obj.sel(this.selector_value);
      }
    });
  });
  $(".selector-buttons", this.jqo).append(x);
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.validate = function()
{
  this.msg = null;
  this.valid = true;

  if (this.on_validate) this.on_validate();
  return this.valid;
}
