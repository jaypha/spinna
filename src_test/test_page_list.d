
module test_page_list;

import std.stdio;
import jaypha.io.output_stream;

import jaypha.types;

import jaypha.spinna.pagebuilder.lists.simple_list;

import jaypha.spinna.pagebuilder.lists.table_list;
import jaypha.spinna.pagebuilder.lists.paged_list;

class MyLSource : ListSource
{
  this(strstr[] _data) { data = _data; }

  @property string[string] front() { return data[i+offset]; }
  @property bool empty() { return i>= psize || i+offset > data.length; }
  void popFront() { ++i; }

  void set_page_size(ulong size) { psize = (size == 0?data.length:size); }
  void set_page(ulong num) { offset = psize*(num-1); }
  @property ulong num_pages() { return (data.length + psize - 1)/psize; }

  void reset() { i = 0; }

  private:
    strstr[] data;
    ulong i = 0;
    ulong psize = 0;
    ulong offset = 0;
    
}



void test_list()
{
  auto output = new TextBuffer!string();

  auto ds = new MyLSource
  (
    [
      [ "label" : "hello", "zonk" : "honk" ],
      [ "label" : "beetle", "zonk" : "tonk" ],
      [ "label" : "tweetle", "zonk" : "tank" ],
      [ "label" : "twobird", "zonk" : "crank" ],
      [ "label" : "accost", "zonk" : "plank" ],
      [ "label" : "zigzag", "zonk" : "pluto" ]
    ]
  );

  auto sl = new SimpleList!"pagelist.tpl"("testlist", ds);

  ds.set_page_size(2);
  ds.set_page(2);
  writeln("pages - ",ds.num_pages);
  
  //StrHash request;

  //request["hello-page"] = "3";
  //auto pg = new_paginator("hello", "abc.com", request);

  //pg.num_pages = 12;


  //writeln("page size: ",pg.page_size);
  //writeln("display all: ",pg.display_all);
  //writeln("page number: ",pg.page_number);

  sl.copy(output);
  writeln(output.data);
}


class MyTSource : TableSource
{
  this(string[][] _data) { data = _data; }

  @property string[] front() { return data[i+offset]; }
  @property bool empty() { return i>= psize || i+offset > data.length; }
  void popFront() { ++i; }

  void set_page_size(ulong size) { psize = (size == 0?data.length:size); }
  void set_page(ulong num) { offset = psize*(num-1); }
  @property ulong num_pages() { return (data.length + psize - 1)/psize; }

  @property string[] headers() { return [ "label", "thwonk" ]; }

  void reset() { i = 0; }

  private:
    string[][] data;
    ulong i = 0;
    ulong psize = 0;
    ulong offset = 0;
    
}


void test_paged_list()
{
  auto output = new TextBuffer!string();

  StrHash request;

  request["hello-page"] = "2";
  request["hello-page-size"] = "3";


  auto ds = new MyTSource
  (
    [
      [ "hello", "honk" ],
      [ "beetle", "tonk" ],
      [ "tweetle", "tank" ],
      [ "twobird", "crank" ],
      [ "accost", "plank" ],
      [ "zigzag", "pluto" ],
      [ "mumbo", "jumbo" ]
    ]
  );

  auto sl = new TableList("tablelist", ds);

  auto pl = new PagedList!("jaypha/spinna/pagebuilder/lists/paged_default.tpl","jaypha/spinna/pagebuilder/lists/paginator_default.tpl")
  ("hello", "abc.com", request);
  pl.content = sl;

  pl.copy(output);
  writeln(output.data);
}