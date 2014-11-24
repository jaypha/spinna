
(function($){$.fn.changeIcon = function(mode)
{
  return this.each(function()
  {
    if (mode != "hot" && mode != "normal" && mode != "disabled") return;
    if (!$(this).hasClass("icon")) return;
    var src = $(this).attr("src");
    $(this).attr("src",src.replace(/(hot|disabled|normal)/, mode));
  });
};})(jQuery);
