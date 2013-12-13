

void default_error_handler(HttpRequest request, uint code, string message)
{
  response.status(code);

  Document doc;
  auto body = make_error_document(doc);
  
  body.set(code, "code");
  body.set(message, "message");
  
  transfer(doc,response);
}

