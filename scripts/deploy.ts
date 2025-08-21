import {ethers, upgrades} from "hardhat"
import fs from "fs"
import writeInfo from "./writeDeploymentInfo"

const out = "scripts/deployment/deploymentInfo.json";

const main = async () => {
    const params = JSON.parse(fs.readFileSync("ignition/parameters.json", "utf-8"));

    const name = params.name;
    const symbol = params.symbol;
    const basicCost = params.basicCost;

    const implementation = await ethers.getContractFactory("NFTv1");
    const proxy = await upgrades.deployProxy(implementation, [name, symbol, basicCost], {
        kind: "uups"
    })

    await proxy.waitForDeployment();

    const proxyAddress = await proxy.getAddress();
    console.log("Proxy deployed at:", proxyAddress);

    const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log("Implementation at:", implAddress);

    writeInfo(proxyAddress, implAddress, out);
}

main();