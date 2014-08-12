/*
 * JS for widgets and client side validation.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

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

/*
function add_integer_widget(n,l,f,i,r,b,t,s)
{
  var w = new IntegerWidget(n,l,f,i,r,b,t)
  if (f)
    widgets[f].push(w);
  if (s)
  {
    var id = i+"-wrapper";
    $('#'+id+' .spinner-up').click(function() { w.increment(1); } );
    $('#'+id+' .spinner-down').click(function() { w.increment(-1); } );
  }
}
*/
function add_radiogroup_widget(n,l,f,r)
{
  widgets[f].push(new EnumGroupWidget(n, l, f, r));
}

function add_checkgroup_widget(n,l,f,r)
{
  widgets[f].push(new EnumGroupWidget(n, l, f, r));
}

function add_date_widget(n,l,f,r)
{
  widgets[f].push(new DateWidget(n,l,f,r));
}

function add_dropdown_list_widget(n,l,f,r)
{
  widgets[f].push(new DropdownListWidget(n,l,f,r));
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

  if (v == "")
  {
    if (this.req == true)
      msg = this.required();
  }
  else
  {
    if (this.min != 0)
    {
      if (v.length < this.min)
        msg = this.violate_min_msg();
    }
    if (msg === null &&  this.max != 0)
    {
      if (v.length > this.max)
        msg = this.violate_max_msg();
    }
  }

  // TODO regex checking

  if (msg != null)
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").addClass("bad-input");
  else
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").removeClass("bad-input");

  return msg;
}

StringWidget.prototype.required = function()
{
  return '"'+this.lab + '" cannot be empty';
}

StringWidget.prototype.violate_min_msg = function()
{
  return '"'+this.lab + '" must be at least ' + this.min + ' characters';
}

StringWidget.prototype.violate_max_msg = function()
{
  return '"'+this.lab + '" cannot be more than ' + this.max + ' characters';
}

/*****************************************************************************
 *
 * Integer Widget
 *
 ****************************************************************************/

function IntegerWidget(n, l, f, i, r, b, t)
{
  this.nam = n;
  this.lab = l;
  this.fid = f;
  this.wid = i;
  this.req = r;
  this.min = b;
  this.max = t;
}

IntegerWidget.prototype.validate = function()
{
  var msg = null;

  var v = $("#"+this.wid).val();

  if (v == "")
  {
    if (this.req)
    {
      msg = '"'+this.lab + '" cannot be empty';
    }
  }
  else
  {
    if (!(/^(\+|-)?(\d+)$/.test(v)))
    {
      msg = '"'+this.lab + '" must be a valid integer';
    }
    v = parseInt(v,10); // Explicity give radix, just in case.
    
    if (msg === null && this.min !== null)
    {
      if (v < this.min)
        msg = '"'+this.lab + '" cannot be less than ' + this.min;
    }
    if (msg === null && this.max !== null)
    {
      if (v > this.max)
        msg = '"'+this.lab + '" cannot be more than ' + this.max;
    }
  }

  if (this.fid)
  {
    if (msg !== null)
      $("#"+this.fid+" ."+this.nam+"-valid-indicator").addClass("bad-input");
    else
      $("#"+this.fid+" ."+this.nam+"-valid-indicator").removeClass("bad-input");
  }

  return msg;
}

