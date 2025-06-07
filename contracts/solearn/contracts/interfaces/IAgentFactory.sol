// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {IAgent} from "./IAgent.sol";

interface IAgentFactory {
    event AgentCreated(address collection, uint256 indexed agentId, address indexed agent);
    event ImplementationSet(address indexed implementation);

    function createAgent(
        uint256 agentId,
        address collection,
        string calldata agentName,
        string calldata codeLanguage,
        IAgent.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external returns (address agent);

    function publishAgentCode(
        uint256 agentId,
        address collection,
        string memory codeLanguage,
        IAgent.CodePointer[] calldata pointers,
        address[] calldata depsAgentsAgents,
        uint256[] calldata depsAgentCollectionIds
    ) external returns (uint16 agetnVersion, uint16 collectionVersion);

    function getImplementation() external view returns (address);
}