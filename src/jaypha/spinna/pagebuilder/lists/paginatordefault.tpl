<%
  ulong startNum = ((pageNumber <= 2) ? 1 : (pageNumber - 2));

  ulong finishNum = startNum + 5;
  if (finishNum > numPages)
  {
    finishNum = numPages+1;
    if (finishNum <= 5)
      startNum = 1;
    else
      startNum = finishNum - 5;
  }
%>
<table class='paginator paginator-<%=name%>'>
 <tbody>
  <tr>
   <%
      if (pageNumber != 1)
      {
        output.print("<td>",htmlLink(link(1),encodeSpecial("<<")),"</td>");
        output.print("<td>",htmlLink(link(pageNumber-1),encodeSpecial("<")),"</td>");
      }
   
      foreach (i; startNum..finishNum)
      {
        if (i == pageNumber)
          output.print("<td class='paginator-current'>",i,"</td>");
        else
          output.print("<td>",htmlLink(link(i),to!string(i)),"</td>");
      }

      if (pageNumber != numPages)
      {
        output.print("<td>",htmlLink(link(pageNumber+1),encodeSpecial(">")),"</td>");
        output.print("<td>",htmlLink(link(numPages),encodeSpecial(">>")),"</td>");
      }
   %>
  </tr>
 </tbody>
</table>
