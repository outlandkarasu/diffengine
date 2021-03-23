/**
Differentiable addition and subtraction type.
*/
module diffengine.add_sub;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    EvalContext;

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

    override R opCall() const @nogc nothrow pure return scope
    {
        return mixin("lhs_() " ~ op ~ " rhs_()");
    }

    override R evaluate(scope EvalContext!R context) const nothrow pure
    {
        return mixin("lhs_.evaluate(context) " ~ op ~ " rhs_.evaluate(context)");
    }

    const(Differentiable!R) differentiate(scope DiffContext!R context) const nothrow pure return scope
        in (false)
    {
        auto lhsDiff = context.diff(lhs_);
        auto rhsDiff = context.diff(rhs_);
        return new const(DifferentiableAddSub!(R, op))(lhsDiff, rhsDiff);
    }

private:
    const(Differentiable!R) lhs_;
    const(Differentiable!R) rhs_;
}

alias Addition(R) = const(DifferentiableAddSub!(R, "+"));

const(Addition!R) add(R)(
    const(Differentiable!R) lhs,
    const(Differentiable!R) rhs) nothrow pure
{
    return new Addition!R(lhs, rhs);
}

alias Subtraction(R) = const(DifferentiableAddSub!(R, "-"));

const(Subtraction!R) sub(R)(
    const(Differentiable!R) lhs,
    const(Differentiable!R) rhs) nothrow pure
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

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : evalContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto c1 = constant(1.0);
    auto c2 = param(2.0);
    auto context = evalContext!double();
    auto p = c1.add(c2);
    assert(context.evaluate(p).isClose(3.0));
    assert(context.cacheHitCount == 0);
    assert(context.evaluate(p).isClose(3.0));
    assert(context.cacheHitCount == 1);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : evalContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto c1 = constant(1.0);
    auto c2 = param(2.0);
    auto context = evalContext!double();
    auto m = c1.sub(c2);
    assert(context.evaluate(m).isClose(-1.0));
    assert(context.cacheHitCount == 0);
    assert(context.evaluate(m).isClose(-1.0));
    assert(context.cacheHitCount == 1);
}

const(Differentiable!R) add(R)(
    scope DiffContext!R context,
    const(Differentiable!R) lhs,
    const(Differentiable!R) rhs) nothrow pure
{
    if (context.isZero(lhs))
    {
        return rhs;
    }
    else if (context.isZero(rhs))
    {
        return lhs;
    }

    return add(lhs, rhs);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto c1 = constant(1.0);
    auto c2 = param(2.0);
    auto context = diffContext(c2);
    assert(context.add(c1, c2)().isClose(3.0));
    assert(context.add(context.zero, c2) is c2);
    assert(context.add(c1, context.zero) is c1);
}

const(Differentiable!R) sub(R)(
    scope DiffContext!R context,
    const(Differentiable!R) lhs,
    const(Differentiable!R) rhs) nothrow pure
{
    if (context.isZero(rhs))
    {
        return lhs;
    }

    return sub(lhs, rhs);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;
    import diffengine.constant : constant;
    import diffengine.parameter : param;

    auto c1 = constant(1.0);
    auto c2 = param(2.0);
    auto context = diffContext(c2);
    assert(context.sub(c1, c2)().isClose(-1.0));
    assert(context.sub(context.zero, c2)().isClose(-2.0));
    assert(context.sub(c1, context.zero) is c1);
}

