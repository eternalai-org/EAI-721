// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {File} from "./IFileStore.sol";

interface IAgent {
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

    event CodePointerCreated(
        uint256 indexed version,
        uint256 indexed pIndex,
        CodePointer newPointer
    );

    event AgentSynced(uint16 indexed oldVersion, uint16 indexed newVersion);

    error Unauthenticated();
    error DigestAlreadyUsed();
    error InvalidData();
    error ZeroAddress();
    error InvalidVersion();

    function publishAgentCode(
        CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external returns (uint16 version);

    function getDepsAgents(
        uint16 version
    ) external view returns (address[] memory);

    function getAgentCode(
        uint16 version
    ) external view returns (string memory code);

    function getCodeLanguage() external view returns (string memory);

    function getCurrentVersion() external view returns (uint16);
}
