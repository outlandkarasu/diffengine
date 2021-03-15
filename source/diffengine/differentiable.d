/**
Differentiable type.
*/
module diffengine.differentiable;

import diffengine.add_sub : Addition, add, Subtraction, sub;
import diffengine.constant : zero, one, two, constant;
import diffengine.div : Division, div;
import diffengine.mul : Multiply, mul;

@safe:

/**
Differentiable interface.

Params:
    R = result type.
*/
interface Differentiable(R)
{
    /**
    Evaluate function.

    Returns;
        function result.
    */
    R opCall() const nothrow pure return scope;

    /**
    Differentiate function.

    Params:
        context = differentiate context.
    Returns:
        Differentiate result.
    */
    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope;

    /**
    Add operator.

    Params:
        rhs = right hand side.
    Returns:
        add expression.
    */
    final const(Addition!R) opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "+")
        in (rhs)
        out (r; r)
    {
        return this.add(rhs);
    }

    /**
    Subtract operator.

    Params:
        rhs = right hand side.
    Returns:
        subtract expression.
    */
    final const(Subtraction!R) opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "-")
        in (rhs)
        out (r; r)
    {
        return this.sub(rhs);
    }

    /**
    Multiply operator.

    Params:
        rhs = right hand side.
    Returns:
        multiply expression.
    */
    final const(Multiply!R) opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "*")
        in (rhs)
        out (r; r)
    {
        return this.mul(rhs);
    }

    /**
    Divide operator.

    Params:
        rhs = right hand side.
    Returns:
        divite expression.
    */
    final const(Division!R) opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "/")
        in (rhs)
        out (r; r)
    {
        return this.div(rhs);
    }

    /**
    Binary operator.

    Params:
        rhs = right hand side.
    Returns:
        binary operator expression.
    */
    final auto opBinary(string op)(auto scope ref const(R) rhs) const nothrow pure
        if (op == "+" || op == "-" || op == "*" || op == "/")
    {
        return opBinary!op(rhs.constant);
    }

    /**
    Binary operator.

    Params:
        lhs = left hand side.
    Returns:
        binary operator expression.
    */
    final auto opBinaryRight(string op)(auto scope ref const(R) lhs) const nothrow pure
        if (op == "+" || op == "-" || op == "*" || op == "/")
    {
        return lhs.constant.opBinary!op(this);
    }
}

/**
Differentiable function result and differentiated function.

Params:
    R = result type.
*/
struct DiffResult(R)
{
    R result;
    const(Differentiable!R) diff;
}

/**
Differentiate context.

Params:
    R = result type.
*/
final class DiffContext(R)
{
    this(const(Differentiable!R) target) nothrow pure scope return
        in (target)
    {
        this.target_ = target;
        this.zero_ = .zero!R();
        this.one_ = .one!R();
        this.two_ = .two!R();
    }

    @property const @nogc nothrow pure @safe scope
    {
        const(Differentiable!R) target() { return target_; }
        const(Differentiable!R) zero() { return zero_; }
        const(Differentiable!R) one() { return one_; }
        const(Differentiable!R) two() { return two_; }
    }

private:
    const(Differentiable!R) target_;
    const(Differentiable!R) zero_;
    const(Differentiable!R) one_;
    const(Differentiable!R) two_;
}

/**
Create differentiate context.

Params:
    R = result type.
    target = differentiate target.
Returns:
    Differentiate context.
*/
DiffContext!R diffContext(R)(const(Differentiable!R) target) nothrow pure
    in (target)
{
    return new DiffContext!R(target);
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.parameter : param;

    auto p = param(1.0);
    auto context = diffContext(p);
    assert(context.target is p);
    assert(context.zero()().isClose(0.0));
    assert(context.one()().isClose(1.0));
    assert(context.two()().isClose(2.0));
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.parameter : param;

    auto p1 = param(1.0);
    auto p2 = param(2.0);
    assert((p1 + p2)().isClose(3.0));
    assert((p1 - p2)().isClose(-1.0));
    assert((p1 * p2)().isClose(2.0));
    assert((p1 / p2)().isClose(0.5));
}

nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.parameter : param;

    auto p1 = param(1.0);
    assert((p1 + 2.0)().isClose(3.0));
    assert((p1 - 2.0)().isClose(-1.0));
    assert((p1 * 2.0)().isClose(2.0));
    assert((p1 / 2.0)().isClose(0.5));
}
nothrow pure unittest
{
    import std.math : isClose;
    import diffengine.parameter : param;

    auto p1 = param(2.0);
    assert((1.0 + p1)().isClose(3.0));
    assert((1.0 - p1)().isClose(-1.0));
    assert((1.0 * p1)().isClose(2.0));
    assert((1.0 / p1)().isClose(0.5));
}

