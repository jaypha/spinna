$(function()
{
  $(".hotable").mouseover(function()
  {
    var i = $("img",this);
    var src = i.attr("src");
    i.attr("src",src.replace(/normal/, "hot"));
    $(this).parent().addClass("highlight");
  });

  $(".hotable").mouseout(function()
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
      $(this).removeClass("hotable");
      $(this).addClass("disabled");
    });
  };})(jQuery);

  (function($){$.fn.EnableIcon = function()
  {
    return this.each(function()
    {
      var src = $("img",this).attr("src");
      $("img",this).attr("src",src.replace(/disabled/, "normal"));
      $(this).addClass("hotable");
      $(this).removeClass("disabled");
    });
  };})(jQuery);

  $('a.disabled').click(function() { return false; });
});
