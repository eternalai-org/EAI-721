// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IAgent, IEAI721Intelligence} from "../interfaces/IAgent.sol";
import {IFileStore, File} from "../interfaces/IFileStore.sol";

contract AgentUpgradeable is IAgent, Initializable {
    bytes32 private constant _IPFS_SIG = keccak256(bytes("ipfs"));

    string private _codeLanguage; // e.g., "python", "javascript"...
    uint16 private _currentVersion;
    address private _factory;
    string private _agentName;
    uint256 private _collectionId;

    mapping(uint256 version => uint256) private _pointersNum;
    mapping(uint256 version => mapping(uint256 => IEAI721Intelligence.CodePointer))
        private _codePointers;
    mapping(uint256 version => address[]) private _depsAgents;

    uint256[50] private __gap;

    modifier checkVersion(uint16 version) {
        _validateVersion(version);
        _;
    }

    modifier onlyFactory() {
        if (msg.sender != _factory) revert Unauthenticated();
        _;
    }

    function initialize(
        uint256 collectionId,
        string memory agentName,
        string memory codeLanguage,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external payable initializer {
        _codeLanguage = codeLanguage;
        _factory = msg.sender;
        _agentName = agentName;
        _collectionId = collectionId;
    
        _publishAgentCode(_bumpVersion(), pointers, depsAgents);
    }

    function publishAgentCode(
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external virtual onlyFactory returns (uint16) {
        _codeLanguage = codeLanguage;
        uint16 version = _bumpVersion();

        return _publishAgentCode(version, pointers, depsAgents);
    }

    function setAgentName(string calldata agentName) external virtual onlyFactory {
        _agentName = agentName;
    }

    function _publishAgentCode(
        uint16 version,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) internal virtual returns (uint16) {
        if (pointers.length == 0) revert InvalidData();

        uint256 pLen = pointers.length;
        for (uint256 i = 0; i < pLen; i++) {
            if (bytes(pointers[i].fileName).length == 0) {
                revert InvalidData();
            }
            _addNewCodePointer(version, pointers[i]);
        }

        uint256 depsLen = depsAgents.length;
        for (uint256 i = 0; i < depsLen; i++) {
            if (depsAgents[i] == address(0)) {
                revert ZeroAddress();
            }
            _depsAgents[version].push(depsAgents[i]);
        }

        return version;
    }

    function _bumpVersion() private returns (uint16) {
        return ++_currentVersion;
    }

    function _addNewCodePointer(
        uint16 version,
        IEAI721Intelligence.CodePointer calldata pointer
    ) internal virtual {
        uint256 pNum = _getPointersNumber(version);

        _codePointers[version][pNum] = pointer;

        emit CodePointerCreated(version, pNum, pointer);
        _pointersNum[version]++;
    }

    function getDepsAgents(
        uint16 version
    ) external view checkVersion(version) returns (address[] memory) {
        return _depsAgents[version];
    }

    function getAgentCode(
        uint16 version
    ) external view checkVersion(version) returns (string memory code) {
        uint256 len = _getPointersNumber(version);
        string memory libsCode = "";
        string memory mainScripts = "";

        for (uint256 pIdx = 0; pIdx < len; pIdx++) {
            IEAI721Intelligence.CodePointer memory p = _codePointers[version][pIdx];

            string memory codeChunk = _getCodeByPointer(p);

            if (p.fileType == IEAI721Intelligence.FileType.LIBRARY) {
                libsCode = _concatStrings(libsCode, codeChunk);
            } else if (p.fileType == IEAI721Intelligence.FileType.MAIN_SCRIPT) {
                mainScripts = _concatStrings(mainScripts, codeChunk);
            }
        }

        return _concatStrings(libsCode, mainScripts);
    }

    function _concatStrings(
        string memory a,
        string memory b
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(a, "\n", b));
    }

    function _getCodeByPointer(
        IEAI721Intelligence.CodePointer memory p
    ) internal view virtual returns (string memory logic) {
        if (keccak256(bytes(_getStorageMode(p))) == _IPFS_SIG) {
            logic = p.fileName; // return the IPFS hash
        } else {
            logic = IFileStore(p.retrieveAddress).getFile(p.fileName).read();
        }
    }

    function _getStorageMode(
        IEAI721Intelligence.CodePointer memory p
    ) internal view virtual returns (string memory) {
        if (p.retrieveAddress != address(0)) {
            return "fs";
        }
        return "ipfs";
    }

    function _getPointersNumber(
        uint16 version
    ) internal view returns (uint256) {
        return _pointersNum[version];
    }

    function getCurrentVersion() external view returns (uint16) {
        return _currentVersion;
    }

    function _validateVersion(uint16 version) internal view {
        if (version > _currentVersion) {
            revert InvalidVersion();
        }
    }

    function getCodeLanguage() external view returns (string memory) {
        return _codeLanguage;
    }

    function getAgentName() external view returns (string memory) {
        return _agentName;
    }

    function getCollectionId() external view returns (uint256) {
        return _collectionId;
    }
}