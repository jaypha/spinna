

module jaypha.decimal;

import std.string;
import std.math;
import std.conv;

struct decimal(uint scale)
{
  enum factor = 10^^scale;

  private:
    long value;

  public:

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
    bool opEquals(long b) { return (value == b*factor); }
    bool opEquals(double b) { return (value == b*factor); }

    int opCmp(decimal b)
    {
      if (value < b.value) return -1;
      if (value > b.value) return 1;
      return 0;
    }

    int opCmp(long b)
    {
      if (value < b*factor) return -1;
      if (value > b*factor) return 1;
      return 0;
    }

    int opCmp(double b)
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
    { value = lround(to!double(v) * factor); } // TODO do this without FP

    void opOpAssign(string op)(long v)
    {
      mixin("value = (this "~op~" v).value;");
    }
    void opOpAssign(string op)(double v)
    {
      mixin("value = (this "~op~" v).value;");
    }

    T opCast(T)() if (is(T == long) || is(T==double))
    { return value / factor; }

    string toString()
    {
      auto s = to!string(value);
      if (value >= factor)
        return to!string(value/factor)~"."~to!string(value%factor);
      else
        return format("0.%0*d",scale,value);
    }

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
      return decimal(value*factor/b.value);
    }

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
      return decimal(value/b);
    }
    decimal opBinaryRight(string s:"/")(long b)
    {
      return decimal(b/value);
    }
}


auto mult(ubyte s1, ubyte s2)(decimal!s1 a, decimal!s2 b)
{
  decimal!(s1+s2) d;
  d.value = a.value * b.value;
  return d;
}

alias decimal!2 Currency;

//mixin decimalOps!2;

unittest
{
  Currency amount;
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
}