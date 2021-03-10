/**
Differentiable type.
*/
module diffengine.differentiable;

@safe:

/**
Differentiable interface.

Params:
    R = result type.
    A = arugment type.
*/
interface Differentiable(R, A)
{
    /**
    Evaluate function.

    Params:
        argument = function argument.
    Returns;
        function result.
    */
    R opCall(return scope A argument) const nothrow pure return scope;

    /**
    Differentiate function.

    Returns:
        Differentiate result.
    */
    DiffResult!(R, A) differentiate(return scope DiffArgument!A argument) const nothrow pure return scope;
}

/**
Differentiable function result and differentiated function.

Params:
    R = result type.
    A = arugment type.
*/
struct DiffResult(R, A)
{
    R result;
    Differentiable!(R, A) diff;
}

/**
Differentiable function arugment.
*/
struct DiffAugument(A)
{
    bool target;
    A value;
}

