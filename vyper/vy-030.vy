#pragma version 0.4.0

event Transfer:
    _from: indexed(address)
    _to: indexed(address)
    _amount: uint256

event Approval:
    _owner: indexed(address)
    _spender: indexed(address)
    _amount: uint256

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)

@deploy
def __init__(initial_supply: uint256):
    balanceOf[msg.sender] = initial_supply
    totalSupply = initial_supply
    pass

@external
def transfer(_to: address, _amount: uint256) -> bool:
    return True

@external
def transferFrom(_from: address, _to: address, _amount: uint256) -> bool:
    return True

@external
def approve(_spender: address, _amount: uint256) -> bool:
    return True