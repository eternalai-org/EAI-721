// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {File} from "./IFileStore.sol";
import {IEAI721Intelligence} from "../../interfaces/IEAI721Intelligence.sol";

interface IAgent {
    event CodePointerCreated(
        uint256 indexed version,
        uint256 indexed pIndex,
        IEAI721Intelligence.CodePointer newPointer
    );

    error Unauthenticated();
    error InvalidData();
    error ZeroAddress();
    error InvalidVersion();

    function publishAgentCode(
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external returns (uint16 version);

    function setAgentName(string calldata agentName) external;

    function getDepsAgents(
        uint16 version
    ) external view returns (address[] memory);

    function getAgentCode(
        uint16 version
    ) external view returns (string memory code);

    function getCodeLanguage() external view returns (string memory);

    function getCurrentVersion() external view returns (uint16);

    function getCollectionId() external view returns (uint256);

    function getAgentName() external view returns (string memory);
}
