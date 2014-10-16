 <table>
  <tr>
   <td class='left-column' style='vertical-align:bottom'>
    &#8595; Currently Selected 
   </td>
   <td class='right-column'>
    <input class='selector-search selector-search-empty' value='Search'/>
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>
    <ul class='selector-box selected'>
     <%
      foreach (o; options)
      {
        output.print("<li class='selected-",o.value,"' style='display:none'>",encodeSpecial(o.label),"</li>");
      }
     %>
    </ul>
   </td>
   <td class='middle-column'>
    <ul class='selector-box unselected'>
     <%
      foreach (o; options)
      {
        output.print("<li class='unselected-",o.value,"' style='display:none'>",encodeSpecial(o.label),"</li>");
      }
     %>
    </ul>
   </td>
   <td class='selector-buttons'>
    <button type='button' class='selector-all'>Select All</button><br/>
    <button type='button' class='selector-clear'>Clear All</button><br/>
   </td>
  </tr>
 </table>
 <div style='display:none'>
  <%
    foreach (o; options)
    {
      output.print("<input type='checkbox' name='",name,"' value='",o.value,"'",((selected.find(o.value).empty)?"":" checked='checked'"),"/>");
    }
  %>
 </div>
