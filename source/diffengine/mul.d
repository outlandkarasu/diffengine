/**
Differentiable multiply function module.
*/
module diffengine.mul;

import diffengine.differentiable :
    Differentiable,
    DiffContext,
    DiffResult;
import diffengine.constant : constant;
import diffengine.plus_minus : plus;

@safe:

/**
Differentiable multiply class.

Params:
    R = result type.
*/
private final class Multiply(R) : Differentiable!R
{
    this(const(Differentiable!R) lhs, const(Differentiable!R) rhs) const @nogc nothrow pure scope
        in (lhs && rhs)
    {
        this.lhs_ = lhs;
        this.rhs_ = rhs;
    }

    override R opCall() const nothrow pure return scope
    {
        return lhs_()  * rhs_();
    }

    DiffResult!R differentiate(scope const(DiffContext!R) context) const nothrow pure return scope
    {
        auto lhsResult = lhs_.differentiate(context);
        auto rhsResult = rhs_.differentiate(context);
        auto result = lhsResult.result * rhsResult.result;
        auto ldy = mul(lhsResult.diff, rhsResult.result.constant);
        auto rdy = mul(lhsResult.result.constant, rhsResult.diff);
        return DiffResult!R(result, plus(ldy, rdy));
    }

private:
    const(Differentiable!R) lhs_;
    const(Differentiable!R) rhs_;
}

const(Multiply!R) mul(R)(const(Differentiable!R) lhs, const(Differentiable!R) rhs) nothrow pure
{
    return new const(Multiply!R)(lhs, rhs);
}

