// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC2981Upgradeable} from "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {EAI721Intelligence, ERC721Upgradeable, Initializable} from "../extensions/EAI721Intelligence.sol";
import {EAI721Identity, IOnchainArtData} from "../extensions/EAI721Identity.sol";
import {EAI721Monetization} from "../extensions/EAI721Monetization.sol";
import {EAI721Tokenization} from "../extensions/EAI721Tokenization.sol";
import {Rating} from "../utils/Rating.sol";
import {Errors} from "../libs/helpers/Errors.sol";

contract CryptoAgents is
    Initializable,
    OwnableUpgradeable,
    EAI721Intelligence,
    EAI721Identity,
    EAI721Monetization,
    EAI721Tokenization,
    ERC2981Upgradeable,
    Rating
{
    // --- Constants ---
    uint256 private constant TOKEN_SUPPLY_LIMIT = 10000;

    // -- errors --
    error Unauthenticated();
    error InvalidTokenId();
    error InvalidFactoryAddress();

    // -- modifiers --
    modifier onlyAgentOwner(uint256 agentId)
        override(EAI721Intelligence, EAI721Tokenization, EAI721Monetization) {
        if (msg.sender != ownerOf(agentId)) revert Unauthenticated();
        _;
    }

    // -- events --
    event AdminAllowed(address indexed admin, bool allowed);
    event AgentDataAddressChanged(address indexed newAddr);

    // -- state variables --
    // admins
    mapping(address => bool) private _admins;

    modifier onlyAdmin() {
        require(_admins[msg.sender], Errors.ONLY_ADMIN_ALLOWED);
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address defaultRoyaltyReceiver_
    ) public initializer {
        __Ownable_init();
        __ERC721_init(name_, symbol_);
        __EAI721Intelligence_init();
        __EAI721Identity_init();
        __Rating_init(100);
        __EAI721Monetization_init();
        __EAI721Tokenization_init();
        __ERC2981_init();

        _setDefaultRoyalty(defaultRoyaltyReceiver_, 500);
    }

    function allowAdmin(address newAdm, bool allow) external onlyOwner {
        require(newAdm != address(0), Errors.INV_ADD);
        _admins[newAdm] = allow;
        emit AdminAllowed(newAdm, allow);
    }

    function isAdmin(address admin) external view returns (bool) {
        return _admins[admin];
    }

    function changeAgentDataAddress(address newAddr) external onlyOwner {
        require(newAddr != address(0), Errors.INV_ADD);

        _setAgentDataAddr(newAddr);
        emit AgentDataAddressChanged(newAddr);
    }

    //@EAI721Identity
    function mint(
        uint256 tokenId,
        address to,
        uint256 dna,
        uint256[6] memory traits
    ) external virtual onlyAdmin {
        if (tokenId == 0 || tokenId > TOKEN_SUPPLY_LIMIT)
            revert InvalidTokenId();

        _mint(tokenId, to, dna, traits);
    }

    function tokenURI(
        uint256 agentId
    )
        public
        view
        override(ERC721Upgradeable, EAI721Identity)
        returns (string memory)
    {
        return EAI721Identity.tokenURI(agentId);
    }

    function agentAttributes(
        uint256 agentId
    ) external view returns (string memory) {
        return IOnchainArtData(agentDataAddr()).agentAttributes(agentId);
    }

    function agentImageSvg(
        uint256 agentId
    ) external view returns (string memory) {
        return IOnchainArtData(agentDataAddr()).agentImageSvg(agentId);
    }

    function agentImage(uint256 agentId) external view returns (bytes memory) {
        return IOnchainArtData(agentDataAddr()).agentImage(agentId);
    }

    function setDefaultRoyalty(
        address newRoyaltyReceiver,
        uint96 feeNumerator
    ) external onlyAdmin {
        _setDefaultRoyalty(newRoyaltyReceiver, feeNumerator);
    }

    function deleteDefaultRoyalty() external onlyAdmin {
        _deleteDefaultRoyalty();
    }

    function setTokenRoyalty(
        uint256 tokenId,
        address newRoyaltyReceiver,
        uint96 feeNumerator
    ) external onlyAdmin {
        _setTokenRoyalty(tokenId, newRoyaltyReceiver, feeNumerator);
    }

    function resetTokenRoyalty(uint256 tokenId) external onlyAdmin {
        _resetTokenRoyalty(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, ERC2981Upgradeable)
        returns (bool)
    {
        return
            ERC721Upgradeable.supportsInterface(interfaceId) ||
            ERC2981Upgradeable.supportsInterface(interfaceId);
    }

    function setAgentFactory(address factory) public virtual onlyOwner {
        if (factory == address(0)) revert InvalidFactoryAddress();

        agentFactory = factory;
    }

    uint256[50] private __gap;
}
