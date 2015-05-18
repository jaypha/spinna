//Written in the D programming language
/*
 * Global variables used in Spinna projects.
 *
 * Copyright 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.global;

public import jaypha.types;
public import jaypha.spinna.request;
public import jaypha.spinna.response;
public import jaypha.spinna.session;

HttpRequest request;
HttpResponse response;

Session session;

bool isFCGI = false;
