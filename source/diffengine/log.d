/**
Differentiable log function module.
*/
module diffengine.log;

import std.math : log;
import std.traits : isFloatingPoint;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;
import diffengine.constant : constant;
import diffengine.mul : mul;
import diffengine.div : div;

@safe:

/**
Differentiable log class.

Params:
    R = result type.
*/
private final class Log(R) : Differentiable!R
    if (isFloatingPoint!R)
{
    this(const(Differentiable!R) x) const @nogc nothrow pure scope
        in (x)
    {
        this.x_ = x;
    }

    override R opCall() const nothrow pure return scope
    {
        return log(x_());
    }

    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        auto xResult = x_.differentiate(context);
        R result = log(xResult.result);
        auto dlog = div(context.one, xResult.result.constant);
        return DiffResult!R(result, mul(dlog, xResult.diff));
    }

private:
    const(Differentiable!R) x_;
}

const(Log!R) log(R)(const(Differentiable!R) x) nothrow pure
    if (isFloatingPoint!R)
{
    return new const(Log!R)(x);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;
    import diffengine.pow : square;

    auto p = param(3.0);
    auto plog = p.log();
    assert(plog().isClose(log(3.0)));

    auto context = p.diffContext;
    auto plogd = plog.differentiate(context);
    assert(plogd.result.isClose(log(3.0)));
    assert(plogd.diff().isClose(1.0/3.0));

    auto plog2x = log(p.square);
    auto plog2xd = plog2x.differentiate(context);
    assert(plog2xd.result.isClose(log(9.0)));
    assert(plog2xd.diff().isClose(2.0/3.0));
}

