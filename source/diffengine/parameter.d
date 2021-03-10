/**
Differentiable parameter type.
*/
module diffengine.parameter;

import diffengine.differentiable :
    Differentiable,
    DiffResult;
import diffengine.constant : One, Zero;

@safe:

/**
Differentiable plus minus class.

Params:
    R = result type.
*/
immutable final class Parameter(R) : Differentiable!R
{
    this()(auto return scope ref const(R) value) nothrow pure return scope
    {
        this.value_ = value;
    }

    override R opCall() const nothrow pure return scope
    {
        return value_;
    }

    override DiffResult!R differentiate(scope const(Deferentiable!R) target) const nothrow pure return scope
    {
        return DiffResult!R(value_, (target is this) ? One!R.instance : Zero!R.instance);
    }

private:
    R value_;
}

