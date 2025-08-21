import path from "path"
import fs from "fs"

const writeInfo = async (proxyAddress: any, implAddress: any, out: any) => {
    
    const deploymentInfo = {
        ProxyAddress: proxyAddress.toString(),
        ImplementAddress:implAddress.toString()
    }
    const deploymentFile = JSON.stringify(deploymentInfo)

    fs.mkdirSync(path.dirname(out), { recursive: true });
    fs.writeFileSync(out, deploymentFile + "\n","utf-8")
}

export default writeInfo