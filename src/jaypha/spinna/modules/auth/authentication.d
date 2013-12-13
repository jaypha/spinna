
module jaypha.spinna.modules.auth.authentication;

import jaypha.types;

import jaypha.spinna.global;

strstr authenticate(DB)(ref DB database, string username, string password, bool login=false)
{
  auto response = database.query_row("select id,roles from authenticate where username="~database.quote(username)~" and password="~database.quote(password));
  if (response && login) session["login"].set_str("auth_id", response["id"]);
  return response;
}

bool is_logged_in()
{
  return session.has("login");
}
