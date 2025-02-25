#pragma version 0.4.0

@external
@nonreentrant
def func0():
    # call back msg.sender
    raw_call(msg.sender, b"", value=0)

@external
@nonreentrant
def func1():
    raw_call(msg.sender, b"", value=0)