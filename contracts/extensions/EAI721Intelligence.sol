// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IEAI721Intelligence} from "../interfaces/IEAI721Intelligence.sol";
import "../libs/helpers/File.sol";
import {IAgentFactory} from "../solearn/contracts/interfaces/IAgentFactory.sol";
import {IAgent} from "../solearn/contracts/interfaces/IAgent.sol";

abstract contract EAI721Intelligence is
    Initializable,
    ERC721Upgradeable,
    IEAI721Intelligence
{
    using {read} for IFileStore.File;

    // --- Constants ---
    uint256 private constant TOKEN_LIMIT = 10000;
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

    address public agentFactory;

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
       IAgentFactory(agentFactory).setAgentName(_collectionIdToAgentId(agentId), name);
    }

    // {IEAI721AgentAbility-agentName}
    function agentName(
        uint256 agentId
    ) public view virtual returns (string memory) {
        string memory name = IAgentFactory(agentFactory).getAgentName(_collectionIdToAgentId(agentId));

        if (bytes(name).length == 0) {
            return _name[agentId];
        }
        return name;
    }

    // {IEAI721AgentAbility-publishAgentCode}
    function publishAgentCode(
        uint256 agentId,
        string calldata codeLanguageIn,
        CodePointer[] calldata pointersIn,
        address[] calldata depsAgentsIn
    ) public virtual onlyAgentOwner(agentId) returns (uint16) {
        bytes32 agentIdBytes = _collectionIdToAgentId(agentId);
        return IAgentFactory(agentFactory).publishAgentCode(agentIdBytes, codeLanguageIn, pointersIn, depsAgentsIn);
    }

    function _collectionIdToAgentId(uint256 collectionId) internal view returns (bytes32) {
        return IAgentFactory(agentFactory).collectionIdToAgentId(collectionId);
    }

     function _collectionIdToAgentAddress(uint256 collectionId) internal view returns (address) {
        return IAgentFactory(agentFactory).agents(_collectionIdToAgentId(collectionId));
    }

    // {IEAI721AgentAbility-depsAgents}
    function depsAgents(
        uint256 agentId,
        uint16 version
    )
        public
        view
        virtual
        returns (address[] memory)
    {
        return IAgent(_collectionIdToAgentAddress(agentId)).getDepsAgents(version);
    }

    // {IEAI721AgentAbility-agentCode}
    function agentCode(
        uint256 agentId,
        uint16 version
    )
        public
        view
        virtual
        returns (string memory code)
    {

        return IAgent(_collectionIdToAgentAddress(agentId)).getAgentCode(version);
    }


    // {IEAI721AgentAbility-currentVersion}
    function currentVersion(
        uint256 agentId
    ) public view virtual returns (uint16) {
        // return _currentVersion[agentId];
        return IAgent(_collectionIdToAgentAddress(agentId)).getCurrentVersion();
    }

    // {IEAI721AgentAbility-codeLanguage}
    function codeLanguage(
        uint256 agentId
    ) public view virtual returns (string memory) {
        // return _codeLanguage[agentId];
        return IAgent(_collectionIdToAgentAddress(agentId)).getCodeLanguage();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[43] private __gap;
}
