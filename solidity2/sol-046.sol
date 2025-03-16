// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract VerifySig {
    function getMessageHash(string memory message)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(message));
    }

    function getEthSignedMessageHash(bytes32 messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        This is the actual hash that is signed, keccak256 of
        \x19Ethereum Signed Message\n + len(msg) + msg
        */
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
    }

    // Function to split signature into 3 parameters needed by ecrecover
    function _split(bytes memory sig)
        internal
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        // implicitly return (r, s, v)
    }

    // Recovers the signer
    function recover(bytes32 ethSignedMessageHash, bytes memory sig)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = _split(sig);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    // Function to verify signature
    // returns true if `message` is signed by `signer`
    function verify(address signer, string memory message, bytes memory sig)
        public
        pure
        returns (bool)
    {
        bytes32 messageHash = getMessageHash(message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, sig) == signer;
    }

    bool public signed;

    function checkSignature(address signer, bytes memory sig) external {
        string memory message = "secret";
        bytes32 messageHash = getMessageHash(message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(recover(ethSignedMessageHash, sig) == signer, "invalid sig");
        signed = true;
    }
}