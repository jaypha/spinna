

module jaypha.spinna.modules.catalogue;

import std.regex;
public import std.conv;
public import std.array;

public import jaypha.types;
import std.algorithm;
import jaypha.algorithm;

import jaypha.dbms.dynamic_query;


struct Catalogue(Database)
{
  string table_prefix;
  Database database;

  this(Database db, string p) { database = db; table_prefix = p; }

  //-----------------------------------------------------------------------------
  // Items
  //-----------------------------------------------------------------------------

  bool exists(ulong id)
  {
    return (get(id) !is null);
  }

  strstr get(ulong id)
  {
    return database.query_row("select * from "~table_prefix ~ "_catalogue where id="~to!string(id));
  }

  //-----------------------------------------------------------------------------

  strstr find(string uri_title)
  {
    return database.query_row("select * from " ~ table_prefix ~ "_catalogue where uri_title = "~database.quote(uri_title));
  }

  //-----------------------------------------------------------------------------

  ulong save(strstr data)
  {
    if ("title" in data)
      data["uri_title"] = get_uri_title(data["title"]);
    return database.quick_insert(table_prefix ~ "_catalogue", data);
  }

  //-----------------------------------------------------------------------------
  
  void save(strstr data, ulong id)
  {
    if ("title" in data)
      data["uri_title"] = get_uri_title(data["title"]);
    
    if ("title" in data)
    {
      auto oldtitle = database.query_value("select uri_title from " ~ table_prefix ~ "_catalogue where id="~to!string(id));
      if (oldtitle != data["uri_title"])
      {
        database.query("update " ~ table_prefix ~ "_uri_redirect set newtitle="~database.quote(data["uri_title"])~" where newtitle="~database.quote(oldtitle));
        database.quick_insert(table_prefix ~ "_uri_redirect", ["oldtitle":oldtitle, "newtitle":data["uri_title"]]);
      }
    }
    database.set(table_prefix ~ "_catalogue", data, id);
  }

  //-----------------------------------------------------------------------------

  void remove(ulong id)
  {
    database.remove(table_prefix ~ "_catalogue", id);
  }

  //-----------------------------------------------------------------------------

  auto get_everything()
  {
    DynamicQuery dq;
    dq.table = table_prefix ~ "_catalogue";
    dq.add_sorting("title");
    return dq;
  }

  //-----------------------------------------------------------------------------

  auto get_items()
  {
    auto dq = get_everything();
    dq.wheres ~= "type='item'";
    return dq;
  }

  //-----------------------------------------------------------------------------

  auto get_categories()
  {
    auto dq = get_everything();
    dq.wheres ~= "type='category'";
    return dq;
  }

  //-----------------------------------------------------------------------------
/*
  auto get_items_in_category_as_range(ulong category_id, bool visible_only = true)
  {
    return database.query
    (
      "select * from " ~ table_prefix ~ "_catalogue as I "
      "left_join " ~ table_prefix ~ "_links as L on (L.item = I.id) where category="~to!string(category_id)~(visible_only?" and visible=1":"")~" order by L.list_order"
    );
  }
*/
  auto get_items_in_category_as_query(ulong category_id, bool visible_only = true)
  {
    DynamicQuery dq;
    dq.table = table_prefix ~ "_links as L";
    dq.add_table(table_prefix ~ "_catalogue as I", dq.JoinType.Left, "L.item = I.id");
    dq.wheres ~= "category="~to!string(category_id);
    if (visible_only)
      dq.wheres ~= "visible=1";
    dq.add_sorting("L.list_order");
    return dq;
  }

  //-----------------------------------------------------------------------------

  string find_redirect(string old_title)
  {
    return database.query_value("select newtitle from " ~ table_prefix ~ "_uri_redirect where oldtitle="~database.quote(old_title));
  }

  //-----------------------------------------------------------------------------

  void make_visible(ulong[] ids)
  {
    if (ids.length == 0)
      database.query("update " ~ table_prefix ~ "_catalogue set visible = 1");
    else
      database.query("update " ~ table_prefix ~ "_catalogue set visible = 1 where " ~ database.in_list(ids));
  }

