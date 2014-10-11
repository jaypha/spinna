//Written in the D programming language
/*
 * General configurations used by Spinna. These need to be set in a file
 * in the projects filespace. These are suitable defaults.
 *
 * Copyright (C) 2013-2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module config.general;

pragma(msg,"You should copy config.general into your own project");

enum max_timeout = 60;

// Session configs.

enum session_dir = "/tmp/";
enum session_time_limit = 20*600000000; // 20 minutes;

// jQuery

enum jquery_src = "http://code.jquery.com/jquery-1.10.2.min.js";

// Directory used by IconButton.

enum icon_file_dir = "/images/icons/";