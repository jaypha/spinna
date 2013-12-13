/*
 * Multi type value used by Fig. A bunch of values form a "fig tree".
 *
 * Part of the Fig configuration language project.
 *
 * Copyright Jaypha 2013.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.fig.value;

enum Fig_Type { Bool=0, Int, Float, Str, List, Array };

struct Fig_Value
{
  package:
    Fig_Type type_;
    union V
    {
      string sval;
      long   lval;
      double dval;
      bool   bval;
      Fig_Value[] fig_array;
      Figtree fig_list;
    }
    V value_;

  public:
    bool is_bool()   { return type_ == Fig_Type.Bool; }
    bool is_int()    { return type_ == Fig_Type.Int; }
    bool is_float()  { return type_ == Fig_Type.Float; }
    bool is_string() { return type_ == Fig_Type.Str; }
    bool is_list()   { return type_ == Fig_Type.List; }
    bool is_array()  { return type_ == Fig_Type.Array; }
    bool is_number() { return type_ == Fig_Type.Int || type_ == Fig_Type.Float; }
    
    Fig_Type type() { return type_; }
    
    long get_int()      { assert(is_int());    return value_.lval; }
    double get_float()  { assert(is_float());  return value_.dval; }
    bool get_bool()     { assert(is_bool());   return value_.bval; }
    string get_string() { assert(is_string()); return value_.sval; }

    Fig_Value[] get_array()
    {
      assert(is_array(),"fig value is not an array");
      return value_.fig_array;
    }

    Figtree get_list()
    {
      assert(is_list(),"fig value is not a list");
      return value_.fig_list;
    }
}

alias Fig_Value[string] Figtree;
