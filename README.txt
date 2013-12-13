Jaypha Spinna Library ReadMe

by Jason den Dulk

= Spinna =

Spinna is a web server framework for the D language.

Spinna is designed to be able to work with an external web server via FCGI, and can be run
from the console for debugging purposes.

Spinna is licensed under the Boost License.

== Modules ==

Spinna modules (not provided by third parties) are kept under the 'jaypha' umbrella package.
Modules specific to the Spinna server are under the jaypha.spinna package. Other modules
are more generic and can be used in non-Spinna projects.

- jaypha.types
- jaypha.conv
- jaypha.rnd
- jaypha.string
- jaypha.embed
- jaypha.container.hash
- jaypha.io.lines
- jaypha.io.print
- jaypha.io.serialize
- jaypha.http.cookie
- jaypha.http.exception
- jaypha.html.entity
- jaypha.html.helpers
- jaypha.mime.header
- jaypha.fcgi.loop
- jaypha.fcgi.c.fcgiapp.di
- jaypha.spinna.router_tools
- jaypha.spinna.global
- jaypha.spinna.request
- jaypha.spinna.response
- jaypha.spinna.session
- jaypha.spinna.process

All modules in the jaypha package umbrella are Copyright Jaypha.

== Third Party Stuff ==

Spinna makes use of several third party projects. These are

|| Project  | License  | Website  |
| Mustache.d  | Boost  | http://code.dlang.org/packages/mustache-d  |
| jQuery  | MIT  | http://jQuery.org  |
| CKEditor  | GPL/LGPL/MPL  | http://ckeditor.com  |
| CKFinder  | Propriety*  | http://cksource.com/ckfinder  |
| MarkItUp  | MIT/GPL  | http://http://markitup.jaysalvat.com  |

* A license needs to be purchased to use CKFinder features.

== What is Jaypha? ==

Jaypha is my business. Any (unpaid) code I write is done under the business name.

== What format is this? ==

This, and all documentation is written in [txt2tags http://txt2tags.org] format.

== What does 'spinna' mean? ==

Spinna is Old Norse for "to weave". It's Old Norse, so it's gotta be cool.
