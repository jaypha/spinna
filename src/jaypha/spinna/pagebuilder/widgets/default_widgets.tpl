<table class='default-widgets'>
 <col class='required-column'/>
 <col class='label-column'/>
 <col class='field-column'/>
 <tbody>
 <% foreach (i,w; widgets) { %>
  <tr class='<%=w.name%>-valid-indicator'>
   <td class='label'><% if (w.required) { %> <span class='required'>*</span> <% } %></td>
   <td class='label'><%=w.label%></td>
   <td class='field'><% w.copy(output); %></td>
   <td class='label <%=w.name%>-valid-indicator no-show'>&lt;--</td>
  </tr>
 <% } %>
 </tbody>
</table>
