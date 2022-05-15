// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Staking is Ownable, IERC721Receiver {
    uint256 constant STAKING_FEE = 0.01 ether;
    uint256 constant MIN_STAKING_PRICE = 0.01 ether;

    IERC721 immutable collection;
    IERC20 immutable erc20;

    struct Stake {
        address sellerAddress;
        uint256 price;
        uint256 stakedTime;
    }

    mapping(uint256 => Stake) stakes;

    event StakeCreated(address sellerAddress, uint256 tokenId, uint256 price);

    constructor(address _collectionAddress, address _erc20Token) {
        require(_collectionAddress != address(0), "invalid contract addresss");
        require(_erc20Token != address(0), "invalid contract addresss");

        collection = IERC721(_collectionAddress);
        erc20 = IERC20(_erc20Token);
    }

    function offer(uint256 _tokenId, uint256 _price) public {
        require(collection.ownerOf(_tokenId) == msg.sender, "Ownership token is required");
        require(_price >= MIN_STAKING_PRICE, "Insufficient price");
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);
        stakes[_tokenId] = Stake(msg.sender, _price, block.timestamp);

        emit StakeCreated(msg.sender, _tokenId, _price);
    }

    function buy(uint256 _tokenId, uint256 _price) public {
        Stake memory targetStake = stakes[_tokenId];

        require(targetStake.stakedTime != 0, "Stake for token id doesn't exist");
        require(targetStake.price <= _price, "Not sufficient price");
        require(block.timestamp - targetStake.stakedTime > 1 days, "NFT item should be staked at least 1 day");
        require(erc20.balanceOf(msg.sender) >= _price, "Not sufficient amount");

        collection.safeTransferFrom(address(this), msg.sender, _tokenId);
        erc20.transferFrom(msg.sender, targetStake.sellerAddress, targetStake.price);

        delete stakes[_tokenId];
    }

    function buyForOwner(uint256 _tokenId) public payable onlyOwner {
        Stake memory targetStake = stakes[_tokenId];
        require(targetStake.stakedTime != 0, "Stake for token id doesn't exist");
        require(msg.value >= targetStake.price / 10, "Not sufficient refund balance");

        collection.safeTransferFrom(address(this), msg.sender, _tokenId);
        (bool success, ) = payable(targetStake.sellerAddress).call{ value: msg.value }("");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
