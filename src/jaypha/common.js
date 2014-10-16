


function in_array(needle, haystack)
{
  for (i in haystack)
    if (needle == haystack[i])
      return true;
  return false;
}

(function($){$.fn.equalise = function(dim)
{
  if (dim != "height" && dim != "width")
    return this;
  var max = 0;
  return this.each(function()
  {
    if ($(this)[dim]() > max)
      max = $(this)[dim]();
  })[dim](max);
};})(jQuery);
