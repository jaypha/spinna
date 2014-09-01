/*
 * JS for icon buttons.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

$(function()
{
  $("body").on("mouseover", ".hotable", function()
  {
    var i = $("img",this);
    var src = i.attr("src");
    i.attr("src",src.replace(/normal/, "hot"));
    $(this).parent().addClass("highlight");
  });

  $("body").on("mouseout", ".hotable", function()
  {
    var i = $("img",this);
    var src = i.attr("src");
    i.attr("src",src.replace(/hot/, "normal"));
    $(this).parent().removeClass("highlight");
  });

  (function($){$.fn.DisableIcon = function()
  {
    return this.each(function()
    {
      var src = $("img",this).attr("src");
      $("img",this).attr("src",src.replace(/(hot|normal)/, "disabled"));
      $("a",this).click(function( e ){e.preventDefault();});
      $(this).removeClass("hotable");
      $(this).addClass("disabled");
      $(this).parent().removeClass("highlight");
    });
  };})(jQuery);

  (function($){$.fn.EnableIcon = function()
  {
    return this.each(function()
    {
      var src = $("img",this).attr("src");
      $("img",this).attr("src",src.replace(/disabled/, "normal"));
      $("a",this).off("click");
      $(this).addClass("hotable");
      $(this).removeClass("disabled");
    });
  };})(jQuery);

  $('a.disabled').click(function() { return false; });
});
