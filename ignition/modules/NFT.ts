/**
 * @deprecated Use `scripts/deploy.ts` instead.
 */

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ProxyModule = buildModule("NFT", (builder) => {
    const name = builder.getParameter("name", "name");
    const symbol = builder.getParameter("symbol", "UKW");
    const basicCost = builder.getParameter("basicCost", "1");
    
    const implementation = builder.contract("NFTv1");

    const initialize = builder.encodeFunctionCall(implementation, "initialize", [
        name,
        symbol,
        basicCost
    ]);
    const proxy = builder.contract("ERC1967Proxy", [implementation, initialize]);

    return{ proxy }
}); 
export default ProxyModule
