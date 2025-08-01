// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable{

    uint256 BASIC_COST = 0.0001 ether;

    uint256 tokensIdCounter = 0; 

    constructor()ERC721("ShitNFT", "SHIT")Ownable(_msgSender()) { 

    }

    // Indicates that `tokenId` already exists with owner `owner`
    error TokenIdAlreadyExists(uint tokensIdCounter, address owner); 

    // Indicates that user don't have enough money to mint NFT
    error NotEnoughMoney(uint256 sendedAmount, uint256 nftCost); 

    error TransferError(address to, uint256 amount);

    function mint() external payable{
        if(ownerOf(tokensIdCounter) != address(0)){
            revert TokenIdAlreadyExists(tokensIdCounter, ownerOf(tokensIdCounter));
        }

        if(msg.value != BASIC_COST) {
            revert NotEnoughMoney(msg.value, BASIC_COST);
        }

        _safeMint(_msgSender(), tokensIdCounter);
        tokensIdCounter++;
    }

    function changeBasicCost(uint256 newCost) external onlyOwner {
        BASIC_COST = newCost;
    }

    function withdraw() external onlyOwner{
        uint256 totalEther = address(this).balance;
        
        (bool success, ) = owner().call{value:totalEther}("");
        require(success, TransferError(owner(), totalEther));
    }
}