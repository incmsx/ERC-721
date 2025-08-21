// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.4;

import "./NFTv1.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTv2 is NFTv1, ERC721EnumerableUpgradeable {
    string private constant BASE_URI =
        "ipfs://bafybeide5b6mgnhkghlsz6eecvgdbu6nmbxmch6b46pq4pvfqpfp6j26si";
    // id => random number for URI computation
    mapping(uint256 => uint256) public _assignedMeta;

    // /// @custom:oz-upgrades-unsafe-allow constructor
    // constructor() {
    //     _disableInitializers();
    // }

    function initializeV2() public reinitializer(2) {
        __ERC721Enumerable_init();
    }

    function mint() public payable virtual override {
        super.mint();
        _assignedMeta[totalSupply()] = computeRandomNumber();
    }

    function computeRandomNumber() internal virtual returns (uint256) {
        uint256 totalSupply = totalSupply();
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, block.prevrandao)
            )
        );
        return (random % totalSupply) + 1;
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, NFTv1)
        returns (string memory)
    {
        _requireOwned(tokenId);

        uint256 randomId = _assignedMeta[tokenId];
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string.concat(
                    baseURI,
                    "/",
                    Strings.toString(randomId),
                    ".json"
                )
                : "";
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI()
        internal
        pure
        override(ERC721Upgradeable, NFTv1)
        returns (string memory)
    {
        return BASE_URI;
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 amount
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
    {
        super._increaseBalance(account, amount);
    }
}
