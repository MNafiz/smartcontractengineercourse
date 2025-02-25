#pragma version 0.4.0

OWNER: immutable(address)
MY_IMMUTABLE: immutable(uint256)

@deploy
def __init__(_val: uint256):
    OWNER = msg.sender
    MY_IMMUTABLE = _val

@external
@view
def getMyImmutable() -> uint256:
    return MY_IMMUTABLE