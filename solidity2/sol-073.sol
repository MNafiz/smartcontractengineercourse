// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract TimeLock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint256 blockTimestamp, uint256 timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint256 blockTimestmap, uint256 timestamp);
    error TimestampExpiredError(uint256 blockTimestamp, uint256 expiresAt);
    error TxFailedError();

    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        string func,
        bytes data,
        uint256 timestamp
    );
    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        string func,
        bytes data,
        uint256 timestamp
    );
    event Cancel(bytes32 indexed txId);

    uint256 public constant MIN_DELAY = 10; // seconds
    uint256 public constant MAX_DELAY = 1000; // seconds
    uint256 public constant GRACE_PERIOD = 1000; // seconds

    address public owner;
    // tx id => queued
    mapping(bytes32 => bool) public queued;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function getTxId(
        address target,
        uint256 value,
        string calldata func,
        bytes calldata data,
        uint256 timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, func, data, timestamp));
    }

    /**
     * @param target Address of contract or account to call
     * @param value Amount of ETH to send
     * @param func Function signature, for example "foo(address,uint256)"
     * @param data ABI encoded data send.
     * @param timestamp Timestamp after which the transaction can be executed.
     */
    function queue(
        address target,
        uint256 value,
        string calldata func,
        bytes calldata data,
        uint256 timestamp
    ) external onlyOwner returns (bytes32 txId) {
        // code
        txId = getTxId(target, value, func, data, timestamp);
        if(queued[txId]) {
            revert AlreadyQueuedError(txId);
        }
        
        if((timestamp < block.timestamp + MIN_DELAY) || (timestamp > block.timestamp + MAX_DELAY)) {
            revert TimestampNotInRangeError(block.timestamp, timestamp);
        }
        
        queued[txId] = true;
        emit Queue(txId, target, value, func, data, timestamp);
        
    }

    function execute(
        address target,
        uint256 value,
        string calldata func,
        bytes calldata data,
        uint256 timestamp
    ) external onlyOwner payable returns (bytes memory) {
        // code
        bytes32 txId = getTxId(target, value, func, data, timestamp);
        if (!queued[txId]) {
            revert NotQueuedError(txId);
        }
        
        if (block.timestamp < timestamp) {
            revert TimestampNotPassedError(block.timestamp, timestamp);
        }
        if (block.timestamp > timestamp + GRACE_PERIOD) {
            revert TimestampExpiredError(
                block.timestamp, timestamp + GRACE_PERIOD
            );
        }
        
        queued[txId] = false;
        
        // prepare data
        bytes memory d;
        if (bytes(func).length > 0) {
            // d = func selector + data
            d = abi.encodePacked(bytes4(keccak256(bytes(func))), data);
        } else {
            // call fallback with data
            d = data;
        }
    
        // call target
        (bool ok, bytes memory res) = target.call{value: value}(d);
        if (!ok) {
            revert TxFailedError();
        }
    
        emit Execute(txId, target, value, func, data, timestamp);
    
        return res;
    }

    function cancel(bytes32 txId) external onlyOwner {
        // code
        if (!queued[txId]) {
            revert NotQueuedError(txId);
        }
        
        queued[txId] = false;
        
        emit Cancel(txId);
        
    }
}