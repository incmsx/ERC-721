import {ethers, upgrades} from "hardhat"
import writeInfo from "./writeDeploymentInfo"

const out = "scripts/deployment/upgradeInfo.json";
const currentProxy = "0xDD12016494b88E61E0eD1162b91f3Cd734790C46";

const main = async () => {

    const newImplementation = await ethers.getContractFactory("NFTv2");
    const proxy = await upgrades.upgradeProxy(currentProxy, newImplementation);

    const proxyAddress = currentProxy;
    const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);

    writeInfo(proxyAddress, implAddress, out);
}

main();