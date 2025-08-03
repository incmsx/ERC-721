// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable{

    uint256 public BASIC_COST = 0.0001 ether;

    uint256 private tokensIdCounter = 0; 

    string public constant BASE_URI = "ipfs://bafkreiehkbbvbl2bb7rgu7zevqdrtx6rkb4pxhalxtwxkiphiatvpggxmi";

    constructor()ERC721("ShitNFT", "SHIT")Ownable(_msgSender()) { 
    }

    // Indicates that user don't have enough money to mint NFT
    error NotEnoughMoney(uint256 sendedAmount, uint256 nftCost); 

    error TransferError(address to, uint256 amount);

    function mint() external payable{
        if(msg.value != BASIC_COST) {
            revert NotEnoughMoney(msg.value, BASIC_COST);
        }

        _mint(_msgSender(), tokensIdCounter);
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

    function _baseURI() internal pure override returns (string memory) {
        return BASE_URI;
    }

    // function tokenURI() internal pure override returns (string memory) {
    //     return BASE_URI;
    // }
}