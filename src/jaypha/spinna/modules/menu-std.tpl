<table class='menu-table'>
  <tbody>
    <tr>
      <%
        foreach (j,m; menu)
        {
          if (m.type == MenuItem.LinkType.link)
            output.print("<td><a href='",encode_special(m.link),"'>",encode_special(m.label),"</a></td>");
          else
            output.print("<td><a onclick='",encode_special(m.link),"'>",encode_special(m.label),"</a></td>");
        }
      %>
    </tr>
  </tbody>
</table>
