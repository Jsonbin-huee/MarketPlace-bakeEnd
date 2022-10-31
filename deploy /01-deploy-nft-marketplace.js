const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config") 
const { verify } = require("../utils/verify.js")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const {deploy, log } = deployments 
    const { deployer } = await getNamedAccounts

    args = []

    const NftMarketplace = await deploy("NftMarketplace", ) ({
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,

    })

    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY
    ) {
        log("Verfiying...")
        await verify(NftMarketplace.address, args)
    }
    log("============================")
}

module.exports.tags = ["all", "Marketplace" ]