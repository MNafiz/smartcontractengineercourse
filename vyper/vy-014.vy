#pragma version 0.4.0

owner: public(address)

event Deposit:
    sender: indexed(address)
    amount: uint256

@external
@payable
def deposit():
    log Deposit(msg.sender, msg.value)

@external
@view
def getBalance() -> uint256:
    # Get balance of Ether stored in this contract
    return self.balance

@external
@payable
def pay():
    assert msg.value > 0, "not"
    self.owner = msg.sender