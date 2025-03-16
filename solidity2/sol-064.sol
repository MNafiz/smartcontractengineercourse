// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC721, IERC721Receiver, IERC165} from "sce/sol/IERC721.sol";

contract ERC721 is IERC721 {
    event Transfer(
        address indexed src, address indexed dst, uint256 indexed id
    );
    event Approval(
        address indexed owner, address indexed spender, uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner, address indexed operator, bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _ownerOf;
    // Mapping owner address to token count
    mapping(address => uint256) internal _balanceOf;
    // Mapping from token ID to approved address
    mapping(uint256 => address) internal _approvals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint256 id) external view returns (address owner) {
        // code
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }

    function balanceOf(address owner) external view returns (uint256) {
        // code
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        // code
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 id) external view returns (address) {
        // code
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    function approve(address spender, uint256 id) external {
        // code
        address owner = _ownerOf[id];
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "not authorized");
        _approvals[id] = spender;
        emit Approval(owner, spender, id);
    }

    function transferFrom(address src, address dst, uint256 id) public {
        // code
        address owner = _ownerOf[id];
        require(dst != address(0), "src or dst is zero address");
        require(src == owner, "not src token");
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender] || msg.sender == _approvals[id], "not authorized");
        
        _balanceOf[src]--;
        _balanceOf[dst]++;
        
        _ownerOf[id] = dst;
        
        delete _approvals[id];
        
        emit Transfer(src, dst, id);
    }

    function safeTransferFrom(address src, address dst, uint256 id) external {
        // code
        transferFrom(src, dst, id);

        require(
            dst.code.length == 0
                || IERC721Receiver(dst).onERC721Received(msg.sender, src, id, "")
                    == IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(
        address src,
        address dst,
        uint256 id,
        bytes calldata data
    ) external {
        // code
        transferFrom(src, dst, id);

        require(
            dst.code.length == 0
                || IERC721Receiver(dst).onERC721Received(msg.sender, src, id, data)
                    == IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function mint(address dst, uint256 id) external {
        // code
        require(dst != address(0), "mint dst zero address");
        require(_ownerOf[id] == address(0), "already minted");
        
        _ownerOf[id] = dst;
        _balanceOf[dst]++;
        
        emit Transfer(address(0), dst, id);
    }

    function burn(uint256 id) external {
        // code
        require(msg.sender == _ownerOf[id], "not owner");
        
        _balanceOf[msg.sender] -= 1;
        
        delete _ownerOf[id];
        delete _approvals[id];
        
        emit Transfer(msg.sender, address(0), id);
    }
}