  //-----------------------------------------------------------------------------

  void make_invisible(ulong[] ids)
  {
    if (ids.length == 0)
      database.query("update " ~ table_prefix ~ "_catalogue set visible = 0");
    else
      database.query("update " ~ table_prefix ~ "_catalogue set visible = 0 where " ~ database.in_list(ids));
  }

  //-----------------------------------------------------------------------------

  void flip_visibility(ulong[] ids)
  {
    if (ids.length != 0)
      database.query("update " ~ table_prefix ~ "_catalogue set visible = not visible where " ~ database.in_list(ids));
  }

  //-----------------------------------------------------------------------------
  // Categories
  //-----------------------------------------------------------------------------

  // Simple list of items.
  strstr[] get_items_in_category(ulong category_id)
  {
    return database.query_data
    (
      "select I.id,title,short_title from " ~ table_prefix ~ "_links as L left join " ~ table_prefix ~ "_catalogue as I "
      "on (I.id = L.item) where L.category="~to!string(category_id)~" order by L.list_order"
    );
  }

  //-----------------------------------------------------------------------------

  // Simple list of categories.
  strstr[] get_categories_for_item(ulong item_id)
  {
    return database.query_data
    (
      "select I.id,title,short_title from " ~ table_prefix ~ "_links as L left join " ~ table_prefix ~ "_catalogue as I "
      " on (I.id = L.category) where L.item="~to!string(item_id)
    );
  }

  //-----------------------------------------------------------------------------

  void update_category_items(ulong category_id, ulong[] list)
  {
    update_category_list("item", "category", category_id, list);
  }

  //-----------------------------------------------------------------------------

  void update_item_categories(ulong id, ulong[] list)
  {
    update_category_list("category", "item", id, list);
  }

  //-----------------------------------------------------------------------------

  void add_item_to_category(ulong category_id, ulong id)
  {
    database.query
    (
      "insert into " ~ table_prefix ~ "_links (`category`,`item`) values "~
      "("~to!string(category_id)~","~to!string(id)~")"
    );
  }

  //-----------------------------------------------------------------------------

  void update_category_list(string list_column, string ref_column, ulong reference, ulong[] list)
  {
    ulong[] current = database.query_column!(ulong)("select "~list_column~" from " ~ table_prefix ~ "_links where "~ref_column~"="~to!string(reference));

    if (current == list) return;

    string query = "delete from " ~ table_prefix ~ "_links where "~ref_column~"="~to!string(reference);
    if (list.length)
      query ~= " and not "~list_column~" in "~database.in_list(list);

    database.query(query);

    auto new_stuff = diff(list, current);
    if (new_stuff.length)
    {
      database.query
      (
        "insert into " ~ table_prefix ~ "_links ("~ref_column~","~list_column~") values "~
        new_stuff.map!((a) => ("("~to!string(reference)~","~to!string(a)~")")).join(",")
      );
    }
  }

  //-----------------------------------------------------------------------------
  // Ordering
  //-----------------------------------------------------------------------------

  ulong[] get_item_ordering(ulong category_id)
  {
    return database.query_column!(ulong)
    (
      "select title, I.id from " ~ table_prefix ~ "_links as L left join, " ~ table_prefix ~ "_catalogue as I on (L.item = I.id) "
      "where L.item = I.id and L.category="~to!string(category_id)~
      "order by L.list_order"
    );
  }


  //-----------------------------------------------------------------------------

  void save_item_ordering(ulong category_id, ulong[] new_order)
  {
    auto cid=to!string(category_id);
    foreach (i,id ; new_order)
      database.query("update " ~ table_prefix ~ "_links set list_order="~to!string(i)~" where category="~cid~" and item="~to!string(id));
  }
}

string get_uri_title(string title)
{
  // replaces anything not a letter, or number with one hyphen

  auto r = regex(r"[^A-Za-z0-9]+","g");
  return replace(title,r,"-");
}

