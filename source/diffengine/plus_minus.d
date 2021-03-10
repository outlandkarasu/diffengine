/**
Differentiable plus minus type.
*/
module diffengine.plus_minus;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;

@safe:

/**
Differentiable plus minus class.

Params:
    R = result type.
    op = operator.
*/
private final class DifferentiablePlusMinus(R, string op) : Differentiable!R
{
    static assert(op == "+" || op == "-");

    this(const(Differentiable!R) lhs, const(Differentiable!R) rhs) const @nogc nothrow pure scope
        in (lhs && rhs)
    {
        this.lhs_ = lhs;
        this.rhs_ = rhs;
    }

    override R opCall() const nothrow pure return scope
    {
        return mixin("lhs_() " ~ op ~ " rhs_()");
    }

    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        auto lhsResult = lhs_.differentiate(context);
        auto rhsResult = rhs_.differentiate(context);
        auto result = mixin("lhsResult.result " ~ op ~ " rhsResult.result");
        auto dy = new const(DifferentiablePlusMinus!(R, op))(lhsResult.diff, rhsResult.diff);
        return DiffResult!R(result, dy);
    }

private:
    const(Differentiable!R) lhs_;
    const(Differentiable!R) rhs_;
}

alias Plus(R) = const(DifferentiablePlusMinus!(R, "+"));

Plus!R plus(R)(const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    return new Plus!R(lhs, rhs);
}

alias Minus(R) = const(DifferentiablePlusMinus!(R, "-"));

Minus!R minus(R)(const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    return new Minus!R(lhs, rhs);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto c1 = constant(1.0);
    auto c2 = param(2.0);
    auto p = c1.plus(c2);
    assert(p().isClose(3.0));

    auto m = c1.minus(c2);
    assert(m().isClose(-1.0));

    auto context = diffContext(c2);
    auto pd = p.differentiate(context);
    assert(pd.result.isClose(3.0));
    assert(pd.diff().isClose(1.0));

    auto md = m.differentiate(context);
    assert(md.result.isClose(-1.0));
    assert(md.diff().isClose(-1.0));
}

