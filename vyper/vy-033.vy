#pragma version 0.4.0

import auth
import math

initializes: auth
exports: (auth.set_owner, auth.owner)

total_supply: public(uint256)
balance_of: public(HashMap[address, uint256])

@deploy
def __init__():
    auth.__init__()
    pass

@external
def mint(to: address, amount: uint256):
    auth._check_auth()
    self.total_supply += amount
    self.balance_of[to] += amount

@external
def transfer(to: address, amount: uint256):
    fee: uint256 = math.calc_fee(amount)
    self.balance_of[msg.sender] -= amount
    self.balance_of[to] += (amount - fee)
    self.total_supply -= fee