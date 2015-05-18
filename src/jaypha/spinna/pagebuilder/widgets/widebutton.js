
$(function()
{
  $('.wide-button').each(function()
  {
    $('.wide-button-content',this).height($(this).height());
    $('.wide-button-content',this).width($(this).width());
  });
});
