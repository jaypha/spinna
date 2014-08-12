/*
 * JS for integer widgets.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


function add_integer_widget(n,l,f,i,r,b,t,s)
{
  $('#'+i).IntegerWidget({ min:b, max: t, spinner: s});

  widgets[f].push
  ({
    validate: function()
    {
      var v = $('#'+i).get(0).validate();
      var msg = null;
      switch(v)
      {
        case "ok":
          break;
        case "non":
          if (r)
            msg = '"'+l + '" cannot be empty';
          break;
        case "invalid":
          msg = '"'+l + '" must be a valid integer';
          break;
        case "low":
          msg = '"'+l + '" cannot be less than ' + b;
          break;
        case "high":
          msg = '"'+l + '" cannot be more than ' + t;
          break;
      }
      if (msg !== null)
        $("#"+f+" ."+n+"-valid-indicator").addClass("bad-input");
      else
        $("#"+f+" ."+n+"-valid-indicator").removeClass("bad-input");

    }
  });
}


(function($){$.fn.IntegerWidget = function(options)
{
  var defs =
  {
    min: 0,
    max: 100000,
    spinner: true
  }

	var optn = jQuery.extend({}, defs, options);

  return this.each(function()
  {
    var wgt = $(this);
    if (optn.spinner)
    {
      var spin_up = $("<a class='spin-up' style='visibility:hidden'>&#9650;</a>");
      var spin_dn = $("<a class='spin-dn' style='visibility:hidden'>&#9660;</a>");
      $("body").append(spin_up);
      $("body").append(spin_dn);
      var pos = wgt.offset();
      spin_up.offset({top:pos.top,left: pos.left + $(this).outerWidth() - spin_up.outerWidth()});
      spin_dn.offset({top:pos.top + $(this).outerHeight() - spin_dn.outerHeight(),left: pos.left + $(this).outerWidth() - spin_up.outerWidth()});
      wgt.css("padding-right",parseInt(wgt.css("padding-right"))+spin_up.outerWidth()+"px");
      wgt.css("width",parseInt(wgt.css("width"))-spin_up.outerWidth()+"px");
    }

    function increment(diff)
    {
      var v = wgt.val();
      if (v === '')
        v = 0;
      else
        v = parseInt(v);
      v += diff;
      if (v < optn.min) v = optn.min;
      if (v > optn.max) v = optn.max;
      wgt.val(v);
    }

    wgt.bind('keypress',

      function(event)
      {
        var c = event.which;
        if (c == 0) return; // Home. End, Arrows etc.
        if (c == '\b'.charCodeAt(0)) return; // Backspace
        if (event.ctrlKey) return; // Allow control keys (paste, cut, etc);
        if (wgt.val() == '' && (c == '-'.charCodeAt(0) || c == '+'.charCodeAt(0))) return;
        if (c < '0'.charCodeAt(0) || c > '9'.charCodeAt(0))
          event.preventDefault();
      }
    );

    wgt.bind('keydown', function(event)
    {
      switch (event.which)
      {
        case 38: // Up key
          increment(1);
          break;
        case 40: // Down key
          increment(-1);
          break;
        case 33: //pgUp key
          increment(10);
          break;
        case 34: // pgDn key
          increment(-10);
          break;
        default: // All others.
          break;
      }
    });

    this.validate = function()
    {
      var v = wgt.val();

      if (v == "")
      {
        return "non";
      }
      else
      {
        if (!(/^(\+|-)?(\d+)$/.test(v)))
          return "invalid";

        v = parseInt(v,10); // Explicity give radix, just in case.

        if (v < optn.min)
          return "low";
        if (v > optn.max)
          return "high";
      }

      return "ok";
    }

    if (optn.spinner)
    {
      spin_up.click(function() { increment(1); } );
      spin_dn.click(function() { increment(-1); } );
      spin_up.css('visibility','');
      spin_dn.css('visibility','');
    }
  });

};})(jQuery);

