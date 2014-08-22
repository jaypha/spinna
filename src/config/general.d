/*
 * General configurations used in the program
 */

module config.general;

enum max_timeout = 60;

// Session configs.

enum session_dir = "/tmp/";
enum session_time_limit = 20*600000000; // 20 minutes;

// jQuery

enum jquery_src = "http://code.jquery.com/jquery-1.10.2.min.js";

// Directory used by IconButton.

enum icon_file_dir = "/images/icons/";