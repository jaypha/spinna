<table class='menu-table'>
  <tbody>
    <tr>
      <%
        foreach (j,m; menu)
        {
          final switch (m.type)
          {
            case MenuItem.LinkType.Link:
              output.print("<td><a href='",encodeSpecial(m.link),"'>",encodeSpecial(m.label),"</a></td>");
              break;
            case MenuItem.LinkType.Script:
              output.print("<td><a onclick='",encodeSpecial(m.link),"'>",encodeSpecial(m.label),"</a></td>");
              break;
            case MenuItem.LinkType.Label:
              output.print("<td>",encodeSpecial(m.label),"</td>");
              break;
            case MenuItem.LinkType.Separator:
              output.print("<td>&nbsp;</td>");
          }
        }
      %>
    </tr>
  </tbody>
</table>
