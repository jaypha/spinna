

function add_decimal_widget(n,l,f,i,r,s,b,t)
{
  $('#'+i).DecimalWidget({ min:b, max: t, scale: s});

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
          msg = '"'+l + '" must be a valid decimal no more than ' + s + ' places';
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


(function($){$.fn.DecimalWidget = function(options)
{
  var defs =
  {
    scale: 2
  }

	var optn = jQuery.extend({}, defs, options);

  return this.each(function()
  {
    var wgt = $(this);

    wgt.bind('keypress', function(event)
    {
      var c = event.which;
      if (c == 0) return; // Home. End, Arrows etc.
      if (c == '\b'.charCodeAt(0)) return; // Backspace
      if (event.ctrlKey) return; // Allow control keys (paste, cut, etc);
      var crt_pos = wgt.caret();
      if (crt_pos == 0 && (c == '-'.charCodeAt(0) || c == '+'.charCodeAt(0))) return;
      var dot_pos = wgt.val().indexOf('.');
      if (c == '.')
      {
        if (dot_pos == -1) return;
        else event.preventDefault();
      }
      if (c < '0'.charCodeAt(0) || c > '9'.charCodeAt(0))
        event.preventDefault();
      if (dot_pos != -1 && crt_pos > dot_pos && str.length() >= dot_pos+1+optn.scale)
        event.preventDefault();
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
        if (!(/^(\+|-)? (\d*)(\.)?(\d*)$/.test(v)))
          return "invalid";
        if (v == '.' || v == '-.' || v == '+.')
          return "invalid";
        var dot_pos = v.indexOf('.');

        if (dot_pos != -1 && v.length >= dot_pos+1+optn.scale)
          return "invalid";

        v = parseFloat(v);

        if (v < optn.min)
          return "low";
        if (v > optn.max)
          return "high";
      }

      return "ok";
    }

  });
};})(jQuery);
