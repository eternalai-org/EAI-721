// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {IAgent, IEAI721Intelligence} from "./IAgent.sol";

interface IAgentFactory {
    event AgentCreated(address collection, bytes32 agentId, address indexed agent);
    event ImplementationSet(address indexed implementation);
    event AgentNameSet(bytes32 indexed agentId, string agentName);

    function collectionIdToAgentId(uint256 nftId) external view returns (bytes32);

    function isNameRegistered(string calldata agentName) external view returns (bool);

    function agents(bytes32 agentId) external view returns (address);

    function createAgent(
        bytes32 agentId,
        string calldata agentName,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] memory pointers,
        address[] calldata depsAgents,
        uint256 nftId
    ) external returns (address agent);

    function publishAgentCode(
        bytes32 agentId,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external returns (uint16 agentVersion);

    function setAgentName(bytes32 agentId, string calldata agentName) external;

    function getAgentName(bytes32 agentId) external view returns (string memory);

    function getImplementation() external view returns (address);
}