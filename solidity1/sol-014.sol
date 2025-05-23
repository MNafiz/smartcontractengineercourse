// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract FunctionModifier {
    bool public paused;
    uint256 public count;

    // Modifier to check if not paused
    modifier whenNotPaused() {
        require(!paused, "paused");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }
    
    modifier whenPaused() {
        require(paused, "not paused");
        _;
    }
    
    function reset() external whenPaused {
        count = 0;
    }

    function setPause(bool _paused) external {
        paused = _paused;
    }

    // This function will throw an error if paused
    function inc() external whenNotPaused {
        count += 1;
    }

    function dec() external whenNotPaused {
        count -= 1;
    }

    // Modifiers can take inputs.
    // Here is an example to check that x is < 10
    modifier cap(uint256 x) {
        require(x < 10, "x >= 10");
        _;
    }

    function incBy(uint256 x) external whenNotPaused cap(x) {
        count += x;
    }

    // Modifiers can execute code before and after the function.
    modifier sandwich() {
        // code here
        _;
        // more code here
    }
}