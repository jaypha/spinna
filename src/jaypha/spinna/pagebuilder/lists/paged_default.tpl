<div class='page-bar'>
  <div style='float:left'>Page <%=paginator.page_number%> of <%=paginator.num_pages %></div>
  <div style='float:right'><% paginator.copy(output); %></div>
  <div style='clear:both'></div>
</div>
<% content.copy(output); %>
<div class='page-bar'>
  <div style='float:left'>Page <%=paginator.page_number%> of <%=paginator.num_pages %></div>
  <div style='float:right'><% paginator.copy(output); %></div>
  <div style='clear:both'></div>
</div>
