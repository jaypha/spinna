<table class='layout default-widgets'>
 <% foreach (i,w; widgets) { %>
  <tr class='<%=w.name%>-valid-indicator'>
   <td><%=w.label%></td><td><% w.copy(output); %></td><td><% if (w.required) { %> <span class='required'>*</span> <% } %></td><td class='<%=w.name%>-valid-indicator no-show'>&lt;--</td>
  </tr>
 <% } %>
</table>
