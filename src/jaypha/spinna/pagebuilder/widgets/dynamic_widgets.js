// Written in Javascript
/*
 * Make widgets JS for string widgets.
 *
 * Part of the Spinna framework
 *
 * Copyright 2013-4 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


function makeWidgetFromMeta(idPrefix, metadata)
{
  var jq;
  switch(metadata.type)
  {
    case "string":
      if ("subtype" in metadata)
        switch (metadata.subtype)
        {
          case "textarea":
            jq = $("<textarea class='widget text-widget' name='"+name+" id='"+idPrefix+metadata.name+"'></textarea>");
            new StringWidget(jq,metadata);
            if ("default" in metadata)
              jq.text(metadata.default);
            break;

          case "password":
            jq = makeStringWidget(idPrefix+metadata.name, metadata.name, metadata, metadata.default);
            jq.attr('type') = "password";
            break;
        }
      else
        jq = makeStringWidget(idPrefix+metadata.name, metadata.name, metadata, metadata.default);
      break;
    //-----------
    case "enum":
      jq = makeDropdownListWidget(idPrefix+metadata.name, metadata.name, metadata, metadata.options, metadata.default);
      break;
  }

  return jq;
}
