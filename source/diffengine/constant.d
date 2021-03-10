/**
Differentiable constant type.
*/
module diffengine.constant;

import diffengine.differentiable :
    Differentiable,
    DiffResult,
    DiffContext;

@safe:

/**
Differentiable Zero class.

Params:
    R = result type.
*/
final class Zero(R) : Differentiable!R
{
    private this() immutable @nogc nothrow pure return scope {}

    override R opCall() const nothrow pure return scope
    {
        return R(0);
    }

    override DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        return DiffResult!R(R(0), context.zero);
    }
}

/**
Create zero constant.

Returns:
    Zero constant.
*/
immutable(Zero!R) zero(R)() nothrow pure
    out (r; r)
{
    return new immutable(Zero!R)();
}

///
nothrow pure unittest
{
    import std.math : isClose;

    auto z = zero!real();
    assert(z().isClose(0.0));
}

/**
Differentiable One class.

Params:
    R = result type.
*/
final class One(R) : Differentiable!R
{
    private this() immutable @nogc nothrow pure return scope {}

    override R opCall() const nothrow pure return scope
    {
        return R(1);
    }

    override DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        return DiffResult!R(R(1), context.zero);
    }
}

/**
Create one constant.

Returns:
    One constant.
*/
immutable(One!R) one(R)() nothrow pure
    out (r; r)
{
    return new immutable(One!R)();
}

///
nothrow pure unittest
{
    import std.math : isClose;

    auto o = one!real();
    assert(o().isClose(1.0));
}

/**
Differentiable constant class.

Params:
    R = result type.
*/
final class Constant(R) : Differentiable!R
{
    override R opCall() const nothrow pure return scope
    {
        return value_;
    }

    override DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        return DiffResult!R(value_, context.zero);
    }

private:
    R value_;

    this()(auto return scope ref const(R) value) immutable nothrow pure return scope
    {
        this.value_ = value;
    }
}

/**
Create a constant.

Returns:
    A constant.
*/
immutable(Constant!R) constant(R)(auto return scope ref const(R) value) nothrow pure
    out (r; r)
{
    return new immutable(Constant!R)(value);
}

///
nothrow pure unittest
{
    import std.math : isClose;

    auto c = constant(1.234);
    assert(c().isClose(1.234));
}

