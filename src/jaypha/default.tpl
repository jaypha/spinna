<div class='header'>
 <h1>PrimaLinx Estore Site</h1>
</div>

<% skin_body.copy(output); %>

<div class='footer'>
 Copyright &copy; 2013 PrimaLinx. All rights reserved
</div>


<div id="message-dialog" class="jqmWindow">
 <h4>PrimaLinx</h4>
 <div id='message-content'>
  <% if ("message_id" in request.gets && session["messages"].is_set(request.gets["message_id"]))
    {
       output.print(session["messages"].get_str(request.gets["message_id"]));
    }
  %>
 </div>
<div style='text-align:center'>
  <button class='message-ok-button' type='button'>OK</button></div>
</div>

<script type='text/javascript'>

$(function()
{
  $('#message-dialog').jqm();$('#message-dialog').jqmAddClose('#message-dialog .message-ok-button');
  <% if ("message_id" in request.gets && session["messages"].is_set(request.gets["message_id"]))
  {
    output.print("$('#message-dialog').jqmShow();");
    session["messages"].unset(request.gets["message_id"]);
  } %>
});

</script>

