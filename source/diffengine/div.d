/**
Differentiable division function module.
*/
module diffengine.div;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;
import diffengine.constant : constant;
import diffengine.plus_minus : minus;
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

    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        auto lhsResult = lhs_.differentiate(context);
        auto rhsResult = rhs_.differentiate(context);
        auto rhsConstant = rhsResult.result.constant;
        auto result = lhsResult.result / rhsResult.result;
        auto ldy = mul(lhsResult.diff, rhsConstant);
        auto rdy = mul(lhsResult.result.constant, rhsResult.diff);
        auto numerator = ldy.minus(rdy);
        return DiffResult!R(result, numerator.div(rhsConstant.square));
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
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto p1 = param(2.0);
    auto p2 = param(3.0);
    auto m = p1.div(p2);
    assert(m().isClose(2.0/3.0));

    auto p1d = m.differentiate(p1.diffContext);
    assert(p1d.result.isClose(2.0/3.0));
    assert(p1d.diff().isClose(3.0/9.0));

    auto p2d = m.differentiate(p2.diffContext);
    assert(p2d.result.isClose(2.0/3.0));
    assert(p2d.diff().isClose(-2.0/9.0));
}

