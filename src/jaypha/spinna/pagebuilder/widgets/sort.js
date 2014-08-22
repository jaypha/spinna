/******************************************************************************
 *
 * Sort Widget
 *
 *****************************************************************************/

function sort_update(id, name, formid)
{
  var a = $('#'+id).sortable('toArray');
  var s = a[0].replace(id+'-','');
  for (var i=1; i<a.length; ++i)
    s=s+','+a[i].replace(id+'-','');
  $('#'+formid+" input[name='"+name+"']").val(s);
}
