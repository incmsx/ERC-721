import { ethers, upgrades } from "hardhat";

import { parseEther } from "ethers";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("NFT", function(){
    async function deploy() {
        const [owner, user] = await ethers.getSigners();
        const NFT = await ethers.getContractFactory("NFTv1");
        const contract = await upgrades.deployProxy(NFT, ["RandomNFT", "RNFT", parseEther("0.0001")], {
            initializer: "initialize",
            kind: "uups"
        }); 

        await contract.waitForDeployment();
        const cost = await contract.basicCost();

        return {contract, owner, user, cost}
    }

    describe("mint", function (){
        it("should be minted", async function (){
            const {owner, contract, user, cost} = await loadFixture(deploy); 
            
            await contract.connect(owner).mint( { value: cost } );
            await contract.connect(user).mint( { value: cost } );
            expect(await contract.ownerOf(1)).to.be.equal(owner.address);
            expect(await contract.ownerOf(2)).to.be.equal(user.address);
        });

        it("should be reverted", async function (){
            const {owner, contract, cost } = await deploy(); 
            const lowerAmount = cost / 10n;
            expect(
                contract.connect(owner).mint( { 
                    value: lowerAmount 
                })
            ).to.be.revertedWithCustomError(contract, "NotEnoughMoney");
        });
        
    })

    describe("changeBasicCost", function (){
        it("basic cost should be changed", async function (){
            const {owner, contract} = await loadFixture(deploy); 
            const newCost = parseEther("1");
            
            await contract.connect(owner).changeBasicCost(newCost);
            const basicCost = await contract.basicCost();
            expect(basicCost).to.be.equal(newCost);
        });   
    })

    async function userMint() {
        const {owner, contract, user, cost} = await loadFixture(deploy);

        await contract.connect(user).mint({ value: cost });
        return {owner, contract, user, cost}
    }

    describe("withdraw", function (){
        it("should be enough money on contract", async function (){
            const {contract, cost} = await loadFixture(userMint);
            const contractBalanceBefore = await ethers.provider.getBalance(contract.getAddress());

            expect(contractBalanceBefore).to.be.equal(cost);
        }); 

        it("should withdraw all ether to owner's wallet", async function (){
            const {owner, contract, user, cost} = await loadFixture(userMint);

            expect(
                contract.connect(owner).withdraw()
            ).changeEtherBalances(
                [contract, owner],
                [-cost, cost]
            );
        });
        
        it("should be reverted if called not by owner", async function (){
            const {contract, user} = await userMint(); 

            expect(
                contract.connect(user).withdraw()
            ).to.be.revertedWithCustomError(contract, "OwnableUnauthorizedAccount");
        });   
    })

    describe ("burn and rufund", function(){
        it("should burn the NFT", async function () {
            const {contract, user, cost} = await loadFixture(userMint);

            const tokenId = 1;
            await contract.connect(user).burn(tokenId);
            expect(contract.ownerOf(tokenId)).to.be.revertedWithCustomError(contract, "ERC721NonexistentToken");
        })

        it("should refund the money", async function () {
            const {contract, user} = await loadFixture(userMint);

            const tokenId = 1;
            const tx = await contract.connect(user).burn(tokenId);
            const cost = await contract.price(tokenId);
            expect(tx).to.changeEtherBalance(user, cost * 9n / 10n);
        })

    })

    // describe("_baseURI", function (){
    //     it("should return base URI", async function (){
    //         const {owner, contract} = await userMint(); 
            
    //         const tokenURI = await contract.tokenURI(0);
    //         const baseURI = await contract.BASE_URI();

    //         expect(tokenURI).to.be.equal(baseURI);
    //     });  
    // })
})