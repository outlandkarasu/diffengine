/**
Differentiable addition and subtraction type.
*/
module diffengine.add_sub;

import diffengine.differentiable :
    Differentiable,
    DiffContext;

@safe:

/**
Differentiable add sub class.

Params:
    R = result type.
    op = operator.
*/
private final class DifferentiableAddSub(R, string op) : Differentiable!R
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

    const(Differentiable!R) differentiate(scope DiffContext!R context) const nothrow pure return scope
    {
        auto lhsDiff = lhs_.differentiate(context);
        auto rhsDiff = rhs_.differentiate(context);
        return new const(DifferentiableAddSub!(R, op))(lhsDiff, rhsDiff);
    }

private:
    const(Differentiable!R) lhs_;
    const(Differentiable!R) rhs_;
}

alias Addition(R) = const(DifferentiableAddSub!(R, "+"));

Addition!R add(R)(const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    return new Addition!R(lhs, rhs);
}

alias Subtraction(R) = const(DifferentiableAddSub!(R, "-"));

Subtraction!R sub(R)(const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    return new Subtraction!R(lhs, rhs);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto c1 = constant(1.0);
    auto c2 = param(2.0);
    auto p = c1.add(c2);
    assert(p().isClose(3.0));

    auto m = c1.sub(c2);
    assert(m().isClose(-1.0));

    auto context = diffContext(c2);
    auto pd = p.differentiate(context);
    assert(pd().isClose(1.0));

    auto md = m.differentiate(context);
    assert(md().isClose(-1.0));
}

