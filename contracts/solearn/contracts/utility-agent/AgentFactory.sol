// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IAgentFactory, IAgent} from "../interfaces/IAgentFactory.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AgentUpgradeable} from "./AgentUpgradeable.sol";
import {AgentProxy} from "./AgentProxy.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IEAI721Intelligence} from "../interfaces/IEAI721Intelligence.sol";

contract AgentFactory is IAgentFactory, OwnableUpgradeable {
    address _implementation;
    // collection => agentId => agent address
    mapping (address => mapping(uint256 => address)) public agents;
    mapping (string => bool) public isNameRegistered;

    // Modifier
    modifier onlyAgentOwner(address collection, uint256 agentId) {
        require(IERC721(collection).ownerOf(agentId) == msg.sender, "Unauthorized");
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
        string calldata agentName,
        string calldata codeLanguage,
        IAgent.CodePointer[] memory pointers,
        address[] calldata depsAgents
    ) external onlyAgentOwner(collection, agentId) returns (address agent) {
        require(!isNameRegistered[agentName], "Agent name already registered");
        require(agents[collection][agentId] == address(0), "Agent already exists");

        isNameRegistered[agentName] = true;
        agent = address(new AgentProxy());
        AgentUpgradeable(agent).initialize(
            agentName,
            codeLanguage, 
            pointers, 
            depsAgents
        );
        
        agents[collection][agentId] = agent;
        emit AgentCreated(collection, agentId, agent);
    }

    function publishAgentCode(
        uint256 agentId,
        address collection,
        string memory codeLanguage,
        IAgent.CodePointer[] calldata pointers,
        address[] calldata depsAgentsAgents,
        uint256[] calldata depsAgentCollectionIds
    ) external onlyAgentOwner(collection, agentId) returns (uint16 agetnVersion, uint16 collectionVersion) {
        address agent = agents[collection][agentId];
        require(agent != address(0), "Agent does not exist");
        agetnVersion = AgentUpgradeable(agent).publishAgentCode(pointers, depsAgentsAgents);
        collectionVersion = IEAI721Intelligence(collection).publishAgentCode(agentId, codeLanguage, pointers, depsAgentCollectionIds);
    }

    function setImplementation(address implementation) external onlyOwner {
        _implementation = implementation;

        emit ImplementationSet(implementation);
    }

    function getImplementation() external view returns (address) {
        return _implementation;
    }

}