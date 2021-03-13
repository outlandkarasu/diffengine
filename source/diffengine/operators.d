/**
Overloaded operators module.
*/
module diffengine.operators;

import diffengine.differentiable : Differentiable;
import diffengine.mul : Multiply, mul;
import diffengine.add_sub : Addition, add, Subtraction, sub;
import diffengine.div : Division, div;

@safe:

/**
Operators for differentiable functions.
*/
mixin template DifferentiableOperators(R)
{
    static assert(is(typeof(this) : Differentiable!R), "this type is not Differentiable");

    /**
    Add operator.

    Params:
        rhs = right hand side.
    Returns:
        add expression.
    */
    Addition!R opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "+")
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
    Subtraction!R opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "-")
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
    Mul!R opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "*")
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
    Div!R opBinary(string op)(const(Differentiable!R) rhs) const nothrow pure if (op == "/")
        in (rhs)
        out (r; r)
    {
        return this.div(rhs);
    }
}

