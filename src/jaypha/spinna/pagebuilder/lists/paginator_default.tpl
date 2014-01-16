<%
  ulong start_num = ((page_number <= 2) ? 1 : (page_number - 2));

  ulong finish_num = start_num + 5;
  if (finish_num > num_pages)
  {
    finish_num = num_pages+1;
    if (finish_num <= 5)
      start_num = 1;
    else
      start_num = finish_num - 5;
  }
%>
<table class='paginator paginator-<%=name%>'>
 <tbody>
  <tr>
   <%
      if (page_number != 1)
      {
        output.print("<td>",html_link(link(1),encode_special("<<")),"</td>");
        output.print("<td>",html_link(link(page_number-1),encode_special("<")),"</td>");
      }
   
      foreach (i; start_num..finish_num)
      {
        if (i == page_number)
          output.print("<td class='paginator-current'>",i,"</td>");
        else
          output.print("<td>",html_link(link(i),to!string(i)),"</td>");
      }

      if (page_number != num_pages)
      {
        output.print("<td>",html_link(link(page_number+1),encode_special(">")),"</td>");
        output.print("<td>",html_link(link(num_pages),encode_special(">>")),"</td>");
      }
   %>
  </tr>
 </tbody>
</table>
