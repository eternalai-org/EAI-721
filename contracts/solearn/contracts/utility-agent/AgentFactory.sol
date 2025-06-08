// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IAgentFactory, IAgent, IEAI721Intelligence} from "../interfaces/IAgentFactory.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AgentUpgradeable} from "./AgentUpgradeable.sol";
import {AgentProxy} from "./AgentProxy.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AgentFactory is IAgentFactory, OwnableUpgradeable {
    address _implementation;
    // collection => agentId => agent address
    mapping(address => mapping(uint256 => address)) public agents;
    mapping(string => bool) public isNameRegistered;

    // Modifier
    modifier onlyAgentOwner(address collection, uint256 agentId) {
        require(
            IERC721(collection).ownerOf(agentId) == msg.sender,
            "Unauthorized"
        );
        _;
    }

    function initialize(
        address owner,
        address implementation
    ) public initializer {
        _transferOwnership(owner);
        _implementation = implementation;
    }

    function createAgent(
        uint256 agentId,
        address collection,
        string calldata agentName
        // string calldata codeLanguage,
        // IEAI721Intelligence.CodePointer[] memory pointers,
        // address[] calldata depsAgents
    ) external onlyAgentOwner(collection, agentId) returns (address agent) {
        require(!isNameRegistered[agentName], "Agent name already registered");
        require(
            agents[collection][agentId] == address(0),
            "Agent already exists"
        );

        isNameRegistered[agentName] = true;
        agent = address(new AgentProxy());
        AgentUpgradeable(agent).initialize(
            agentName
            // codeLanguage,
            // pointers,
            // depsAgents
        );

        agents[collection][agentId] = agent;

        emit AgentCreated(collection, agentId, agent);
    }

    function publishAgentCode(
        uint256 agentId,
        address collection,
        string memory codeLanguage,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents,
        uint256[] calldata depsAgentCollectionIds
    )
        external
        onlyAgentOwner(collection, agentId)
        returns (uint16 agentVersion, uint16 collectionVersion)
    {
        address agent = agents[collection][agentId];
        require(agent != address(0), "Agent does not exist");

        collectionVersion = IEAI721Intelligence(collection)
            .currentVersion(agentId);
        agentVersion = AgentUpgradeable(agents[collection][agentId])
            .getCurrentVersion();

        if (collectionVersion > agentVersion) {
            collectionVersion = IEAI721Intelligence(collection).publishAgentCode(
                agentId,
                codeLanguage,
                pointers,
                depsAgentCollectionIds
            );
            agentVersion = AgentUpgradeable(agents[collection][agentId]).syncAgent(
                collectionVersion,
                pointers,
                depsAgents
            );
        } else if (collectionVersion == agentVersion) {
            collectionVersion = IEAI721Intelligence(collection).publishAgentCode(
                agentId,
                codeLanguage,
                pointers,
                depsAgentCollectionIds
            );
            agentVersion = AgentUpgradeable(agents[collection][agentId]).publishAgentCode(
                pointers,
                depsAgents
            );
        }
    }

    function setImplementation(address implementation) external onlyOwner {
        _implementation = implementation;

        emit ImplementationSet(implementation);
    }

    function getImplementation() external view returns (address) {
        return _implementation;
    }
}