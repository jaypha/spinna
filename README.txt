Jaypha Spinna Library ReadMe

by Jason den Dulk

= Spinna =

Spinna is a web server framework for the D language.

== Features ==

- Server independance*
- Compile time generated router.
- Sessions
- MySQL database support (other databases possible, but not yet implemented).
- Pagebuilder classes to construct HTML.
- Templates - Embed D code inside text.

* Spinna's main processor function is designed to be independant of any particular server.
You can create an executable for FCGI, console, or builtin server.

== License ==

Spinna is licensed under the Boost License.

== Platform Support ==

Linux only. Tested under Fedora, should work with other distros.

== Requirements ==

- FCGI
- MySQL (or MariaDB)
- Sass
- Flex
- Bison

== Installation ==

After copying Spinna into a directory, run make install (using sudo). This will build the
makerouter and makefixdb utilities and copy them to the BININSTALL directory
(/usr/local/bin), as well as the Fig library, placed into the LIBINSTALL
directory (/usr/local/lib). The resource files spinna.js and spinna.scss will also be made.

== Modules ==

Spinna modules (not provided by third parties) are kept under the 'jaypha' umbrella package.
Modules specific to the Spinna framework are under the jaypha.spinna package. Other modules
are more generic and can be used in non-Spinna projects.

All code in the jaypha package umbrella is copyright Jaypha and licensed under the
Boost License.

== Third Party Stuff ==

The Spinna distribution includes several third party projects. These are

|| Project  | License  | Website  |
| jQuery  | MIT  | http://jQuery.org  |
| jQuery-UI | | |
| jQuery Caret | BSD | http://http://plugins.jquery.com/caret |
| JS Date | MIT | - |

* A license needs to be purchased to use CKFinder features.

== What is Jaypha? ==

Jaypha is my business. All my work is done under the business name.

== What format is this? ==

This, and all documentation is written in [txt2tags http://txt2tags.org] format.

== What does 'Spinna' mean? ==

Spinna is Old Norse for "to weave".
