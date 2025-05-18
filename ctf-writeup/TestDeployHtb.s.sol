// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";


contract TestContract {
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}
contract Solution is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);

        TestContract hack = new TestContract();

        vm.stopBroadcast();

        console.log(address(hack));
    }
}

//    "PrivateKey": "0x4dbc8a8139e897d2e2e2e226153e0d875e409cd5b9ab2f6923a7005f5967506e",
//     "Address": "0x1E43cf85BAABe12Fe7Bb0d5E07334CF195abE52D",
//     "TargetAddress": "0xB356C90B4c18E26dE37c7DcfB4b0c8770681c1D8",
//     "setupAddress": "0xfeF352c84CDe2759B389d7c619E3413B9B771E73"
// http://94.237.56.147:52270/rpc
// 0x08Cb94Ee5C66036C3216e4b44BDC0298c0a95154
// cast call 0x08Cb94Ee5C66036C3216e4b44BDC0298c0a95154 "getTimestamp()(uint256)" --rpc-url http://94.237.56.147:52270/rpc --private-key $PRIVATE_KEY
// cast send 0x08Cb94Ee5C66036C3216e4b44BDC0298c0a95154 "getTimestamp()(uint256)" --rpc-url http://94.237.56.147:52270/rpc --private-key $PRIVATE_KEY
// kalo belum ada transaksi sebelumnya (cast send), block.timestamp gaakan gerak