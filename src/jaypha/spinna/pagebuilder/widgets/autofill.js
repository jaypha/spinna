/******************************************************************************
 * Auto fill widget
 * Copyright (C) 2011 Jaypha.
 *
 * Author: Jason den Dulk
 *****************************************************************************/

/*
 * Options:
 *
 * listId:  Id of an element to use. If none then one will be created as a popup.
 * list:    List to be used. Defaults to [].
 * searchMinLength: The min length to start searching. Defaults to 1.
 * searchCallback: function to use for performing search/filter.
 *           defaults to a simple text matching function
 * selectCallback: function to call when a selection has been made. Defaults
 *                 to filling the input with the selected value.
 * required: If true, then a value must be selected.
 */

function AutofillWidget(jqo, options)
{
  var defs =
  {
    required: false,
    list: [],
    labels: AutofillLabels
  }

  var obj= this;

  this.optn = jQuery.extend({}, defs, options);

  this.jqo = jqo;
  this.id = jqo.attr('id');
  this.required = this.optn.required;
  this.valid = true;
  this.msg = null;
  this.label = this.optn.label;
  this.no_blur = false;
  this.val = $('#'+this.id+'-ret').val();
  this.name = $('#'+this.id+'-ret').attr('name');
  
  if ('listId' in options)
    this.listw = $('#'+options.listId);
  else
  {
    this.listw = $("<ul id='"+this.id+"-list' class='autofill-widget-list' style='display:none'></ul>");
    jqo.after(this.listw);
    // Position listw to be just below jqo.
  }

  this.select(this.val);

  if (!('searchCallback' in this.optn))
    this.optn.searchCallback = function(text)
    {//alert("search: "+text);
      //if (text == "") return options.list;
      if (text.length <2)
        return [];

      // Returns any item that has text as a substring.
      text = text.toLowerCase();
      var list = [];

      for (var i=0; i<obj.optn.list.length; ++i)
      {
        if (obj.optn.list[i][1].toLowerCase().indexOf(text) != -1)
          list.push(obj.optn.list[i]);
      }
      return list;
    };

  this.listw.bind('mousedown', function()
  {
    obj.optn.no_blur = true;
  });

  this.listw.bind('mouseup', function()
  {
    obj.optn.no_blur = false;
  });

  jqo.bind('blur',  function()
  {
    if (obj.optn.no_blur) return;
    if (obj.get_value($(this).val()) === null)
    {
      obj.select('');
      //$(this).val(obj.optn.labels.empty_input);
      //$(this).addClass("autofill-empty");
      //obj.listw.hide();
    }
  });

  // Calls searchCallback and loads result into the list.
  jqo.bind('keyup', function()
  {
    obj.loadlist(obj.optn.searchCallback($(this).val()));
  });

  //----------------------------------------

  jqo.bind('focus', function()
  {
    if (!obj.has_content)
    {
      $(this).val("");
      $(this).removeClass("autofill-empty");
      this.has_content = true;
    }
  });

  this.loadlist(this.optn.searchCallback(""));

  this.jqo.data("widget",this);
}

AutofillWidget.prototype.validate = function()
{
  var msg = null;

  if (this.required)
  {
    if (this.val == '')
    {
      msg = 'Must have a value selected';
    }
  }

  this.msg = msg;
  this.valid = (msg === null);
  if (this.on_validate) this.on_validate();
  return this.valid;
}

AutofillWidget.prototype.select = function(val)
{
  this.val = val;
  $('input[name='+this.name+']').val(val);
  if (val == "")
  {
    this.jqo.addClass("autofill-empty");
    this.jqo.val(this.optn.labels.empty_input);
    this.has_content = false;
  }
  else
  {
    this.jqo.removeClass("autofill-empty");
    this.jqo.val(this.get_label(val));
    this.has_content = true;
  }
  this.optn.no_blur = false;
  this.listw.hide();
  if ('selectCallback' in this.optn)
    this.optn.selectCallback(val);
}

AutofillWidget.prototype.get_value = function(label)
{
  for (i in this.optn.list)
    if (label == this.optn.list[i][1])
      return this.optn.list[i][0];
  return null;
}

AutofillWidget.prototype.get_label = function(val)
{
  for (i in this.optn.list)
    if (val == this.optn.list[i][0])
      return this.optn.list[i][1];
  return null;
}

AutofillWidget.prototype.loadlist = function(subList)
{
  //alert("loadlist "+subList.length);
  var obj = this;
  // Creates HTML for subList and inserts into the list element.
  this.listw.html("");

  for (var i=0; i<subList.length; ++i)
  {
    var val = subList[i][0];
    var lab = subList[i][1];
    var li = $("<li class='autofill-list-"+val+"'><a style='display:block'>"+lab+"</a></li>");
    li.data("autofill_value", val);
    li.click
    (
      (function(v) {
        return function() { obj.select(v); }
      })(val)
    );
    this.listw.append(li);
  }
  if (subList.length) this.listw.show(); else this.listw.hide();
}


var AutofillLabels = 
{
  empty_input : "Type search here"
};