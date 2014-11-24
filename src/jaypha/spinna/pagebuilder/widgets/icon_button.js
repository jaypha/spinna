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
    $(".icon",this).changeIcon("hot");
    $(this).parent().addClass("highlight");
  });

  $("body").on("mouseout", ".hotable", function()
  {
    $(".icon",this).changeIcon("normal");
    $(this).parent().removeClass("highlight");
  });

  (function($){$.fn.disableButton = function()
  {
    return this.each(function()
    {
      $(".icon",this).changeIcon("disabled");
      $(".inner",this).click(function( e ){e.preventDefault();});
      $(".inner",this).removeClass("hotable");
      $(this).addClass("disabled");
      $(this).removeClass("highlight");
    });
  };})(jQuery);

  (function($){$.fn.enableButton = function()
  {
    return this.each(function()
    {
      $(".icon",this).changeIcon("normal");
      $(".inner",this).off("click");
      $(".inner",this).addClass("hotable");
      $(this).removeClass("disabled");
    });
  };})(jQuery);

  $('.inner.disabled').click(function() { return false; });
});

