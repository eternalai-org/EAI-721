# EAI721
EAI721 is an innovative ERC721-compliant smart contract that tokenizes AI agents as NFTs, enabling on-chain storage of agent ability, visual representation, and monetization capabilities. 

## Core Architecture

The contract is built on a modular architecture, inheriting from multiple specialized interfaces:

```solidity
contract EAI721 is 
    ERC721,
    IEAI721AgentAbility,
    IEAI721Art,
    IEAI721Subscription,
    IEAI721Token
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

### 2. NFT Art & Visual Representation (IEAI721Art)

The art extension contract manages the visual representation of agents as NFTs, with all artwork stored directly on-chain.

#### Key Features

- **On-Chain Art Storage**: All NFT artwork is stored directly on the blockchain
- **ORIGIN NFT Distinction**: Special visual treatment to determine whether the Agent is original or not
- **DNA & Traits System**: Each agent has unique DNA and traits that influence its visual representation

#### Core Functions

##### 1. Mint a New AI Agent NFT
```solidity
function mint(
    address to, 
    uint256 dna, 
    uint256[5] memory traits, 
    string calldata agentName    
) external;
```

**Parameters:**
- `to`: Recipient address (NFT owner)
- `dna`: Unique identifier determining the NFT's species/type (e.g., human, monkey, alien)
- `traits`: Array of values defining the NFT's equipment and accessories
- `agentName`: Human-readable name for the Agent associated with the NFT

##### 2. Get On-Chain Art
```solidity
function tokenURI(uint256 tokenId) external view returns (string memory);
```

**Parameters:**
- `tokenId`: The ID of the token to get art for

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

## Conclusion

EAI721 represents a significant advancement in the field of decentralized AI, combining the immutability of blockchain technology with the flexibility of AI agents. The architecture enables the creation of truly autonomous, on-chain AI agents with built-in monetization capabilities, paving the way for a new generation of decentralized AI services.
