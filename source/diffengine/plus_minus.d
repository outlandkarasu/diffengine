/**
Differentiable plus minus type.
*/
module diffengine.plus_minus;

import diffengine.differentiable :
    Differentiable,
    DiffResult;

@safe:

/**
Differentiable plus minus class.

Params:
    R = result type.
    op = operator.
*/
immutable final class DifferentiablePlusMinus(R, string op) : Differentiable!R
{
    static assert(op == "+" || op == "-");

    override R opCall() const nothrow pure return scope
    {
    }

    DiffResult!R differentiate() const nothrow pure return scope
    {
    }
}

