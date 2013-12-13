write("<div class='header'>\n <h1>PrimaLinx Estore Site</h1>\n</div>\n\n");
 skin_body.copy(output); 
write("\n\n<div class='footer'>\n Copyright &copy; 2013 PrimaLinx. All rights reserved\n</div>\n\n\n<div id=\"message-dialog\" class=\"jqmWindow\">\n <h4>PrimaLinx</h4>\n <div id='message-content'>\n  ");
 if ("message_id" in request.gets && session["messages"].is_set(request.gets["message_id"]))
    {
       output.print(session["messages"].get_str(request.gets["message_id"]));
    }
  
write("\n </div>\n<div style='text-align:center'>\n  <button class='message-ok-button' type='button'>OK</button></div>\n</div>\n\n<script type='text/javascript'>\n\n$(function()\n{\n  $('#message-dialog').jqm();$('#message-dialog').jqmAddClose('#message-dialog .message-ok-button');\n  ");
 if ("message_id" in request.gets && session["messages"].is_set(request.gets["message_id"]))
  {
    output.print("$('#message-dialog').jqmShow();");
    session["messages"].unset(request.gets["message_id"]);
  } 
write("\n});\n\n</script>\n\n");

