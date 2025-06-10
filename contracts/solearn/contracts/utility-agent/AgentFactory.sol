// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IAgentFactory, IAgent, IEAI721Intelligence} from "../interfaces/IAgentFactory.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AgentUpgradeable} from "./AgentUpgradeable.sol";
import {AgentProxy} from "./AgentProxy.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AgentFactory is IAgentFactory, OwnableUpgradeable {
    address _implementation;
    address _collection;

    // agentId => agent address
    mapping(bytes32 => address) public agents;
    // nftId => agentId
    mapping(uint256 => bytes32) public collectionIdToAgentId;
    // agentName => isRegistered
    mapping(string => bool) public isNameRegistered;

    // Modifier
    modifier onlyAgentOwner(uint256 collectionId) {
        require(
            IERC721(_collection).ownerOf(collectionId) == msg.sender || msg.sender == _collection,
            "Unauthorized"
        );
        _;
    }

    function initialize(
        address owner,
        address implementation,
        address collection
    ) public initializer {
        require(owner != address(0), "Invalid owner");
        require(implementation != address(0), "Invalid implementation");
        require(collection != address(0), "Invalid collection");

        __Ownable_init();
        _transferOwnership(owner);
        _implementation = implementation;
        _collection = collection;
    }

      function createAgent(
        bytes32 agentId,
        string calldata agentName,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] memory pointers,
        address[] calldata depsAgents,
        uint256 nftId
    ) external onlyAgentOwner(nftId) returns (address agent) {
        require(agentId != bytes32(0) && collectionIdToAgentId[nftId] == bytes32(0), "Invalid agent id");
        require(!isNameRegistered[agentName], "Agent name already registered");
        require(
            agents[agentId] == address(0),
            "Agent already exists"
        );

        collectionIdToAgentId[nftId] = agentId;
        isNameRegistered[agentName] = true;
        agent = address(new AgentProxy());
        AgentUpgradeable(agent).initialize(
            nftId,
            agentName,
            codeLanguage,
            pointers,
            depsAgents
        );

        agents[agentId] = agent;

        emit AgentCreated(_collection, agentId, agent);
    }

    function publishAgentCode(
        bytes32 agentId,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    )
        external
        onlyAgentOwner(AgentUpgradeable(agents[agentId]).getCollectionId())
        returns (uint16 agentVersion)
    {
        address agent = agents[agentId];
        require(agent != address(0), "Agent does not exist");

        agentVersion = AgentUpgradeable(agents[agentId]).publishAgentCode(
            codeLanguage,
            pointers,
            depsAgents
        );
    }

    function setImplementation(address implementation) external onlyOwner {
        _implementation = implementation;

        emit ImplementationSet(implementation);
    }

    function getImplementation() external view returns (address) {
        return _implementation;
    }

    function getCollection() external view returns (address) {
        return _collection;
    }
}