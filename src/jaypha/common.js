// Written in javascript
/*
 * Common JS code
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

//----------------------------------------------------------------------------
// Is needle in haystack?

function inArray(needle, haystack)
{
  for (i in haystack)
    if (needle == haystack[i])
      return true;
  return false;
}

//----------------------------------------------------------------------------
// Equialises the height/width of an element to the largest one.

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


//----------------------------------------------------------------------------
// Sets the focus to the first form element on the page.

$(function()
{
  $('form:first *:input[type!=hidden]:first').focus();
});