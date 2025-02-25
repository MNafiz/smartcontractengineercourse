#pragma version 0.4.0

# Internal functions can only be called inside this contract
@internal
@pure
def _add(x: uint256, y: uint256) -> uint256:
    return x + y
    
@internal
@pure
def _sqr(x: uint256) -> uint256:
    return x * x

@external
@view
def extFunc() -> bool:
    return True

@external
@view
def sumOfSquares(x: uint256, y: uint256) -> uint256:
    return x * x + y * y

# External functions can only be called from outside this contract
@external
@view
def avg(x: uint256, y: uint256) -> uint256:
    # cannot call other external function
    # self.extFunc()

    # can call internal functions
    z: uint256 = self._add(x, y)

    return (x + y) // 2