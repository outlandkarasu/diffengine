/**
Differentiable log function module.
*/
module diffengine.log;

import std.math : mathLog = log;
import std.traits : isFloatingPoint, isNumeric;

import diffengine.differentiable :
    Differentiable,
    DiffContext;
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
        return mathLog(x_());
    }

    const(Differentiable!R) differentiate(scope DiffContext!R context) const nothrow pure return scope
        in (false)
    {
        auto xDiff = context.diff(x_);
        auto dlog = div(context.one, x_);
        return mul(dlog, xDiff);
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
    import diffengine.parameter : param;
    import diffengine.pow : square;

    auto p = param(3.0);
    auto plog = p.log();
    assert(plog().isClose(mathLog(3.0)));

    auto context = p.diffContext;
    auto plogd = plog.differentiate(context);
    assert(plogd().isClose(1.0/3.0));

    auto plog2x = log(p.square);
    auto plog2xd = plog2x.differentiate(context);
    assert(plog2xd().isClose(2.0/3.0));
}

/**
log for numeric.

Params:
    x = value
Returns:
    log value.
*/
T log(T)(T x) @nogc nothrow pure
    if (isNumeric!T)
{
    return mathLog(x);
}

///
@nogc nothrow pure unittest
{
    import std.math : isClose;
    assert(log(4.0).isClose(mathLog(4.0)));
}

