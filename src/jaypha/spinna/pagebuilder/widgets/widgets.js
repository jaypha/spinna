
function in_array(needle, haystack)
{
  for (i in haystack)
    if (needle == haystack[i])
      return true;
  return false;
}

/*****************************************************************************
 *
 * Widgets
 *
 ****************************************************************************/

var widgets = {};

function add_string_widget(n, l, f, r, b, t, x)
{
  widgets[f].push(new StringWidget(n, l, f, r, b, t, x));
}

function add_boolean_widget(n, l, f, r, d)
{
  widgets[f].push(new BooleanWidget(n, l, f, r, d));
}

function add_selector_widget(n,l,f,b,t)
{
  widgets[f].push(new SelectorWidget(n,l,f,b,t));
}

/*****************************************************************************
 *
 * Validation
 *
 ****************************************************************************/

function form_validate(formid, callback)
{
  var messages = [];

  for (var i in widgets[formid])
  {
    var message = widgets[formid][i].validate();
    if (message != null)
    {
      messages.push(message);
    }
  }

  if (messages.length)
  {
    callback(messages);
    return false;
  }
  return true;
}

function no_valid(messages)
{
  $("#message-dialog .dialog-content").html("<h4>Form submission is not acceptable</h4>"+messages.join("<br/>"));
  $("#message-dialog").jqmShow();
}

/*****************************************************************************
 *
 * String Widget
 *
 ****************************************************************************/

function StringWidget(n, l, f, r, b, t, x)
{
  this.nam = n;
  this.lab = l;
  this.fid = f;
  this.req = r;
  this.min = b;
  this.max = t;
  this.reg = x;
}

StringWidget.prototype.validate = function()
{
  var msg = null;

  var v = $("#"+this.fid+"-"+this.nam).val();

  if (this.req == true)
  {
    if (v == "")
      msg = '"'+this.lab + '" cannot be empty';
  }
  if (msg != null && this.min != 0)
  {
    if (v.length < this.min)
      msg = '"'+this.lab + '" must be at least ' + this.min + ' characters';
  }
  if (msg != null &&  this.max != 0)
  {
    if (v.length > this.max)
      msg = '"'+this.lab + '" cannot be more than ' + this.max + ' characters';
  }

  // TODO regex checking

  if (msg != null)
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").addClass("bad-input");
  else
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").removeClass("bad-input");

  return msg;
}

/*****************************************************************************
 *
 * Boolean Widget
 *
 ****************************************************************************/

function BooleanWidget(n, l, f, r)
{
  this.nam = n;
  this.lab = l;
  this.fid = f;
  this.req=r;
  var v = $("#"+f+"-"+n+" input").val();
  if (v == "0") $("#"+f+"-"+n+" .false-setting").show();
  else if (v == "1") $("#"+f+"-"+n+" .true-setting").show();
}

function set_boolean(fid,nam)
{
  var v = $("#"+fid+"-"+nam+" input").val();
  alert(v);
  if (v == "0") $("#"+fid+"-"+nam+" .false-setting").show();
  else if (v == "1") $("#"+fid+"-"+nam+" .true-setting").show();
}

BooleanWidget.prototype.set = function()
{
  $("#"+this.fid+"-"+this.nam+" .true-setting").show();
  $("#"+this.fid+"-"+this.nam+" .false-setting").hide();
  $("#"+this.fid+"-"+this.nam+" input").val(1);
}

BooleanWidget.prototype.clear = function()
{
  $("#"+this.fid+"-"+this.nam+" .true-setting").hide();
  $("#"+this.fid+"-"+this.nam+" .false-setting").show();
  $("#"+this.fid+"-"+this.nam+" input").val(0);
}

BooleanWidget.prototype.validate = function()
{
  var msg = null;

  var v = $("#"+this.fid+" input[name="+this.nam+"]").val();

  if (this.req == true)
  {
    if (v == "")
    {
      msg = '"'+this.lab + '" cannot be empty';
    }
  }
  if (msg != null)
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").addClass("bad-input");
  else
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").removeClass("bad-input");

  return msg;
}

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

  var id = f.id + "-" + n;
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
      uv.hide();
    else
      sv.hide();
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

/******************************************************************************
 *
 * Sort Widget
 *
 *****************************************************************************/

function sort_update(id, name, formid)
{
  var a = $('#'+id).sortable('toArray');
  var s = a[0].replace(id+'-','');
  for (var i=1; i<a.length; ++i)
    s=s+','+a[i].replace(id+'-','');
  $('#'+formid+" input[name='"+name+"']").val(s);
}

/*****************************************************************************
 *
 * CKFinder
 *
 *****************************************************************************/

function use_ckfinder( startupPath, functionData )
{
	// You can use the "CKFinder" class to render CKFinder in a page:
	var finder = new CKFinder() ;
	
	// The path for the installation of CKFinder (default = "/ckfinder/").
	finder.BasePath = '/thirdparty/ckfinder/' ;
	
	//Startup path in a form: "Type:/path/to/directory/"
	finder.StartupPath = startupPath ;
	
	// Name of a function which is called when a file is selected in CKFinder.
	finder.SelectFunction = SetFileField ;
	
	// Additional data to be passed to the SelectFunction in a second argument.
	// We'll use this feature to pass the Id of a field that will be updated.
	finder.SelectFunctionData = functionData ;
	
	// Name of a function which is called when a thumbnail is selected in CKFinder.
	//finder.SelectThumbnailFunction = ShowThumbnails ;

	// Launch CKFinder
	finder.Popup() ;
}

// This is a sample function which is called when a file is selected in CKFinder.
function SetFileField( fileUrl, data )
{
	$('#'+ data["selectFunctionData"]).val(fileUrl);
}

/*****************************************************************************
 *
 * Startup
 *
 ****************************************************************************/

$(function()
{
  $(".boolean-widget").click
  (
    function()
    {
      var v = $("input",$(this)).val();
      if (v == '')
      {
        $(".true-setting",$(this)).toggle();
        $("input",$(this)).val(1);
      }
      else
      {
        $(".true-setting",$(this)).toggle(); $(".false-setting",$(this)).toggle();
        $("input",$(this)).val(1-$("input",$(this)).val());
      }
    }
  );
});
