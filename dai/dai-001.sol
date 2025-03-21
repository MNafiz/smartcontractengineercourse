// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

address constant PROXY_REGISTRY = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;
address constant PROXY_ACTIONS = 0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038;
address constant CDP_MANAGER = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;

bytes32 constant ETH_C =
    0x4554482d43000000000000000000000000000000000000000000000000000000;

interface IDssProxyRegistry {
    function build() external returns (address proxy);
}

interface IDssProxy {
    function execute(address target, bytes memory data)
        external
        payable
        returns (bytes32 res);
}

interface IDssProxyActions {
    function open(address cdpManager, bytes32 ilk, address usr)
        external
        returns (uint256 cdpId);
}

contract DaiProxy {
    address public immutable proxy;
    uint256 public immutable cdpId;

    constructor() {
        // Code here
        proxy = IDssProxyRegistry(PROXY_REGISTRY).build();
        bytes32 res = IDssProxy(proxy).execute(
            PROXY_ACTIONS,
            abi.encodeCall(IDssProxyActions.open, (CDP_MANAGER, ETH_C, proxy))
        );
        cdpId = uint256(res);
    }
}