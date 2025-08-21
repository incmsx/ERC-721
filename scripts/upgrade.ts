import {ethers, upgrades} from "hardhat"
import writeInfo from "./writeDeploymentInfo"

const out = "scripts/deployment/upgradeInfo.json";

const main = async () => {
    const newImplementation = await ethers.getContractFactory("NFTv2");
    const proxy = await upgrades.upgradeProxy("", newImplementation);

    await proxy.waitForDeployment();

    const proxyAddress = await proxy.getAddress();
    const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);

    writeInfo(proxyAddress, implAddress, out);
}