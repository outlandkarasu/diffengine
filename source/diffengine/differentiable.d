/**
Differentiable type.
*/
module diffengine.differentiable;

import diffengine.constant : zero, one;

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
    }

    @property const @nogc nothrow pure @safe scope
    {
        const(Differentiable!R) target() { return target_; }
        const(Differentiable!R) zero() { return zero_; }
        const(Differentiable!R) one() { return one_; }
    }

private:
    const(Differentiable!R) target_;
    const(Differentiable!R) zero_;
    const(Differentiable!R) one_;
}

