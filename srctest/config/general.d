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

enum maxTimeout = 60;

// Paginator configs

enum pageSizeDefault = 50;

// Session configs.

enum sessionDir = "/tmp/";
enum sessionTimeLimit = 20*600000000L; // 20 minutes;

// jQuery

enum jquerySrc = "http://code.jquery.com/jquery-1.10.2.min.js";
