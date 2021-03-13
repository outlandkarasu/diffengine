/**
Differentiable exp function module.
*/
module diffengine.exp;

import std.math : exp;
import std.traits : isFloatingPoint;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;
import diffengine.constant : constant;
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
        return exp(x_());
    }

    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        auto xResult = x_.differentiate(context);
        auto result = exp(xResult.result);
        auto dexp = mul(result.constant, xResult.diff);
        return DiffResult!R(result, mul(result.constant, xResult.diff));
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
    import diffengine.constant : constant;
    import diffengine.parameter : param;
    import diffengine.pow : square;

    auto p = param(3.0);
    auto pexp = p.exp();
    assert(pexp().isClose(exp(3.0)));

    auto context = p.diffContext;
    auto pexpd = pexp.differentiate(context);
    assert(pexpd.result.isClose(exp(3.0)));
    assert(pexpd.diff().isClose(exp(3.0)));

    auto pexpx2 = exp(p.square);
    auto pexpx2d = pexpx2.differentiate(context);
    assert(pexpx2d.result.isClose(exp(9.0)));
    assert(pexpx2d.diff().isClose(exp(9.0) * 6.0));
}

