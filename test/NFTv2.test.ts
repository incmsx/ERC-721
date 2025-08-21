import { ethers, upgrades } from "hardhat";

import { parseEther } from "ethers";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("NFTv2", function(){

    describe("upgradeability", function () {
    async function deployAndUpgrade() {
        const [owner, user] = await ethers.getSigners();

        // 1. Деплоим V1
        const NFTv1 = await ethers.getContractFactory("NFTv1");
        const proxy = await upgrades.deployProxy(
            NFTv1,
            ["RandomNFT", "RNFT", parseEther("0.0001")],
            { initializer: "initialize", kind: "uups" }
        );
        await proxy.waitForDeployment();

        // 2. Апгрейдим до V2
        const NFTv2 = await ethers.getContractFactory("NFTv2");
        const upgraded = await upgrades.upgradeProxy(
            await proxy.getAddress(),
            NFTv2
        );

        return { proxy, upgraded, owner, user };
    }

    it("should keep old state after upgrade", async function () {
        const { proxy, upgraded, owner } = await deployAndUpgrade();

        // цена из V1 сохранилась?
        expect(await upgraded.basicCost()).to.equal(parseEther("0.0001"));

        // владелец сохранился?
        expect(await upgraded.owner()).to.equal(owner.address);
    });

    it("should support new V2 logic", async function () {
        const { upgraded, owner } = await deployAndUpgrade();

        // Проверка новой логики
        const tokenId = 1;
        await upgraded.connect(owner).mint({ value: parseEther("0.0001") });
        await upgraded.connect(owner).mint({ value: parseEther("0.0001") });

        const uri = await upgraded.tokenURI(tokenId + 1);
        const expected = (await upgraded._assignedMeta(tokenId + 1)).toString();

        // шаблон: ipfs://.../<expected>.json (с привязкой к концу строки)
        const re = new RegExp(`^ipfs:\\/\\/.+\\/${expected}\\.json$`);
        console.log(uri);
        expect(uri).to.match(re);
    });
});

});