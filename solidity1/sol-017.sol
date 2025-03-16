// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract FunctionOutputs {
    // Functions can return multiple outputs.
    function returnMany() public pure returns (uint256, bool) {
        return (1, true);
    }

    // Outputs can be named.
    function named() public pure returns (uint256 x, bool b) {
        return (1, true);
    }

    // Outputs can be assigned to their name.
    // In this case the return statement can be omitted.
    function assigned() public pure returns (uint256 x, bool b) {
        x = 1;
        b = true;
    }
    
    function myFunc() external view returns(address, bool) {
        return (msg.sender, false);
    }

    // Use destructuring assignment when calling another
    // function that returns multiple outputs.
    function destructuringAssigments() public pure {
        (uint256 i, bool b) = returnMany();
        // Outputs can be left out.
        (, bool bb) = returnMany();
    }
}