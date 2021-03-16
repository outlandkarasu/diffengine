/**
Differentiable power function module.
*/
module diffengine.pow;

import std.math : pow;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;
import diffengine.constant : constant;
import diffengine.mul : mul;
import diffengine.div : div;
import diffengine.add_sub : add;
import diffengine.log : log;

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

/**
Differentiable power class.

Params:
    R = result type.
*/
private final class Power(R) : Differentiable!R
{
    this(const(Differentiable!R) lhs, const(Differentiable!R) rhs) const @nogc nothrow pure scope
        in (lhs && rhs)
    {
        this.lhs_ = lhs;
        this.rhs_ = rhs;
    }

    override R opCall() const nothrow pure return scope
    {
        return pow(lhs_(), rhs_());
    }

    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        auto lhsResult = lhs_.differentiate(context);
        auto rhsResult = rhs_.differentiate(context);
        auto result = pow(lhsResult.result, rhsResult.result);
        auto ld = lhsResult.diff.mul(constant(rhsResult.result / lhsResult.result));
        auto rd = mul(rhsResult.diff, R(log(lhsResult.result)).constant);
        return DiffResult!R(result, mul(this, ld.add(rd)));
    }

private:
    const(Differentiable!R) lhs_;
    const(Differentiable!R) rhs_;
}

const(Power!R) pow(R)(const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    return new const(Power!R)(lhs, rhs);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto p1 = param(2.0);
    auto p2 = param(3.0);
    auto m = p1.pow(p2);
    assert(m().isClose(8.0));

    auto p1d = m.differentiate(p1.diffContext);
    assert(p1d.result.isClose(8.0));
    assert(p1d.diff().isClose(12.0));

    auto p2d = m.differentiate(p2.diffContext);
    assert(p2d.result.isClose(8.0));
    assert(p2d.diff().isClose(8.0 * log(2.0)));
}
