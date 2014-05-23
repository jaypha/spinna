
 <div class='jqm-border-box'>
  <div class='jqm-header'>
    <% if (header) header.copy(output); %>
  </div>
  <hr class='p'/>
  <div class='dialog-content'>
    <% if (content) content.copy(output); %>
  </div>
  <% if (footer) { %>
   <div class='jqm-footer'>
    <% footer.copy(output); %>
   </div>
  <% } %>
 </div>
