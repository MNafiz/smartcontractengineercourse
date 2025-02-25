#pragma version 0.4.0

interface HelloCtf:
    def capture(): nonpayable

target: public(HelloCtf)

@deploy
def __init__(target: address):
    self.target = HelloCtf(target)

@external
def pwn():
    # write your code here
    extcall self.target.capture()
    pass