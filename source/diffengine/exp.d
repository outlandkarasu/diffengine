/**
Differentiable exp function module.
*/
module diffengine.exp;

import std.math : mathExp = exp;
import std.traits : isFloatingPoint, isNumeric;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;
import diffengine.mul : mul;

@safe:

/**
Differentiable exp class.

Params:
    R = result type.
*/
private final class Exp(R) : Differentiable!R
    if (isFloatingPoint!R)
{
    this(const(Differentiable!R) x) const @nogc nothrow pure scope
        in (x)
    {
        this.x_ = x;
    }

    override R opCall() const nothrow pure return scope
    {
        return mathExp(x_());
    }

    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        auto xResult = x_.differentiate(context);
        auto result = mathExp(xResult.result);
        return DiffResult!R(result, mul(this, xResult.diff));
    }

private:
    const(Differentiable!R) x_;
}

const(Exp!R) exp(R)(const(Differentiable!R) x) nothrow pure
    if (isFloatingPoint!R)
{
    return new const(Exp!R)(x);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.parameter : param;
    import diffengine.pow : square;

    auto p = param(3.0);
    auto pexp = p.exp();
    assert(pexp().isClose(mathExp(3.0)));

    auto context = p.diffContext;
    auto pexpd = pexp.differentiate(context);
    assert(pexpd.result.isClose(mathExp(3.0)));
    assert(pexpd.diff().isClose(mathExp(3.0)));

    auto pexpx2 = exp(p.square);
    auto pexpx2d = pexpx2.differentiate(context);
    assert(pexpx2d.result.isClose(mathExp(9.0)));
    assert(pexpx2d.diff().isClose(mathExp(9.0) * 6.0));
}

/**
exp for numeric.

Params:
    x = value
Returns:
    exp value.
*/
T exp(T)(T x) @nogc nothrow pure
    if (isNumeric!T)
{
    return mathExp(x);
}

///
@nogc nothrow pure unittest
{
    import std.math : isClose;
    assert(exp(4.0).isClose(mathExp(4.0)));
}

