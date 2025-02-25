#pragma version 0.4.0

# public state variable
owner: public(address)
# private state variable
foo: uint256
bar: public(bool)

@deploy
def __init__():
    self.owner = msg.sender
    self.foo = 123
    self.bar = True