// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721CInitializable} from "@limitbreak/creator-token-standards/src/erc721c/ERC721C.sol";
import {IEAI721Intelligence} from "../interfaces/IEAI721Intelligence.sol";
import "../libs/helpers/File.sol";

abstract contract EAI721Intelligence is
    Initializable,
    ERC721CInitializable,
    IEAI721Intelligence
{
    using {read} for IFileStore.File;

    // --- Constants ---
    uint256 public constant TOKEN_LIMIT = 10000;
    bytes32 private constant IPFS_SIG = keccak256(bytes("ipfs"));

    // --- Storage ---
    mapping(uint256 agentId => string) private _codeLanguage; // e.g., "python", "javascript"...
    mapping(uint256 agentId => uint16) private _currentVersion;

    mapping(uint256 agentId => string) private _name;

    mapping(bytes32 digest => bool) private _usedDigests;
    mapping(uint256 agentId => mapping(uint256 version => uint256))
        private _pointersNum;
    mapping(uint256 agentId => mapping(uint256 version => mapping(uint256 => CodePointer)))
        private _codePointers;
    mapping(uint256 agentId => mapping(uint256 version => uint256[]))
        private _depsAgents;

    // --- Modifiers ---
    modifier checkVersion(uint256 agentId, uint16 version) virtual {
        _validateVersion(agentId, version);
        _;
    }

    modifier onlyAgentOwner(uint256 agentId) virtual {
        if (msg.sender != ownerOf(agentId)) revert EAI721IntelligenceAuth();
        _;
    }

    // --- Initialization ---
    function __EAI721Intelligence_init() internal onlyInitializing {}

    function __EAI721Intelligence_init_unchained() internal onlyInitializing {}

    // --- Functions ---

    // {IEAI721AgentAbility-setAgentName}
    function setAgentName(
        uint256 agentId,
        string calldata name
    ) public virtual onlyAgentOwner(agentId) {
        _name[agentId] = name;
    }

    // {IEAI721AgentAbility-agentName}
    function agentName(
        uint256 agentId
    ) public view virtual returns (string memory) {
        return _name[agentId];
    }

    // {IEAI721AgentAbility-publishAgentCode}
    function publishAgentCode(
        uint256 agentId,
        string calldata codeLanguageIn,
        CodePointer[] calldata pointersIn,
        uint256[] calldata depsAgentsIn
    ) public virtual onlyAgentOwner(agentId) returns (uint16) {
        return
            _publishAgentCode(
                agentId,
                codeLanguageIn,
                pointersIn,
                depsAgentsIn
            );
    }

    function _publishAgentCode(
        uint256 agentId,
        string calldata codeLanguageIn,
        CodePointer[] calldata pointersIn,
        uint256[] calldata depsAgentsIn
    ) internal virtual returns (uint16) {
        if (pointersIn.length == 0) revert InvalidData();

        _codeLanguage[agentId] = codeLanguageIn;
        uint16 version = _bumpVersion(agentId);

        uint256 pLen = pointersIn.length;
        for (uint256 i = 0; i < pLen; i++) {
            if (bytes(pointersIn[i].fileName).length == 0) {
                revert InvalidData();
            }
            _addNewCodePointer(agentId, version, pointersIn[i]);
        }

        uint256 depsLen = depsAgentsIn.length;
        for (uint256 i = 0; i < depsLen; i++) {
            if (depsAgentsIn[i] == 0 || depsAgentsIn[i] > TOKEN_LIMIT) {
                revert InvalidDependency();
            }
            _depsAgents[agentId][version].push(depsAgentsIn[i]);
        }

        return version;
    }

    function _bumpVersion(uint256 agentId) private returns (uint16) {
        return ++_currentVersion[agentId];
    }

    function _addNewCodePointer(
        uint256 agentId,
        uint16 version,
        CodePointer calldata pointer
    ) internal virtual {
        uint256 pNum = _pointersNumber(agentId, version);

        _codePointers[agentId][version][pNum] = pointer;

        emit CodePointerCreated(agentId, version, pNum, pointer);
        _pointersNum[agentId][version]++;
    }

    // {IEAI721AgentAbility-depsAgents}
    function depsAgents(
        uint256 agentId,
        uint16 version
    )
        public
        view
        virtual
        checkVersion(agentId, version)
        returns (uint256[] memory)
    {
        return _depsAgents[agentId][version];
    }

    // {IEAI721AgentAbility-agentCode}
    function agentCode(
        uint256 agentId,
        uint16 version
    )
        public
        view
        virtual
        checkVersion(agentId, version)
        returns (string memory code)
    {
        uint256 len = _pointersNumber(agentId, version);
        string memory libsCode = "";
        string memory mainScripts = "";

        for (uint256 pIdx = 0; pIdx < len; pIdx++) {
            CodePointer memory p = _codePointers[agentId][version][pIdx];

            string memory codeChunk = _codeByPointer(p);

            if (p.fileType == FileType.LIBRARY) {
                libsCode = _concatStrings(libsCode, codeChunk);
            } else if (p.fileType == FileType.MAIN_SCRIPT) {
                mainScripts = _concatStrings(mainScripts, codeChunk);
            }
        }

        if (bytes(libsCode).length == 0 && bytes(mainScripts).length == 0)
            return "";

        return _concatStrings(libsCode, mainScripts);
    }

    function _concatStrings(
        string memory a,
        string memory b
    ) internal pure virtual returns (string memory) {
        return string(abi.encodePacked(a, "\n", b));
    }

    function _codeByPointer(
        CodePointer memory p
    ) internal view virtual returns (string memory logic) {
        if (keccak256(bytes(_storageMode(p))) == IPFS_SIG) {
            logic = p.fileName; // return the IPFS hash
        } else {
            logic = IFileStore(p.retrieveAddress).getFile(p.fileName).read();
        }
    }

    function _storageMode(
        CodePointer memory p
    ) internal view virtual returns (string memory) {
        if (p.retrieveAddress != address(0)) {
            return "fs";
        }
        return "ipfs";
    }

    function _pointersNumber(
        uint256 agentId,
        uint16 version
    ) internal view virtual returns (uint256) {
        return _pointersNum[agentId][version];
    }

    // {IEAI721AgentAbility-currentVersion}
    function currentVersion(
        uint256 agentId
    ) public view virtual returns (uint16) {
        return _currentVersion[agentId];
    }

    function _validateVersion(
        uint256 agentId,
        uint16 version
    ) internal view virtual {
        if (version > _currentVersion[agentId]) {
            revert InvalidVersion();
        }
    }

    // {IEAI721AgentAbility-codeLanguage}
    function codeLanguage(
        uint256 agentId
    ) public view virtual returns (string memory) {
        return _codeLanguage[agentId];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[44] private __gap;
}
