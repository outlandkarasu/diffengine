/**
Differentiable multiply function module.
*/
module diffengine.mul;

import diffengine.differentiable :
    Differentiable,
    DiffContext;
import diffengine.add_sub : add;

@safe:

/**
Differentiable multiply class.

Params:
    R = result type.
*/
final class Multiply(R) : Differentiable!R
{
    this(const(Differentiable!R) lhs, const(Differentiable!R) rhs) const @nogc nothrow pure scope
        in (lhs && rhs)
    {
        this.lhs_ = lhs;
        this.rhs_ = rhs;
    }

    override R opCall() const nothrow pure return scope
    {
        return lhs_() * rhs_();
    }

    const(Differentiable!R) differentiate(scope DiffContext!R context) const nothrow pure return scope
        in (false)
    {
        auto lhsDiff = context.diff(lhs_);
        auto rhsDiff = context.diff(rhs_);
        auto ldy = mul(lhsDiff, rhs_);
        auto rdy = mul(lhs_, rhsDiff);
        return ldy.add(rdy);
    }

private:
    const(Differentiable!R) lhs_;
    const(Differentiable!R) rhs_;
}

const(Multiply!R) mul(R)(const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    return new const(Multiply!R)(lhs, rhs);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.parameter : param;

    auto p1 = param(2.0);
    auto p2 = param(3.0);
    auto m = p1.mul(p2);
    assert(m().isClose(6.0));

    auto p1d = m.differentiate(p1.diffContext);
    assert(p1d().isClose(3.0));

    auto p2d = m.differentiate(p2.diffContext);
    assert(p2d().isClose(2.0));
}

const(Differentiable!R) mul(R)(scope DiffContext!R context, const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    if (context.isZero(lhs) || context.isZero(rhs))
    {
        return context.zero;
    }
    else if (context.isOne(lhs))
    {
        return rhs;
    }
    else if (context.isOne(rhs))
    {
        return lhs;
    }

    return mul(lhs, rhs);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.parameter : param;

    auto p1 = param(2.0);
    auto p2 = param(3.0);
    auto context = diffContext(p1);
    assert(context.mul(p1, p2)().isClose(6.0));
    assert(context.mul(p1, context.zero) is context.zero);
    assert(context.mul(p1, context.one) is p1);
    assert(context.mul(context.zero, p2) is context.zero);
    assert(context.mul(context.one, p2) is p2);
}

