<table <% if (!id.empty) output.print("id='",id,"'"); %> class='default-widgets form-frag-std-layout'>
 <col class='required-column'/>
 <col class='label-column'/>
 <col class='field-column'/>
 <tbody>
 <% foreach (i,w; widgets) { %>
   <% if (w.name is null) { %>
    <tr><td colspan='4'><%=w.label%></td></tr>
   <% } else { %>
    <tr class='<%=w.name%>-valid-indicator'>
     <td class='label'><span class='required' <% if (!w.required) output.print("style='visibility:hidden'");%> >*</span></td>
     <td class='label'><%=w.label%></td>
     <td class='field'><% w.copy(output); %></td>
     <td class='label <%=w.name%>-invalid-msg' style='display:none'>&lt;--<span></span></td>
    </tr>
    <script>
     $('#<%=w.id%>').data("widget").onValidate = function()
     {
        if (this.valid)
        {
          $(".<%=w.name%>-valid-indicator").removeClass("bad-input");
          $(".<%=w.name%>-invalid-msg").hide();
        }
        else
        {
          $(".<%=w.name%>-valid-indicator").addClass("bad-input");
          $(".<%=w.name%>-invalid-msg span").text(this.msg);
          $(".<%=w.name%>-invalid-msg").show();
        }
     }
    </script>
 <% } } %>
 </tbody>
</table>
