# EAI-721: NON-FUNGIBLE AGENT STANDARD
EAI-721 extends ERC-721 to represent AI agents as NFTs. It supports onchain storage of agent capabilities, visual representation, and monetization features — enabling secure ownership and interaction.

## Core Architecture

The contract is built on a modular architecture, inheriting from multiple specialized interfaces:

```solidity
contract EAI721 is 
    IEAI721Brain,
    IEAI721Art,
    IEAI721Payment,
    IEAI721Coin
```

## Key Components

### 1. Agent Ability Management (IEAI721AgentAbility)

The ability extension contract enables the on-chain creation and management of AI agent abilities.

#### Core Data Structures

```solidity
enum FileType {
    LIBRARY,
    MAIN_SCRIPT
}

struct CodePointer {
    address retrieveAddress;
    FileType fileType;
    string fileName;
}

struct SignData {
    CodePointer[] pointers;
    address[] depsAgents;
    uint16 currentVersion;
}
```

#### Key Features

- **On-Chain Code Storage**: Agent logic is stored immutably on-chain using ETHFS (Ethereum File System)
- **Version Control**: Each agent's code can be versioned and updated over time
- **Dependency Management**: Agents can depend on other agents' capabilities
- **Code Verification**: Support for cryptographic signatures to verify code authenticity

#### Core Functions

##### 1. Publish Agent Code
```solidity
function publishAgentCode(
    uint256 agentId,
    string calldata codeLanguage,
    CodePointer[] calldata pointers,
    address[] calldata depsAgents
) external;
```

**Parameters:**
- `agentId`: The ID of the agent to publish code for
- `codeLanguage`: The programming language used for the agent's code
- `pointers`: Array of code pointers containing file locations and types
- `depsAgents`: Array of agent addresses that this agent depends on

##### 2. Get Current Version
```solidity
function currentVersion(uint256 agentId) external view returns (uint16);
```

**Parameters:**
- `agentId`: The ID of the agent to check version for

##### 3. Get Agent Code
```solidity
function agentCode(
    uint256 agentId,
    uint16 version
) external view returns (string memory code);
```

**Parameters:**
- `agentId`: The ID of the agent to retrieve code for
- `version`: The specific version of the agent's code to retrieve

##### 4. Get Dependent Agents
```solidity
function depsAgents(
    uint256 agentId, 
    uint16 version
) external view returns (uint256[] memory);
```

**Parameters:**
- `agentId`: The ID of the agent to get dependencies for
- `version`: The specific version of the agent to check dependencies for

##### 5. Set Agent Name
```solidity
function setAgentName(
    uint256 agentId,
    string calldata name
) external;
```

**Parameters:**
- `agentId`: The ID of the agent to rename
- `name`: The new human-readable name for the agent

### 2. Implementation Choices for NFT Art

Developers have two distinct options for implementing NFT art in their AI Agent contracts:

#### <i> Option 1: On-Chain Art Implementation (IEAI721OnChainArt) </i>

If you want to store all artwork directly on the blockchain, follow the `IEAI721OnChainArt` interface. This approach provides complete decentralization and immutability of the visual representation.

#### Key Features
- **Fully On-Chain Art Storage**: All NFT artwork is stored directly on the blockchain
- **ORIGIN NFT Distinction**: Special visual treatment to determine whether the Agent is original or not
- **DNA & Traits System**: Each agent has unique DNA and traits that influence its visual representation

#### Core functions

##### 1. Mint a New AI Agent NFT

```solidity
function _mint(
    address to, 
    uint256 dna, 
    uint256[5] memory traits  
) internal virtual;
```
<i> Let's implement a public wrapper function for the _mint function above, incorporating appropriate access control mechanisms to secure the minting process. </i>
**Parameters:**
- `to`: Recipient address (NFT owner)
- `dna`: Unique identifier determining the NFT's species/type (e.g., human, monkey, alien)
- `traits`: Array of values defining the NFT's equipment and accessories

##### 2. Get On-Chain Art

```solidity
function tokenURI(uint256 tokenId) external view returns (string memory);
```

**Parameters:**
- `tokenId`: The ID of the token to get art for

#### <i> Option 2: Off-Chain Art Implementation (Standard ERC721) </i>

If you prefer to store artwork off-chain (e.g., IPFS, centralized servers), you can use the standard ERC721 implementation.

#### Core Functions

##### 1. Mint a New NFT

```solidity
function _mint(address to, uint256 tokenId) internal virtual;
```
<i> Let's implement a public wrapper function for the _mint function above, incorporating appropriate access control mechanisms to secure the minting process. </i>

**Parameters:**
- `to`: Recipient address (NFT owner)
- `tokenId`: Token id of new NFT

##### 2. Get token URI

```solidity
function tokenURI(uint256 tokenId) external view virtual returns (string memory);
```

**Parameters:**
- `tokenId`: The ID of the token to get URI for

Choose **Option 1** if you need:
- Complete decentralization of artwork
- Immutable on-chain visual representation
- Complex trait-based artwork generation

Choose **Option 2** if you need:
- External storage solutions (IPFS, centralized servers)
- Simpler implementation without on-chain art generation

### 3. AI Subscription (IEAI721Subscription)

The AI subscription extension contract enables agent creators to monetize their AI agents through subscription-based access. This contract manages the subscription fees for accessing AI agent services.

#### Key Features

- **Subscription Fee Management**: Agent creators can set and update subscription fees for their AI agents

#### Core Functions

##### 1. Set Subscription Fee
```solidity
function setSubscriptionFee(
    uint256 agentId, 
    uint256 fee
) external;
```

**Parameters:**
- `agentId`: The ID of the agent to set the subscription fee for
- `fee`: The subscription fee amount in wei

##### 2. Get Subscription Fee
```solidity
function subscriptionFee(uint256 agentId) external view returns (uint256);
```

**Parameters:**
- `agentId`: The ID of the agent to get the subscription fee for

### 4. AI Token (IEAI721Token)

The AI Token extension contract allows each AI agent to have its own dedicated token for specialized use cases and value exchange.

#### Key Features

- **Custom Token Integration**: Each agent can be associated with a specific ERC20 token

#### Core Functions

##### 1. Set AI Token Address
```solidity
function setAITokenAddress(
    uint256 agentId, 
    address newAIToken
) external;
```

**Parameters:**
- `agentId`: The ID of the agent to set the AI token address for
- `newAIToken`: The address of the ERC20 token to associate with the agent

##### 2. Get AI Token Address
```solidity
function aiToken(uint256 agentId) external view returns (address);
```

**Parameters:**
- `agentId`: The ID of the agent to get the associated token address for

