/*
 * Detrmines which function to call based on the path
 *
 * Copyright (C) 2014 Jaypha.
 */

/*
 * Generated file. Do not edit
 */

module gen.router;

public import jaypha.spinna.router_tools;
import std.functional;
import std.exception;

static import pages;
static import jaypha.spinna.readback;

auto find_route(string path, string method)
{
  mixin(match_static_route!("/", "get", "root.home.get", "pages.getHome", "0", ""));
  mixin(match_static_route!("/html", "get", "root.html.get", "pages.getHtml", "0", ""));
  mixin(match_static_route!("/json", "get", "root.json.get", "pages.getJson", "0", ""));
  mixin(match_static_route!("/readback", "get", "root.readback.get", "jaypha.spinna.readback.getReadback", "0", ""));
  return ActionInfo(null);
}