IntegerWidget.prototype.increment = function(diff)
{
  var w = $("#"+this.wid);
  var v;
  if (w.val() === '')
    v = 0;
  else
    v = parseInt(w.val());
  v += diff;
  if (v < this.min) v = this.min;
  if (v > this.max) v = this.max;
  w.val(v);
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
    if (v == "0")
    {
      msg = '"'+this.lab + '" must be set to "Yes"';
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
 * Date Widget
 *
 ****************************************************************************/

function DateWidget(n,l,f,r)
{
  this.nam = n;
  this.lab = l;
  this.fid = f;
  this.req = r;

  var id = f + "-" + n;
  var obj = this;

  this.wgt = $("#"+id);
  this.dsp = $("#"+id+"-display");

  var d = this.get();
  if (d)
  {
    this.dsp.val(d.format("jS M Y"));
  }

  this.x = new Calendar();
  this.x.on_select = function(date) { obj.set(date); };
  this.wgt.click(function(){ obj.x.show(get_position(obj.dsp), obj.get()); });
  this.dsp.click(function(){ obj.x.show(get_position(obj.dsp), obj.get()); });
  this.dsp.focus(function(){ obj.x.show(get_position(obj.dsp), obj.get()); });
}

DateWidget.prototype.get = function(date)
{
  if (this.wgt.val() != "")
    return new Date(this.wgt.val().replace(/-/g,'/'));
  else
    return null;
}

DateWidget.prototype.set = function(date)
{
  if (date)
  {
    this.wgt.val(date.format("Y-m-d"));
    this.dsp.val(date.format("jS M Y"));
  }
  else
  {
    this.wgt.val("");
    this.dsp.val("");
  }
}

DateWidget.prototype.validate = function()
{
  var msg = null;

  if (this.wgt.val() == "")
  {
    if (this.req)
      msg = '"'+this.lab + '" must have a value';
  }

  if (msg !== null)
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

/******************************************************************************
 *
 * EnumGroup Widget - For checkbox and radio groups
 *
 *****************************************************************************/

function EnumGroupWidget(n, l, f, r)
{
  this.nam = n;
  this.lab = l;
  this.fid = f;
  this.req=r;
  var obj = this;

  var id = f + "-" + n;
  var wgt = $("#"+id);

  $("#"+f+"-"+n+" label").each(function()
  {
    if ($("#"+$(this).attr("for")).prop("checked"))
      $(this).addClass("selected");
  });

  $('input', wgt).change(function() { obj.onchange(); });
}

EnumGroupWidget.prototype.onchange = function()
{
  $("#"+this.fid+"-"+this.nam+" label").each(function()
  {
    if ($("#"+$(this).attr("for")).prop("checked"))
      $(this).addClass("selected");
    else
      $(this).removeClass("selected");
  });
}

EnumGroupWidget.prototype.validate = function()
{
  var msg = null;

  if (this.req)
  {
    var has_value = false;
    $("#"+this.fid+"-"+this.nam+" input").each(function()
    {
      if ($(this).prop("checked"))
        has_value = true;
    });
    if (!has_value)
    {
      msg = '"'+this.lab + '" must have a value selected';
    }
  }

  if (msg !== null)
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").addClass("bad-input");
  else
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").removeClass("bad-input");

  return msg;
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
 * DropdownListWidget
 *
 *****************************************************************************/

function DropdownListWidget(n, l, f, r)
{
  this.nam = n;
  this.lab = l;
  this.fid = f;
  this.req=r;

  this.wid = f + "-" + n;
}

DropdownListWidget.prototype.validate = function()
{
  var msg = null;

  if (this.req)
  {
    if ($("#"+this.wid).val() == '')
    {
      msg = '"'+this.lab + '" must have a value selected';
    }
  }

  if (msg !== null)
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").addClass("bad-input");
  else
    $("#"+this.fid+" ."+this.nam+"-valid-indicator").removeClass("bad-input");

  return msg;
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
      $(".true-setting",$(this)).toggle(); $(".false-setting",$(this)).toggle();
      $("input",$(this)).val(1-$("input",$(this)).val());
    }
  );

  $(".integer-widget").keypress
  (
    function(event)
    {
      var c = event.which;
      var wgt = $(event.target);
      if (c == 0) return; // Home. End, Arrows etc.
      if (c == '\b'.charCodeAt(0)) return; // Backspace
      if (wgt.val() == '' && (c == '-'.charCodeAt(0) || c == '+'.charCodeAt(0))) return;
      if (c < '0'.charCodeAt(0) || c > '9'.charCodeAt(0))
        event.preventDefault();
    }
  );

  // Set up forms to use validation.
  $("form").submit(function(event) { return form_validate(this.attr('id'),no_valid); });
});
