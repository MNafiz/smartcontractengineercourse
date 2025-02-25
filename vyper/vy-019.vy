#pragma version 0.4.0

interface TestInterface:
    # get address of owner
    def owner() -> address: view
    # set new owner
    def setOwner(owner: address): nonpayable
    # send ETH
    def sendEth(): payable
    # set owner and send ETH
    def setOwnerAndSendEth(owner: address): payable

# store contract having the above interface
test: public(TestInterface)

@deploy
def __init__(test: address):
    # store contract instance
    self.test = TestInterface(test)
    # if you need to get address from self.test
    addr: address = self.test.address

@external
@view
def getOwner() -> address:
    return staticcall self.test.owner()

@external
@view
def getOwnerFromAddress(test: address) -> address:
    # you can also call functions by passing in the address of the interface
    return staticcall TestInterface(test).owner()

@external
def setOwner(owner: address):
    extcall self.test.setOwner(owner)

@external
@payable
def sendEth():
    extcall self.test.sendEth(value=msg.value)

@external
@payable
def setOwnerAndSendEth(owner: address):
    extcall self.test.setOwnerAndSendEth(owner, value=msg.value)