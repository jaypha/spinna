
 <div class='jqm-border-box'>
  <div class='jqm-header'>
    <% if (header) header.copy(output); %>
  </div>
  <hr class='p'/>
  <div class='dialog-content'>
    <% if (content) content.copy(output); %>
  </div>
  <div class='jqm-footer'>
   <button class='dialog-ok-button' type='button'>OK</button>
  </div>
 </div>

<script type='text/javascript'>
$(function()
{
  $('#<%=id%>').jqm();
  $('#<%=id%>').jqmAddClose('#<%=id%> .dialog-ok-button');
  $('#about-btn').click(function(){ $('#about-dialog').jqmShow(); });
});
</script>
