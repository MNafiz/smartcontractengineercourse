// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract AccessControl {
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);

    mapping(bytes32 => mapping(address => bool)) public roles;

    bytes32 public constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 public constant USER = keccak256(abi.encodePacked("USER"));
    
    constructor() {
        _grantRole(ADMIN, msg.sender);
    }
    
    modifier onlyRole(bytes32 role) {
        require(roles[role][msg.sender], "not authorized");
        _;
    }

    function _grantRole(bytes32 role, address account) internal {
        // Write code here
        roles[role][account] = true;
        emit GrantRole(role, account);
    }

    function grantRole(bytes32 role, address account) external onlyRole(ADMIN) {
        // Write code here
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyRole(ADMIN) {
        // Write code here
        roles[role][account] = false;
        emit RevokeRole(role, account);
    }
}