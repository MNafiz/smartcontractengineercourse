#pragma version 0.4.0

b: public(bool)
i: public(int128)  # -2 ** 127 to (2 ** 127 - 1)
u: public(uint256)  # 0 to 2 ** 256 - 1
addr: public(address)
b32: public(bytes32)
bs: public(Bytes[100])
s: public(String[100])

@deploy
def __init__():
    self.b = True
    self.i = -1
    self.u = 123
    self.addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    self.b32 = 0xada1b75f8ae9a65dcc16f95678ac203030505c6b465c8206e26ae84b525cdacb
    self.bs = b"\x01"
    self.s = "This is a string"
    self.b = False
    self.i = -69
    self.addr = 0x0000000000000000000000000000000000000000
    self.s = "Hello Vyper"