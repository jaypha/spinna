//Written in Javascript
/*
 * JS for sort widgets
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

function sortUpdate(id, name, formid)
{
  var a = $('#'+id).sortable('toArray');
  var s = a[0].replace(id+'-','');
  for (var i=1; i<a.length; ++i)
    s=s+','+a[i].replace(id+'-','');
  $('#'+formid+" input[name='"+name+"']").val(s);
}
