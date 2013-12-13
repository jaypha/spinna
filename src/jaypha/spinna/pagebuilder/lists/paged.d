<?php
/******************************************************************************
 * components/html/lists/paged.inc
 *
 * Copyright (C) 2010  Fairfax eCommerce Pty Ltd. All rights reserved.
 *****************************************************************************/

require_once "components/html/widgets/paginator.inc";

class PagedList : HtmlElement
{
  uint default_page_size = PAGE_SIZE_DEFAULT;
  string name;

  this(string _name)
  {
    super();
    id = _name~"-paged";
    add_class("paged-list");
    name = _name;
    paginator = new Paginator(name, get_base_uri());
  }

  copy(TextOutputStream output)
  {
    if (name~"-displayall" in request.request)
      ds.set_retrieve_all();
    else if (name~"-page-size" in request.request)
      ds.set_page_size(request.request[name~"-page-size"]);
    else
      ds.set_page_size(PAGE_SIZE_DEFAULT);
    ds.set_current_page(paginator.page_number);
    mixin();
  }
}

class FWSPagedList extends FWSTaggedObject
{
  public $PageSizeDefault = PAGE_SIZE_DEFAULT;

  //---------------------------------------------------------------------------

  function __construct($name)
  {
    parent::__construct("$name-paged");
    $this->AddClass("paged-list");
    $this->children["name"] = $name;
    $this->children["paginator"] = new FWSPaginator($name, getBaseUri());
    $this->Template = "components/templates/paged.tpl";
    $this->children["pagebar"] = "components/templates/paged_list_bar.tpl";
  }

  //---------------------------------------------------------------------------

  function Display()
  {
    assert($this->Pages);
    
    $ds = $this->Pages->DataSource;
    
    if (isset($_GET["$this->Name-displayall"]))
      $ds->SetDisplayAll();
    if (isset($_GET["$this->Name-page-size"]))
      $ds->SetPageSize($_GET["$this->Name-page-size"]);
    else
      $ds->SetPageSize($this->PageSizeDefault);

    $ds->SetCurrentPage($this->Paginator->PageNo);
    $ds->DataBind();

    $this->Paginator->NumPages = $ds->GetNumPages();
    parent::Display();
  }
  
  //---------------------------------------------------------------------------

  function __get($p)
  {
    switch ($p)
    {
      case "Pages":
        return $this->children["pages"];
      case "Paginator":
        return $this->children["paginator"];
      case "Name":
        return $this->children["name"];
      default:
        parent::__get($p);
    }
  }

  //---------------------------------------------------------------------------
  
  function __set($p, $v)
  {
    switch ($p)
    {
      case "Pages":
        $this->children["pages"] = $v;
        break;
      default:
        parent::__set($p, $v);
    }
  }

  //---------------------------------------------------------------------------
}

?>
