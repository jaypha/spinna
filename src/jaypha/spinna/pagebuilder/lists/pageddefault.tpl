<div class='page-bar'>
  <div style='float:left'>Page <%=paginator.pageNumber%> of <%=paginator.numPages %></div>
  <div style='float:right'><% paginator.copy(output); %></div>
  <div style='clear:both'></div>
</div>
<% content.copy(output); %>
<div class='page-bar'>
  <div style='float:left'>Page <%=paginator.pageNumber%> of <%=paginator.numPages %></div>
  <div style='float:right'><% paginator.copy(output); %></div>
  <div style='clear:both'></div>
</div>
