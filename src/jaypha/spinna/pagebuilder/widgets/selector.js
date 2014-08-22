/*****************************************************************************
 *
 * Selector Widget
 *
 ****************************************************************************/

function SelectorWidget(n,l,f,b,t)
{
  this.nam = n;
  this.lab = l;
  this.fid = f;
  this.min = b;
  this.max = t;

  var id = f + "-" + n;
  var wgt = $("#"+id);
  var obj = this;

  this.wgt = wgt;

  var html = "";
  var u = $(".unselected", wgt);
  var s = $(".selected", wgt);

  $("input[name='"+n+"']",wgt).each(function()
  {
    var v = $(this).val();
    var uv = $(".unselected-"+v, wgt);
    uv.click(function() { obj.sel(v); });
    uv.get(0).selector_value = v;
    var sv = $(".selected-"+v, wgt);
    sv.click(function() { obj.unsel(v); });
    sv.get(0).selector_value = v;
    if ($(this).prop("checked"))
      sv.show();
    else
      uv.show();
  });

  var x = $(".selector-search", wgt);
  x.bind('keyup', function() { obj.search(); });
  x.bind('blur', function() { if ($(this).val() == "") { $(this).val("Search"); $(this).addClass("selector-search-empty"); this.has_content = false; } });
  x.bind('focus', function() { if (!this.has_content) { $(this).val(""); $(this).removeClass("selector-search-empty"); this.has_content = true; } });
  x.val("Search");

  $(".selector-clear", wgt).bind("click", function() { obj.clear(); });
  $(".selector-all", wgt).bind("click", function() { obj.selectall(); });

}

//----------------------------------------------------------------------------

SelectorWidget.prototype.sel = function(v)
{
  $(".selected-"+v, this.wgt).show();
  $(".unselected-"+v, this.wgt).hide();
  $("input[value='"+v+"']", this.wgt).prop("checked",true);
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.unsel = function(v)
{
  $(".selected-"+v, this.wgt).hide();
  $(".unselected-"+v, this.wgt).show();
  $("input[value='"+v+"']", this.wgt).prop("checked",false);
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.search = function()
{
  var txt = $(".selector-search", this.wgt).val();
  var wgt = this.wgt;
  $(".selected li:hidden", this.wgt).each(function()
  {
    var v = $(this).attr("class");
    {
      var x = $(".un"+v,wgt);
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
  $(".selected li", this.wgt).each(function()
  {
    obj.unsel($(this).attr("class").substring(9));
  });
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.selectall = function()
{
  var obj = this;
  $(".unselected li", this.wgt).each(function()
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
    $(".unselected li", obj.wgt).each(function()
    {
      if (in_array(this.selector_value, button.list))
      {
        obj.sel(this.selector_value);
      }
    });
  });
  $(".selector-buttons", this.wgt).append(x);
}

//----------------------------------------------------------------------------

SelectorWidget.prototype.validate = function()
{
  return null;
}
