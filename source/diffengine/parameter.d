/**
Differentiable parameter type.
*/
module diffengine.parameter;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;

@safe:

/**
Differentiable plus minus class.

Params:
    R = result type.
*/
final class Parameter(R) : Differentiable!R
{
    this()(auto return scope ref const(R) value) nothrow pure return scope
    {
        this.value_ = value;
    }

    override R opCall() const nothrow pure return scope
    {
        return value_;
    }

    override DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        return DiffResult!R(value_, (context.target is this) ? context.one : context.zero);
    }

    /**
    Assign new value.

    Params:
        value = new value.
    Returns:
        this object.
    */
    typeof(this) opAssign()(auto return scope ref const(R) value) nothrow pure return scope
    {
        this.value_ = value;
        return this;
    }

private:
    R value_;
}

Parameter!R param(R)(auto return scope ref const(R) value) nothrow pure
{
    return new Parameter!R(value);
}

///
nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.differentiable : diffContext;

    auto p = param(1.0);
    assert(p().isClose(1.0));

    auto context = diffContext(p);
    auto d = p.differentiate(context);
    assert(d.result.isClose(1.0));
    assert(d.diff is context.one);

    auto p2 = param(1.1);
    auto d2 = p2.differentiate(context);
    assert(d2.result.isClose(1.1));
    assert(d2.diff is context.zero);

    p = 100.0;
    assert(p().isClose(100.0));
}


