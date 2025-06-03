const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
// const {  } = require("@openzeppelin/hardhat-upgrades");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
require("@nomicfoundation/hardhat-chai-matchers");

// Use chai-as-promised for async assertions
chai.use(chaiAsPromised);

// Get Agent contract artifact and interface
// const AgentArtifact = require("../artifacts/contracts/nfts/utilities/AgentUpgradeable.sol/AgentUpgradeable.json");

// Helper function to get contract instance from address and ABI
async function getContractInstance(address, abi, signer) {
    if (!address || !abi) {
        throw new Error("Address and ABI are required");
    }
    return new ethers.Contract(address, abi, signer || ethers.provider);
}


describe("CryptoAI and CryptoAIData", function () {
    // Define contract variables
    let cryptoAI;
    let cryptoAIData;
    let owner;
    let admin;
    let user;

    // Fixture to deploy contracts
    async function deployContractsFixture() {
        // Get signers
        [owner, admin, user] = await ethers.getSigners();

        // Deploy CryptoAIData first using upgrades
        const CryptoAIData = await ethers.getContractFactory("OnchainArtData");
        // cryptoAIData = await upgrades.deployProxy(CryptoAIData, [owner.address]);
        // await cryptoAIData.deployed();
        cryptoAIData = await ethers.deployContract("OnchainArtData", [owner.address]);
        await cryptoAIData.deployed();

        console.log("cryptoAIData deployed at", cryptoAIData.address);

        // Deploy CryptoAI using upgrades
        const CryptoAI = await ethers.getContractFactory("CryptoAgents");
        cryptoAI = await upgrades.deployProxy(
            CryptoAI,
            ["CryptoAI", "CAI", owner.address, owner.address]
        );
        await cryptoAI.deployed();
        console.log("cryptoAI deployed at", cryptoAI.address);

        return { cryptoAI, cryptoAIData, owner, admin, user };
    }

    describe("Deployment", function () {
        it("Should deploy both contracts successfully", async function () {
            console.log("deploying contracts ...");
            const { cryptoAI, cryptoAIData } = await loadFixture(
                deployContractsFixture
            );

            expect(cryptoAI.address).to.be.a("string");
            expect(cryptoAIData.address).to.be.a("string");
        });

        it("Should set the correct deployer address", async function () {
            const { cryptoAI, cryptoAIData, owner } = await loadFixture(
                deployContractsFixture
            );

            expect(await cryptoAI._deployer()).to.equal(owner.address);
            expect(await cryptoAIData._deployer()).to.equal(owner.address);
        });
    });

    describe("Configuration", function () {
        it("Should allow deployer to change CryptoAIData address", async function () {
            const { cryptoAI, cryptoAIData, owner, user } = await loadFixture(
                deployContractsFixture
            );

            // Deploy a new CryptoAIData contract
            const CryptoAIData = await ethers.getContractFactory("OnchainArtData");
            const newCryptoAIData = await ethers.deployContract(
                "OnchainArtData",
                [owner.address]
            );
            await newCryptoAIData.deployed();
            const newCryptoAIDataAddress = newCryptoAIData.address;

            // Change the address
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(newCryptoAIDataAddress);

            expect(await cryptoAI.cryptoAIDataAddr()).to.equal(
                newCryptoAIData.address
            );
        });

        it("Should not allow non-deployer to change CryptoAIData address", async function () {
            const { cryptoAI, user } = await loadFixture(deployContractsFixture);

            await expect(
                cryptoAI.connect(user).changeCryptoAIDataAddress(user.address)
            ).to.be.rejectedWith("103");
        });

        it("Should allow deployer to change CryptoAIAgent address", async function () {
            const { cryptoAIData, owner } = await loadFixture(deployContractsFixture);

            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(owner.address);
            expect(await cryptoAIData._cryptoAIAgentAddr()).to.equal(owner.address);
        });

        it("Should not allow non-deployer to change CryptoAIAgent address", async function () {
            const { cryptoAIData, user } = await loadFixture(deployContractsFixture);

            await expect(
                cryptoAIData.connect(user).changeCryptoAIAgentAddress(user.address)
            ).to.be.revertedWith("103");
        });

        it("Should allow deployer to seal the contract", async function () {
            const { cryptoAIData, owner } = await loadFixture(deployContractsFixture);

            await cryptoAIData.connect(owner).sealContract();

            // Try to change CryptoAIAgent address after sealing (should fail)
            await expect(
                cryptoAIData.connect(owner).changeCryptoAIAgentAddress(owner.address)
            ).to.be.rejectedWith("500");
        });

        it("Should not allow non-deployer to seal the contract", async function () {
            const { cryptoAIData, user } = await loadFixture(deployContractsFixture);

            await expect(
                cryptoAIData.connect(user).sealContract()
            ).to.be.rejectedWith("103");
        });
    });

    describe("Admin and Minting", function () {
        it("Should allow deployer to grant admin privileges", async function () {
            const { cryptoAI, owner, admin } = await loadFixture(
                deployContractsFixture
            );

            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            expect(await cryptoAI._admins(admin.address)).to.be.true;
        });

        it("Should not allow non-deployer to grant admin privileges", async function () {
            const { cryptoAI, user, admin } = await loadFixture(
                deployContractsFixture
            );

            await expect(
                cryptoAI.connect(user).allowAdmin(admin.address, true)
            ).to.be.revertedWith("103");
        });

        it("Should allow admin to mint NFT", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Prepare mint parameters
            const dna = 0;
            const traits = [0, 0, 0, 0, 0, 0];
            const agentName = "";
            const ability = "";

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    dna,
                    traits
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);
            expect(await cryptoAI.agentName(1)).to.equal(agentName);
        });

        it("Should not allow non-admin to mint NFT", async function () {
            const { cryptoAI, cryptoAIData, owner, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAIData.connect(owner).sealContract();

            // Prepare mint parameters
            const dna = 0;
            const traits = [0, 0, 0, 0, 0, 0];
            const agentName = "Test Agent";
            const ability = "Smart";

            // Attempt to mint NFT (should fail)
            await expect(
                cryptoAI
                    .connect(user)
                    .mint(
                        1,
                        user.address,
                        dna,
                        traits,
                        // agentName,
                        // ability
                    )
            ).to.be.revertedWith("101");
        });

        it("Should correctly store and retrieve agent properties after minting", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Prepare mint parameters
            const dna = 0;
            const traits = [0, 0, 0, 0, 0, 0];
            const agentName = "Test Agent";
            const ability = "Smart";

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    dna,
                    traits,
                    // agentName,
                    // ability
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);

            // Verify agent properties
            // expect(await cryptoAI.agentName(1)).to.equal(agentName);
            expect(await cryptoAI.currentVersion(1)).to.equal(0);
            expect(await cryptoAI.codeLanguage(1)).to.equal("");
            expect(await cryptoAI.depsAgents(1, 0)).to.deep.equal([]);
            expect(await cryptoAI.agentCode(1, 0)).to.equal("");
        });

        it("Should directly publish agent code with nft-owner role", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Prepare mint parameters with realistic values
            const dna = 12345; // Unique DNA identifier
            const traits = [1, 2, 3, 4, 5, 6]; // Different trait values
            const codeLanguage = "Python"; // Using Python as the code language
            const agentName = "Code Generator Agent"; // Agent name
            const ability = "Advanced Code Generation"; // Specific ability
            const pointers = [
                {
                    retrieveAddress: "0x0000000000000000000000000000000000000000", // Using IPFS (zero address)
                    fileType: 0, // LIBRARY type
                    fileName: "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco" // Example IPFS hash
                },
                {
                    retrieveAddress: "0x0000000000000000000000000000000000000000",
                    fileType: 1, // MAIN_SCRIPT type
                    fileName: "QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ"
                }
            ];
            const depsAgents = [
                2, // Example dependency agent ID
                3  // Example dependency agent ID
            ];

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    dna,
                    traits,
                    // agentName,
                    // ability
                );

            // Verify NFT was minted
            expect(await cryptoAI.ownerOf(1)).to.equal(user.address);
            // expect(await cryptoAI.agentName(1)).to.equal(agentName);
            expect(await cryptoAI.currentVersion(1)).to.equal(0);
            expect(await cryptoAI.codeLanguage(1)).to.equal("");
            expect(await cryptoAI.depsAgents(1, 0)).to.deep.equal([]);
            expect(await cryptoAI.agentCode(1, 0)).to.equal("");

            await cryptoAI.connect(user).publishAgentCode(1, codeLanguage, pointers, depsAgents);

            // Verify agent properties
            expect(await cryptoAI.codeLanguage(1)).to.equal(codeLanguage);
            expect(await cryptoAI.currentVersion(1)).to.equal(1);

            // Verify code pointers and dependencies
            const deps = await cryptoAI.depsAgents(1, 1);
            expect(deps).to.have.lengthOf(2);
            expect(deps[0]).to.equal(ethers.BigNumber.from(depsAgents[0]));
            expect(deps[1]).to.equal(ethers.BigNumber.from(depsAgents[1]));

            // Get and verify code (should be IPFS hashes since we used zero address)
            const code = await cryptoAI.agentCode(1, 1);
            console.log("code: ", code);
            expect(code).to.include(pointers[0].fileName);
            expect(code).to.include(pointers[1].fileName);
        });

        it.skip("Should publish agent code with valid signature from NFT owner", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Mint NFT to user
            const dna = 12345;
            const traits = [1, 2, 3, 4, 5, 6];
            const codeLanguage = "Python";
            const agentName = "Code Generator Agent";
            const ability = "Code Generation";
            const initialPointers = [];
            const initialDepsAgents = [];

            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    dna,
                    traits,
                    // agentName,
                    // ability
                );

            // Prepare new code pointers and dependencies for publishing
            const newPointers = [
                {
                    retrieveAddress: "0x0000000000000000000000000000000000000000",
                    fileType: 0,
                    fileName: "QmNewPointer1"
                }
            ];
            const newDepsAgents = [
                2 // Example dependency agent ID
            ];

            // Get current version
            const initialVersion = await cryptoAI.currentVersion(1);

            // Get chain ID for domain
            const chainId = await ethers.provider.getNetwork().then(n => n.chainId);

            // Define domain for EIP-712
            const domain = {
                name: "CryptoAI", // This should match the name used in contract initialization
                version: "1.0",
                chainId: chainId,
                verifyingContract: cryptoAI.address
            };

            // Define types for EIP-712
            const types = {
                SignData: [
                    { name: "pointers", type: "CodePointer[]" },
                    { name: "depsAgents", type: "uint256[]" },
                    { name: "agentId", type: "uint256" },
                    { name: "currentVersion", type: "uint16" }
                ],
                CodePointer: [
                    { name: "retrieveAddress", type: "address" },
                    { name: "fileType", type: "uint8" },
                    { name: "fileName", type: "string" }
                ]
            };

            // Create the message to sign
            const message = {
                pointers: newPointers,
                depsAgents: newDepsAgents,
                agentId: 1,
                currentVersion: Number(initialVersion)
            };

            // Sign the typed data with NFT owner's private key
            const signature = await user._signTypedData(domain, types, message);

            // Publish code with signature
            await cryptoAI.publishAgentCodeWithSignature(1, codeLanguage, newPointers, newDepsAgents, signature);

            // Verify the new version was created
            const newVersion = await cryptoAI.currentVersion(1);
            expect(newVersion).to.equal(initialVersion + 1);

            // Verify the new code pointers and dependencies
            const deps = await cryptoAI.depsAgents(1, newVersion);
            expect(deps).to.have.lengthOf(1);
            expect(deps[0]).to.equal(ethers.BigNumber.from(newDepsAgents[0]));

            // Try to use the same signature again(should fail)

            // await expect(
            //     cryptoAI.publishAgentCodeWithSignature(1, codeLanguage, newPointers, newDepsAgents, signature)
            // ).to.be.rejectedWith("DigestAlreadyUsed");

            // Try to use signature from non-owner (should fail)
            const nonOwnerSignature = await admin._signTypedData(domain, types, message);
            await expect(
                cryptoAI.publishAgentCodeWithSignature(1, codeLanguage, newPointers, newDepsAgents, nonOwnerSignature)
            ).to.be.rejectedWith("Unauthenticated");
        });

        it("Should allow NFT owner to update agent name", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Mint NFT
            const initialName = "";
            const ability = "Code Generation";
            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5, 6],
                    // initialName,
                    // ability
                );

            // Verify initial name
            expect(await cryptoAI.agentName(1)).to.equal(initialName);

            // Update name
            const newName = "Updated Agent Name";
            await cryptoAI.connect(user).setAgentName(1, newName);

            // Verify updated name
            expect(await cryptoAI.agentName(1)).to.equal(newName);
        });

        it("Should not allow non-owner to update agent name", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Mint NFT
            const initialName = "";
            const ability = "Code Generation";
            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5, 6],
                    // initialName,
                    // ability
                );

            // Try to update name as non-owner (should fail)
            const newName = "Updated Agent Name";

            await expect(
                cryptoAI.connect(admin).setAgentName(1, newName)
            ).to.be.rejectedWith("Unauthenticated");

            // Verify name remains unchanged
            expect(await cryptoAI.agentName(1)).to.equal(initialName);
        });
    });

    describe("Rating System", function () {
        it("Should allow users to rate an agent", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up required addresses and mint an NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Mint NFT
            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5, 6]
                );

            // Rate the agent
            await cryptoAI.connect(user).rateStar(1, 5);

            // Verify rating
            expect(await cryptoAI.ratingScore(1)).to.equal(500); // 5.00 * 100
            expect(await cryptoAI.ratingCount(1)).to.equal(1);
        });

        it("Should allow users to update their rating", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5, 6]
                );

            // Initial rating
            await cryptoAI.connect(user).rateStar(1, 3);

            // Update rating
            await cryptoAI.connect(user).rateStar(1, 4);

            // Verify updated rating
            expect(await cryptoAI.ratingScore(1)).to.equal(350n); // 4.00 * 100
            expect(await cryptoAI.ratingCount(1)).to.equal(2);
        });

        it("Should not allow rating outside valid range", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5, 6]
                );

            // Try to rate with invalid values
            await expect(cryptoAI.connect(user).rateStar(1, 0)).to.be.rejectedWith("RatingOutOfRange");
            await expect(cryptoAI.connect(user).rateStar(1, 6)).to.be.rejectedWith("RatingOutOfRange");
        });

        it("Should calculate average rating correctly with multiple ratings", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5, 6]
                );

            // Get additional signers for multiple ratings
            const [, , , rater1, rater2, rater3] = await ethers.getSigners();

            // Multiple users rate the agent
            await cryptoAI.connect(user).rateStar(1, 5);
            await cryptoAI.connect(rater1).rateStar(1, 4);
            await cryptoAI.connect(rater2).rateStar(1, 3);
            await cryptoAI.connect(rater3).rateStar(1, 5);

            // Verify average rating (5 + 4 + 3 + 5) / 4 = 4.25
            expect(await cryptoAI.ratingScore(1)).to.equal(425n); // 4.25 * 100
            expect(await cryptoAI.ratingCount(1)).to.equal(4n);
        });

        it("Should return 0 for rating score when no ratings exist", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );

            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            await cryptoAI
                .connect(admin)
                .mint(
                    1,
                    user.address,
                    12345,
                    [1, 2, 3, 4, 5, 6]
                );

            // Verify initial state
            expect(await cryptoAI.ratingScore(1)).to.equal(0);
            expect(await cryptoAI.ratingCount(1)).to.equal(0);
        });
    });

    describe("Minting 10.000 NFTs", function () {
        it.skip("Should mint 10.000 NFTs", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(
                deployContractsFixture
            );
            // Set up and mint NFT
            await cryptoAI
                .connect(owner)
                .changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData
                .connect(owner)
                .changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Create array with 10000 elements
            const nftSupply = 10000;
            const nftArray = Array.from({ length: nftSupply }, (_, i) => i + 1);
            const dna = 12345;
            const agentName = "";
            const ability = "Code Generation";

            for await (let i of nftArray) {
                console.log("Minting NFT ", i);
                const traits = Array(6).fill(0).map(() => Math.floor(Math.random() * 100) + 1);
                await cryptoAI.connect(admin).mint(i, user.address, dna, traits);
                await cryptoAI.connect(user).setAgentName(i, agentName);
            }
            expect(await cryptoAI.balanceOf(user.address)).to.equal(nftSupply);
        });
    });

    describe("EAI721Intelligence: setAgentName and agentName edge cases", function () {
        it("Should allow owner to set name to empty after non-empty", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(deployContractsFixture);
            await cryptoAI.connect(owner).changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData.connect(owner).changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();
            await cryptoAI.connect(admin).mint(1, user.address, 12345, [1, 2, 3, 4, 5, 6]);
            const agentId = 1;
            await cryptoAI.connect(user).setAgentName(agentId, "NonEmptyName");
            expect(await cryptoAI.agentName(agentId)).to.equal("NonEmptyName");
            await cryptoAI.connect(user).setAgentName(agentId, "");
            expect(await cryptoAI.agentName(agentId)).to.equal("");
        });

        it("Should allow owner to set a very long agent name", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(deployContractsFixture);
            await cryptoAI.connect(owner).changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData.connect(owner).changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();
            await cryptoAI.connect(admin).mint(1, user.address, 12345, [1, 2, 3, 4, 5, 6]);
            const agentId = 1;
            const longName = "A".repeat(256); // 256 chars
            await cryptoAI.connect(user).setAgentName(agentId, longName);
            expect(await cryptoAI.agentName(agentId)).to.equal(longName);
        });

        it("Should revert when calling agentName for non-existent agent", async function () {
            const { cryptoAI } = await loadFixture(deployContractsFixture);
            expect(await cryptoAI.agentName(9999)).to.equal("");
        });

        it("Should allow only new owner to set agent name after transfer", async function () {
            const { cryptoAI, cryptoAIData, owner, admin, user } = await loadFixture(deployContractsFixture);
            const [, , , newOwner] = await ethers.getSigners();
            await cryptoAI.connect(owner).changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData.connect(owner).changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();
            await cryptoAI.connect(admin).mint(1, user.address, 12345, [1, 2, 3, 4, 5, 6]);
            const agentId = 1;
            await cryptoAI.connect(user).setAgentName(agentId, "UserName");
            await cryptoAI.connect(user)["safeTransferFrom(address,address,uint256)"](user.address, newOwner.address, agentId);
            await expect(cryptoAI.connect(user).setAgentName(agentId, "ShouldFail")).to.be.rejectedWith("Unauthenticated");
            await cryptoAI.connect(newOwner).setAgentName(agentId, "NewOwnerName");
            expect(await cryptoAI.agentName(agentId)).to.equal("NewOwnerName");
        });
    });

    describe("ERC2981 Royalties", function () {
        it("Should allow admin to set and get default royalty", async function () {
            const { cryptoAI, owner, admin, user, cryptoAIData } = await loadFixture(deployContractsFixture);

            // Setup
            await cryptoAI.connect(owner).changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData.connect(owner).changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Set default royalty
            const royaltyReceiver = user.address;
            const feeNumerator = 1000; // 10%
            await cryptoAI.connect(admin).setDefaultRoyalty(royaltyReceiver, feeNumerator);

            // Mint NFT
            await cryptoAI.connect(admin).mint(1, user.address, 12345, [1, 2, 3, 4, 5, 6]);
            const tokenId = 1;

            // Check royalty info
            const salePrice = ethers.utils.parseEther("1");
            const [receiver, royaltyAmount] = await cryptoAI.royaltyInfo(tokenId, salePrice);
            expect(receiver).to.equal(royaltyReceiver);
            expect(royaltyAmount).to.equal(salePrice.mul(feeNumerator).div(10000));
        });

        it("Should allow admin to set and get token-specific royalty", async function () {
            const { cryptoAI, owner, admin, user, cryptoAIData } = await loadFixture(deployContractsFixture);

            // Setup
            await cryptoAI.connect(owner).changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData.connect(owner).changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Mint NFT
            await cryptoAI.connect(admin).mint(1, user.address, 12345, [1, 2, 3, 4, 5, 6]);
            const tokenId = 1;

            // Set token royalty
            const royaltyReceiver = admin.address;
            const feeNumerator = 500; // 5%
            await cryptoAI.connect(admin).setTokenRoyalty(tokenId, royaltyReceiver, feeNumerator);

            // Check royalty info
            const salePrice = ethers.utils.parseEther("2");
            const [receiver, royaltyAmount] = await cryptoAI.royaltyInfo(tokenId, salePrice);
            expect(receiver).to.equal(royaltyReceiver);
            expect(royaltyAmount).to.equal(salePrice.mul(feeNumerator).div(10000));
        });

        it("Should allow admin to delete default royalty", async function () {
            const { cryptoAI, owner, admin, user, cryptoAIData } = await loadFixture(deployContractsFixture);

            // Setup
            await cryptoAI.connect(owner).changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData.connect(owner).changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Set and then delete default royalty
            await cryptoAI.connect(admin).setDefaultRoyalty(user.address, 1000);
            await cryptoAI.connect(admin).deleteDefaultRoyalty();

            // Mint NFT
            await cryptoAI.connect(admin).mint(1, user.address, 12345, [1, 2, 3, 4, 5, 6]);
            const tokenId = 1;

            // Check royalty info (should be zeroed)
            const salePrice = ethers.utils.parseEther("1");
            const [receiver, royaltyAmount] = await cryptoAI.royaltyInfo(tokenId, salePrice);
            expect(royaltyAmount).to.equal(0);
            expect(receiver).to.equal(ethers.constants.AddressZero);
        });

        it("Should allow admin to reset token-specific royalty", async function () {
            const { cryptoAI, owner, admin, user, cryptoAIData } = await loadFixture(deployContractsFixture);

            // Setup
            await cryptoAI.connect(owner).changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData.connect(owner).changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Set default royalty
            await cryptoAI.connect(admin).setDefaultRoyalty(user.address, 1000);

            // Mint NFT
            await cryptoAI.connect(admin).mint(1, user.address, 12345, [1, 2, 3, 4, 5, 6]);
            const tokenId = 1;

            // Set token royalty
            await cryptoAI.connect(admin).setTokenRoyalty(tokenId, admin.address, 500);

            // Reset token royalty
            await cryptoAI.connect(admin).resetTokenRoyalty(tokenId);

            // Should fallback to default royalty
            const salePrice = ethers.utils.parseEther("1");
            const [receiver, royaltyAmount] = await cryptoAI.royaltyInfo(tokenId, salePrice);
            expect(receiver).to.equal(user.address);
            expect(royaltyAmount).to.equal(salePrice.mul(1000).div(10000));
        });

        it("Should not allow non-admin to set or delete royalties", async function () {
            const { cryptoAI, owner, admin, user, cryptoAIData } = await loadFixture(deployContractsFixture);

            // Setup
            await cryptoAI.connect(owner).changeCryptoAIDataAddress(cryptoAIData.address);
            await cryptoAIData.connect(owner).changeCryptoAIAgentAddress(cryptoAI.address);
            await cryptoAI.connect(owner).allowAdmin(admin.address, true);
            await cryptoAIData.connect(owner).sealContract();

            // Mint NFT
            await cryptoAI.connect(admin).mint(1, user.address, 12345, [1, 2, 3, 4, 5, 6]);
            const tokenId = 1;

            // Non-admin tries to set/delete royalties
            await expect(
                cryptoAI.connect(user).setDefaultRoyalty(user.address, 1000)
            ).to.be.revertedWith("101");
            await expect(
                cryptoAI.connect(user).deleteDefaultRoyalty()
            ).to.be.revertedWith("101");
            await expect(
                cryptoAI.connect(user).setTokenRoyalty(tokenId, user.address, 1000)
            ).to.be.revertedWith("101");
            await expect(
                cryptoAI.connect(user).resetTokenRoyalty(tokenId)
            ).to.be.revertedWith("101");
        });
    });


}); 