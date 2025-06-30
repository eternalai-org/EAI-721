import { createAlchemyWeb3 } from "@alch/alchemy-web3";
import * as path from "path";

const { ethers, upgrades } = require("hardhat");
const hardhatConfig = require("../../../hardhat.config");

class CryptoAI {
    network: string;
    senderPublicKey: string;
    senderPrivateKey: string;

    constructor(network: any, senderPrivateKey: any, senderPublicKey: any) {
        this.network = network;
        this.senderPrivateKey = senderPrivateKey;
        this.senderPublicKey = senderPublicKey;

        // console.log("senderPrivateKey", senderPrivateKey);
        // console.log("senderPublicKey", senderPublicKey);
    }

    async deployUpgradeable(name: string,
        symbol: string,
        defaultRoyaltyReceiver: any
    ) {
        // if (this.network == "local") {
        //     console.log("not run local");
        //     return;
        // }

        const contract = await ethers.getContractFactory("CryptoAgents");
        console.log("CryptoAgents.deploying ...")
        const proxy = await upgrades.deployProxy(contract, [name, symbol, defaultRoyaltyReceiver], {
            initializer: 'initialize(string, string, address)',
        });
        await proxy.deployed();
        console.log("CryptoAgents deployed at proxy:", proxy.address);
        return proxy.address;
    }

    getContract(contractAddress: any, contractName: any = "./artifacts/contracts/examples/CryptoAgents.sol/CryptoAgents.json") {
        console.log("Network run", this.network, hardhatConfig.networks[this.network].url);
        // if (this.network == "local") {
        //     console.log("not run local");
        //     return;
        // }
        let API_URL: any;
        API_URL = hardhatConfig.networks[hardhatConfig.defaultNetwork].url;

        // load contract
        let contract = require(path.resolve(contractName));
        const web3 = createAlchemyWeb3(API_URL)
        const nftContract = new web3.eth.Contract(contract.abi, contractAddress)
        return { web3, nftContract };
    }

    async upgradeContract(proxyAddress: any) {
        const contractUpdated = await ethers.getContractFactory("CryptoAgents");
        console.log('Upgrading CryptoAgents... by proxy ' + proxyAddress);
        const tx = await upgrades.upgradeProxy(proxyAddress, contractUpdated);
        console.log('CryptoAgents upgraded on tx address ' + await tx.address);
        return tx;
    }

    async signedAndSendTx(web3: any, tx: any) {
        const signedTx = await web3.eth.accounts.signTransaction(tx, this.senderPrivateKey)
        if (signedTx.rawTransaction != null) {
            let sentTx = await web3.eth.sendSignedTransaction(
                signedTx.rawTransaction,
                function (err: any, hash: any) {
                    if (!err) {
                        console.log(
                            "The hash of your transaction is: ",
                            hash,
                            "\nCheck Alchemy's Mempool to view the status of your transaction!"
                        )
                    } else {
                        console.log(
                            "Something went wrong when submitting your transaction:",
                            err
                        )
                    }
                }
            )
            return sentTx;
        }
        return null;
    }

    async changeAgentDataAddress(contractAddress: any, gas: any, newAddr: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.changeAgentDataAddress(newAddr)
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

    async allowAdmin(contractAddress: any, gas: any, newAddr: any, allow: boolean) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.allowAdmin(newAddr, allow)
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

    async setFactory(contractAddress: any, gas: any, factoryAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.setAgentFactory(factoryAddress)
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

    async mint(contractAddress: any, gas: any, tokenId: number, to: any, dna: number, traits: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.mint(tokenId, to, dna, traits)
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

    // async unlock(contractAddress: any, gas: any, tokenId: any) {
    //     let temp = this.getContract(contractAddress);
    //     const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
    //     const fun = temp?.nftContract.methods.unlock(tokenId)
    //     //the transaction
    //     const tx = {
    //         from: this.senderPublicKey,
    //         to: contractAddress,
    //         nonce: nonce,
    //         gas: gas,
    //         data: fun.encodeABI(),
    //     }
    //
    //     if (tx.gas == 0) {
    //         tx.gas = await fun.estimateGas(tx);
    //     }
    //
    //     return await this.signedAndSendTx(temp?.web3, tx);
    // }

    async tokenURI(contractAddress: any, tokenId: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        return await temp?.nftContract.methods.tokenURI(tokenId).call(tx);
    }
}

export { CryptoAI };
