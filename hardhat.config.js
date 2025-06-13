/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("hardhat-gas-reporter");
require('hardhat-contract-sizer');
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');
var verify = require("@ericxstone/hardhat-blockscout-verify");

module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.22",
                settings: {
                    optimizer: { enabled: true, runs: 200000 },
                    viaIR: true,
                },
            },
            {
                version: "0.8.19",
                settings: {
                    optimizer: { enabled: true, runs: 200000 },
                    viaIR: true,
                },
            },
            {
                version: "0.8.20",
                settings: {
                    optimizer: { enabled: true, runs: 200000 },
                    viaIR: true,
                },
            },
        ],
    },
    defaultNetwork: process.env.NETWORK,
    etherscan: {
        apiKey: {
            sepolia: process.env.ETHSCAN_API_KEY,
            mainnet: process.env.ETHSCAN_API_KEY,
            base_mainnet: process.env.BASESCAN_API_KEY,
            base_testnet: process.env.BASESCAN_API_KEY,
        },
        customChains: [
            {
                network: "base_mainnet",
                chainId: 8453,
                urls: {
                    apiURL: "https://api.basescan.org/api",
                    browserURL: "https://api.basescan.org/api"
                }
            },
            {
                network: "base_testnet",
                chainId: 84532,
                urls: {
                    apiURL: "https://api-sepolia.basescan.org/api",
                    browserURL: "https://api-sepolia.basescan.org/api"
                }
            }
        ]
    },
    networks: {
        hardhat: {
            allowUnlimitedContractSize: true,
        },
        local: {
            url: process.env.LOCAL_API_URL,
            accounts: [
                `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`,
            ],
        },
        rinkeby: {
            url: process.env.RINKEBY_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        goerli: {
            url: process.env.GOERLI_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        ropsten: {
            url: process.env.ROPSTEN_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
            gas: 500000,
        },
        mainnet: {
            url: process.env.ETH_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        sepolia: {
            url: process.env.SEPOLIA_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        polygon: {
            url: process.env.POLYGON_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        mumbai: {
            url: process.env.POLYGON_MUMBAI_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        bsc_mainnet: {
            url: process.env.BSC_MAINNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        bsc_testnet: {
            url: process.env.BSC_TESTNET_API_URL,
            accounts: [`0x${process.env.PRIVATE_KEY}`],
        },
        base_mainnet: {
            url: process.env.BASE_MAINNET_API_URL, accounts: [`0x${process.env.PRIVATE_KEY}`], timeout: 100_000,
        },
        base_testnet: {
            url: process.env.BASE_TESTNET_API_URL, accounts: [`0x${process.env.PRIVATE_KEY}`], timeout: 100_000,
        }
    },
    mocha: {
        timeout: 40000000,
    },
};