

module jaypha.spinna.modules.catalogue;

import std.regex;
public import std.conv;
public import std.array;

public import jaypha.types;
import std.algorithm;
import jaypha.algorithm;

import std.stdio;
struct Catalogue(string table_prefix, DB)
{
  this(ref DB _database) { database = _database; }

  //-----------------------------------------------------------------------------
  // Items
  //-----------------------------------------------------------------------------

  strstr get(ulong id)
  {
    return database.get(table_prefix ~ "_catalogue", id);
  }

  //-----------------------------------------------------------------------------

  strstr find(string uri_title)
  {
    return database.query_row("select * from " ~ table_prefix ~ "_catalogue where uri_title = "~database.quote(uri_title));
  }

  //-----------------------------------------------------------------------------

  ulong save(ulong id, strstr data)
  {
    data["uri_title"] = get_uri_title(data["title"]);
    
    if (id)
    {
      auto oldtitle = database.query_value("select uri_title from " ~ table_prefix ~ "_catalogue where id="~to!string(id));
      if (oldtitle != data["uri_title"])
      {
        database.query("update " ~ table_prefix ~ "_uri_redirect set newtitle="~database.quote(data["uri_title"])~" where newtitle="~database.quote(oldtitle));
        database.quick_insert(table_prefix ~ "_uri_redirect", ["oldtitle":oldtitle, "newtitle":data["uri_title"]]);
      }
      database.set(table_prefix ~ "_catalogue", data, id);
    }
    else
      id = database.quick_insert(table_prefix ~ "_catalogue", data);
    return id;
  }

  //-----------------------------------------------------------------------------

  void remove(ulong id)
  {
    database.remove(table_prefix ~ "_catalogue", id);
  }

  //-----------------------------------------------------------------------------

  auto get_items()
  {
    return database.query("select * from " ~ table_prefix ~ "_catalogue where type='item' order by title");
  }

  //-----------------------------------------------------------------------------

  auto get_categories()
  {
    return database.query("select * from " ~ table_prefix ~ "_catalogue where type='category' order by title");
  }

  //-----------------------------------------------------------------------------

  auto get_items_in_category_as_range(ulong category_id, bool visible_only = true)
  {
    return database.query
    (
      "select * from " ~ table_prefix ~ "_catalogue as I "
      "left_join " ~ table_prefix ~ "_links as L on (L.item = I.id) where category="~to!string(category_id)~(visible_only?" and visible=1":"")~" order by L.list_order"
    );
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

  strstr[] get_items_in_category(ulong category_id)
  {
    return database.query_data
    (
      "select * from " ~ table_prefix ~ "_links as L left join " ~ table_prefix ~ "_catalogue as I "
      "on (I.id = L.item) where L.category="~to!string(category_id)~" order by L.list_order"
    );
  }

  //-----------------------------------------------------------------------------

  strstr[] get_categories_for_item(ulong item_id)
  {
    return database.query_data
    (
      "select * from " ~ table_prefix ~ "_links as L left join " ~ table_prefix ~ "_catalogue as I "
      " on (I.id = L.category) where L.item="~to!string(item_id)
    );
  }

  //-----------------------------------------------------------------------------

  void update_category_items(ulong id, ulong[] list)
  {
    update_category_list("item", "category", id, list);
  }

  //-----------------------------------------------------------------------------

  void update_item_categories(ulong id, ulong[] list)
  {
    update_category_list("category", "item", id, list);
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
    //writeln(category_id, new_order);
    auto cid=to!string(category_id);
    foreach (i,id ; new_order)
      //writeln("update " ~ table_prefix ~ "_links as L set list_order="~to!string(i)~" where L.category="~cid~" L.item="~to!string(id));
      database.query("update " ~ table_prefix ~ "_links as L set list_order="~to!string(i)~" where L.category="~cid~" and L.item="~to!string(id));
  }

  //-----------------------------------------------------------------------------

  private:
    DB database;
}

string get_uri_title(string title)
{
  // replaces anything not a letter, or number with one hyphen

  auto r = regex(r"[^A-Za-z0-9]+","g");
  return replace(title,r,"-");
}

