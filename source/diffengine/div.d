/**
Differentiable division function module.
*/
module diffengine.div;

import diffengine.differentiable :
    Differentiable,
    DiffContext;
import diffengine.add_sub : sub;
import diffengine.mul : mul;
import diffengine.pow : square;

@safe:

/**
Differentiable division class.

Params:
    R = result type.
*/
final class Division(R) : Differentiable!R
{
    this(const(Differentiable!R) lhs, const(Differentiable!R) rhs) const @nogc nothrow pure scope
        in (lhs && rhs)
    {
        this.lhs_ = lhs;
        this.rhs_ = rhs;
    }

    override R opCall() const nothrow pure return scope
    {
        return lhs_() / rhs_();
    }

    const(Differentiable!R) differentiate(scope DiffContext!R context) const nothrow pure return scope
        in (false)
    {
        auto lhsDiff = context.diff(lhs_);
        auto rhsDiff = context.diff(rhs_);
        auto ldy = context.mul(lhsDiff, rhs_);
        auto rdy = context.mul(lhs_, rhsDiff);
        auto numerator = ldy.sub(rdy);
        return numerator.div(rhs_.square);
    }

private:
    const(Differentiable!R) lhs_;
    const(Differentiable!R) rhs_;
}

const(Division!R) div(R)(const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    return new const(Division!R)(lhs, rhs);
}

pure nothrow unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.parameter : param;

    auto p1 = param(2.0);
    auto p2 = param(3.0);
    auto m = p1.div(p2);
    assert(m().isClose(2.0/3.0));

    auto p1d = m.differentiate(p1.diffContext);
    assert(p1d().isClose(3.0/9.0));

    auto p2d = m.differentiate(p2.diffContext);
    assert(p2d().isClose(-2.0/9.0));
}

const(Differentiable!R) div(R)(scope DiffContext!R context, const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    if (context.isOne(rhs))
    {
        return lhs;
    }

    return new const(Division!R)(lhs, rhs);
}

pure nothrow unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.parameter : param;

    auto p1 = param(2.0);
    auto p2 = param(3.0);
    auto context = diffContext(p1);
    assert(context.div(p1, p2)().isClose(2.0/3.0));
    assert(context.div(p1, context.one) is p1);
}

