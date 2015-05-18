//Written in the D programming language
/*
 * Fixed point type.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.decimal;

import std.string;
import std.math;
import std.conv;


struct decimal(uint scale)
{
  enum factor = 10^^scale;
  enum strf = std.range.repeat("0",scale).join();


  private:
    long value;

  public:

    // min and max represent the smallest and larget possible values respectively.

    static immutable decimal min = decimal(long.min);
    static immutable decimal max = decimal(long.max);

    decimal opUnary(string s:"-")()
    {
      return decimal(-value);
    }

    decimal opUnary(string s:"++")()
    {
      return decimal(value + factor);
    }

    decimal opUnary(string s:"--")()
    {
      return decimal(value - factor);
    }

    bool opEquals(decimal b) { return (value == b.value); }
    bool opEquals(long b)    { return (value == b*factor); }
    bool opEquals(double b)  { return ((cast(double)value / factor) == b); }

    pure nothrow int opCmp(const decimal b) const
    {
      if (value < b.value) return -1;
      if (value > b.value) return 1;
      return 0;
    }

    pure nothrow int opCmp(const long b) const
    {
      if (value < b*factor) return -1;
      if (value > b*factor) return 1;
      return 0;
    }

    pure nothrow int opCmp(const double b) const
    {
      if (value < b*factor) return -1;
      if (value > b*factor) return 1;
      return 0;
    }

    void opAssign(decimal v) { value = v.value; }
    void opAssign(long v) { value = v * factor; }
    void opAssign(int v) { value = v * factor; }
    void opAssign(double v) { value = lround(v * factor); }
    void opAssign(float v) { value = lround(v * factor); }
    void opAssign(string v)
    //{ value = to!long(v~strf); }
    { value = lround(std.conv.to!double(v) * factor); } // TODO do this without FP

    void opOpAssign(string op)(decimal v)
    {
      mixin("value = (this "~op~" v).value;");
    }

    void opOpAssign(string op)(long v)
    {
      mixin("value = (this "~op~" v).value;");
    }
    void opOpAssign(string op)(double v)
    {
      mixin("value = (this "~op~" v).value;");
    }

    T opCast(T : long)()
    { return value / factor; }

    T opCast(T : double)()
    { return (cast(double)value) / factor; }

    string toString()
    {
      auto s = std.conv.to!string(value);
      if (value >= factor)
        return std.conv.to!string(value/factor)~"."~std.conv.to!string(value%factor);
      else
        return format("0.%0*d",scale,value);
    }

    // Operators for decimal and decimal

    decimal opBinary(string s:"+")(decimal b)
    {
      return decimal(value+b.value);
    }

    decimal opBinary(string s:"-")(decimal b)
    {
      return decimal(value-b.value);
    }

    decimal opBinary(string s:"*")(decimal b)
    {
      return decimal(value*b.value/factor);
    }

    decimal opBinary(string s:"/")(decimal b)
    {
      return decimal(lround(cast(double)(value*factor)/b.value));
    }

    // Operators for decimal and long

    decimal opBinary(string s:"+")(long b)
    {
      return decimal(value + b*factor);
    }
    decimal opBinaryRight(string s:"+")(long b)
    {
      return decimal(value + b*factor);
    }
    decimal opBinary(string s:"-")(long b)
    {
      return decimal(value + b*factor);
    }
    decimal opBinaryRight(string s:"-")(long b)
    {
      return decimal(b*factor - value);
    }
    decimal opBinary(string s:"*")(long b)
    {
      return decimal(value*b);
    }
    decimal opBinaryRight(string s:"*")(long b)
    {
      return decimal(b*value);
    }
    decimal opBinary(string s:"/")(long b)
    {
      return decimal(lround(value/cast(float)b));
    }
    decimal opBinaryRight(string s:"/")(long b)
    {
      return decimal(lround(cast(float)b/value));
    }

    auto conv(uint new_scale)()
    {
      return decimal!new_scale(value * 10^^(new_scale-scale));
    }
    
    // Operators for decimal and double
/* TODO
    decimal opBinary(string s:"+")(double b)
    {
      return decimal(value + b*factor);
    }
    decimal opBinaryRight(string s:"+")(double b)
    {
      return decimal(value + b*factor);
    }
    decimal opBinary(string s:"-")(double b)
    {
      return decimal(value + b*factor);
    }
    decimal opBinaryRight(string s:"-")(double b)
    {
      return decimal(b*factor - value);
    }
    decimal opBinary(string s:"*")(double b)
    {
      return decimal(value*b);
    }
    decimal opBinaryRight(string s:"*")(double b)
    {
      return decimal(b*value);
    }
    decimal opBinary(string s:"/")(double b)
    {
      return decimal(value/b);
    }
    decimal opBinaryRight(string s:"/")(double b)
    {
      return decimal(b/value);
    }
*/
}

auto toDecimal(uint scale,T)(T v)
{
  decimal!scale d;
  d.opAssign(v);
  return d;
}

auto mult(ubyte s1, ubyte s2)(decimal!s1 a, decimal!s2 b)
{
  decimal!(s1+s2) d;
  d.value = a.value * b.value;
  return d;
}

alias decimal!1 dec1;
alias decimal!2 dec2;
alias decimal!3 dec3;

//mixin decimalOps!2;

unittest
{
  import std.stdio;

  assert(dec2.min.value == long.min);
  assert(dec2.max.value == long.max);

  dec2 amount;
  assert(amount.value == 0);
  amount = 20;
  assert(amount.value == 2000);

  amount = amount + 14;
  assert(amount.value == 3400);

  amount = 6 + amount;
  assert(amount.value == 4000);

  amount += 5;
  assert(amount.value == 4500);
  assert(amount.toString() == "45.0");
  assert(cast(long)amount == 45);
  assert(cast(double)amount == 45.0);

  amount = 0.05;
  assert(amount.value == 5);
  assert(amount.toString() == "0.05");
  assert(cast(long)amount == 0);
  assert(cast(double)amount == 0.05);

  amount = 50;
  assert(amount.value == 5000);

  ulong mult = 2;
  dec2 another = amount * 2;
  assert(another.value == 10000);
  amount *= 3;
  assert(amount.value == 15000);

  amount = "30";
  assert(amount.value == 3000);

  amount = toDecimal!(2,string)("6");
  assert(amount.value == 600);

  amount = 295;
  amount /= 11;
  assert(amount.value == 2682);

  amount = 295;
  another = 11;
  assert((amount/another).value == 2682);

}
