// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract NFTv1 is
    ERC721Upgradeable,
    ERC721BurnableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    event Refund(address indexed to, uint256 indexed tokenId, uint256 amount);

    error NotEnoughMoney(uint256 sentAmount, uint256 nftCost);
    error TransferError(address to, uint256 amount);

    uint256 public basicCost;
    uint256 private tokenIdCounter;
    string private constant BASE_URI =
        "ipfs://bafkreiehkbbvbl2bb7rgu7zevqdrtx6rkb4pxhalxtwxkiphiatvpggxmi";
    mapping(uint256 => uint256) public price;

    modifier onlyMinter(uint256 tokenId) {
        require(
            ownerOf(tokenId) == _msgSender(),
            ERC721InvalidOwner(ownerOf(tokenId))
        );
        _;
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _basicCost
    ) public initializer {
        __ERC721_init(_name, _symbol);
        __Ownable_init(_msgSender());
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        basicCost = _basicCost;
        tokenIdCounter = 1;
    }

    function mint() external payable {
        if (msg.value < basicCost) {
            revert NotEnoughMoney(msg.value, basicCost);
        }

        _mint(_msgSender(), tokenIdCounter);
        price[tokenIdCounter] = basicCost;
        tokenIdCounter++;
    }

    function burn(uint256 tokenId) public override {
        _burnRefund(_msgSender(), price[tokenId], tokenId);
        super.burn(tokenId);
    }

    function changeBasicCost(uint256 newCost) external onlyOwner {
        basicCost = newCost;
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 totalEther = address(this).balance;

        (bool success, ) = owner().call{value: totalEther}("");
        require(success, TransferError(owner(), totalEther));
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? baseURI : "";
    }

    function _baseURI() internal pure override returns (string memory) {
        return BASE_URI;
    }

    function _burnRefund(
        address minterAddress,
        uint256 nftPrice,
        uint256 tokenId
    ) internal onlyMinter(tokenId) nonReentrant {
        uint256 refund = (nftPrice * 9) / 10;
        (bool success, ) = payable(minterAddress).call{value: refund}("");
        require(success, TransferError(minterAddress, refund));

        emit Refund(minterAddress, tokenId, refund);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
