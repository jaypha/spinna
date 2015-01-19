Spinna
======

Spinna is a HTTP request processor framework for the D language.


Features
--------

- Server independance*
- Compile time generated router.
- Sessions
- Pagebuilder classes to construct HTML.
- Templates - Embed D code inside text.

* Spinna's main processor function is designed to be independant of any particular server.
You can create an executable for FCGI, console, or builtin server.

License
-------

All original code is distributed under the Boost License
(see LICENSE.txt). Third party licenses are kept in the licenses
directory.

Platform Support
----------------

Linux only. Tested under Fedora, should work with other distros. Should work with windows
with some tweaking, not yet tested.

Requirements
------------

- fcgiLoop
- Sass

Installation
------------

After copying Spinna into a directory, run make install (using sudo). This will build the
makerouter utilities and copy them to the BININSTALL directory
(/usr/local/bin) directory (/usr/local/lib). The resource files spinna.js and spinna.scss will also be made.

Modules
-------

Spinna modules (not provided by third parties) are kept under the 'jaypha' umbrella package.
Modules specific to the Spinna framework are under the jaypha.spinna package. Other modules
are more generic and can be used in non-Spinna projects.

All code in the jaypha package umbrella is copyright Jaypha and licensed under the
Boost License.

What does 'Spinna' mean?
------------------------

Spinna is Old Norse for "to weave".

Todo
----

- Documentation
- Vibe.d support
