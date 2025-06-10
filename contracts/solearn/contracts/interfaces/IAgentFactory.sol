// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {IAgent, IEAI721Intelligence} from "./IAgent.sol";

interface IAgentFactory {
    event AgentCreated(address collection, bytes32 agentId, address indexed agent);
    event ImplementationSet(address indexed implementation);

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
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external returns (uint16 agentVersion);

    function getImplementation() external view returns (address);
}