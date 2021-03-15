/**
Differentiable type.
*/
module diffengine.differentiable;

import diffengine.add_sub : Addition, add, Subtraction, sub;
import diffengine.constant : zero, one, two;
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
    final Addition!R opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "+")
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
    final Subtraction!R opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "-")
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
    final Mul!R opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "*")
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
    final Div!R opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "/")
        in (rhs)
        out (r; r)
    {
        return this.div(rhs);
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

