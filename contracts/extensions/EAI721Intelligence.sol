// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IAgentFactory} from "../agent-platform/interfaces/IAgentFactory.sol";
import {IAgent} from "../agent-platform/interfaces/IAgent.sol";
import {IEAI721Intelligence} from "../interfaces/IEAI721Intelligence.sol";
import {IDelegateRegistry} from "../interfaces/IDelegateRegistry.sol";

import "../libs/helpers/File.sol";

abstract contract EAI721Intelligence is
    Initializable,
    ERC721Upgradeable,
    IEAI721Intelligence
{
    using {read} for IFileStore.File;

    // --- Constants ---
    uint256 private constant TOKEN_LIMIT = 10000;
    bytes32 private constant IPFS_SIG = keccak256(bytes("ipfs"));
    address constant delegateRegistry =
        0x00000000000000447e69651d841bD8D104Bed493;
    bytes32 constant DELEGATE_RIGHT_ERC721 =
        0x0000000000000000000000000000000000000000000000000000000000000111;

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
        address agentOwner = ownerOf(agentId);
        
        if (
            msg.sender != agentOwner &&
            !checkAgentDelegate(msg.sender, agentOwner, agentId)
        ) revert EAI721IntelligenceAuth();

        _;
    }

    function checkAgentDelegate(
        address to,
        address from,
        uint256 agentId
    ) public view returns (bool) {
        return
            IDelegateRegistry(delegateRegistry).checkDelegateForERC721(
                to,
                from,
                address(this),
                agentId,
                DELEGATE_RIGHT_ERC721
            );
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
        bytes32 agentIdBytes = _collectionIdToAgentId(agentId);

        if (agentIdBytes == bytes32(0)) {
            _name[agentId] = name;
        } else {
            IAgentFactory(agentFactory).setAgentName(agentIdBytes, name);
        }

        emit AgentNameSet(agentId, name);
    }

    // {IEAI721AgentAbility-agentName}
    function agentName(
        uint256 agentId
    ) public view virtual returns (string memory) {
        address agent = _collectionIdToAgentAddress(agentId);

        if (agent == address(0)) {
            return _name[agentId];
        } else {
            return IAgent(agent).getAgentName();
        }
    }

    // {IEAI721AgentAbility-publishAgentCode}
    function publishAgentCode(
        uint256 agentId,
        string calldata codeLanguageIn,
        CodePointer[] calldata pointersIn,
        address[] calldata depsAgentsIn
    ) public virtual onlyAgentOwner(agentId) returns (uint16) {
        bytes32 agentIdBytes = _collectionIdToAgentId(agentId);
        return
            IAgentFactory(agentFactory).publishAgentCode(
                agentIdBytes,
                codeLanguageIn,
                pointersIn,
                depsAgentsIn
            );
    }

    function _collectionIdToAgentId(
        uint256 collectionId
    ) internal view returns (bytes32) {
        return IAgentFactory(agentFactory).collectionIdToAgentId(collectionId);
    }

    function _collectionIdToAgentAddress(
        uint256 collectionId
    ) internal view returns (address) {
        return
            IAgentFactory(agentFactory).agents(
                _collectionIdToAgentId(collectionId)
            );
    }

    // {IEAI721AgentAbility-depsAgents}
    function depsAgents(
        uint256 agentId,
        uint16 version
    ) public view virtual returns (address[] memory) {
        return
            IAgent(_collectionIdToAgentAddress(agentId)).getDepsAgents(version);
    }

    // {IEAI721AgentAbility-agentCode}
    function agentCode(
        uint256 agentId,
        uint16 version
    ) public view virtual returns (string memory code) {
        return
            IAgent(_collectionIdToAgentAddress(agentId)).getAgentCode(version);
    }

    // {IEAI721AgentAbility-currentVersion}
    function currentVersion(
        uint256 agentId
    ) public view virtual returns (uint16) {
        address agent = _collectionIdToAgentAddress(agentId);

        if (agent == address(0)) {
            return 0;
        } else {
            return IAgent(agent).getCurrentVersion();
        }
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
