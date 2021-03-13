/**
Differentiable power function module.
*/
module diffengine.pow;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;
import diffengine.constant : constant;
import diffengine.mul : mul;

@safe:

/**
Differentiable square class.

Params:
    R = result type.
*/
private final class Square(R) : Differentiable!R
{
    this(const(Differentiable!R) x) const @nogc nothrow pure scope
        in (x)
    {
        this.x_ = x;
    }

    override R opCall() const nothrow pure return scope
    {
        auto x = x_();
        return x * x;
    }

    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        auto xResult = x_.differentiate(context);
        auto result = xResult.result * xResult.result;
        return DiffResult!R(result, mul(constant(R(2) * xResult.result), xResult.diff));
    }

private:
    const(Differentiable!R) x_;
}

const(Square!R) square(R)(const(Differentiable!R) x) nothrow pure
{
    return new const(Square!R)(x);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto p = param(3.0);
    auto p2 = p.square();
    assert(p2().isClose(9.0));

    auto p2d = p2.differentiate(p.diffContext);
    assert(p2d.result.isClose(9.0));
    assert(p2d.diff().isClose(6.0));
}

