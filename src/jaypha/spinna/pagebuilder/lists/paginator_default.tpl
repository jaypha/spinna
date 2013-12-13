<%
  uint start_num = page_number - 2;
  if (start_num < 1)
    start_num = 1;

  finish_num = start_num + 5;
  if (finish_num > num_pages)
  {
    finish_num = num_pages+1;
    start_num = finish_num - 5;
    if (start_num < 1)
      start_num = 1;
  }
%>

<table class='paginator paginator-<%=name%>'>
 <tbody>
  <tr>
   <%
      if (page_no != 1)
      {
        output.print("<td>",html_link(link(1),"<<"),"</td>");
        output.print("<td>",html_link(link(page_number-1),"<"),"</td>");
      }
   
      foreach (i; start_num..finish_num)
      {
        if (i == page_number)
          output.print("<td class='paginator-current'>",i,"</td>");
        else
          output.print("<td>",html_link(link(i),i),"</td>");
      }

      if (page_no != num_pages)
      {
        output.print("<td>",html_link(link(page_number+1),">"),"</td>");
        output.print("<td>",html_link(link(num_pages),">>"),"</td>");
      }
   %>
  </tr>
 </tbody>
</table>
