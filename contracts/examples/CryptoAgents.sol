// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {EAI721Intelligence, ERC721Upgradeable, Initializable} from "../extensions/EAI721Intelligence.sol";
import {EAI721Identity} from "../extensions/EAI721Identity.sol";
import {EAI721Monetization} from "../extensions/EAI721Monetization.sol";
import {EAI721Tokenization} from "../extensions/EAI721Tokenization.sol";
import {Rating} from "../utils/Rating.sol";
import {Errors} from "../libs/helpers/Errors.sol";

contract CryptoAgents is
    Initializable,
    EAI721Intelligence,
    EAI721Identity,
    EAI721Monetization,
    EAI721Tokenization,
    Rating
{
    // --- Constants ---
    uint256 public constant TOKEN_SUPPLY_LIMIT = 10000;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // -- errors --
    error Unauthenticated();
    error InvalidTokenId();

    // -- modifiers --
    modifier onlyAgentOwner(uint256 agentId)
        override(EAI721Intelligence, EAI721Tokenization, EAI721Monetization) {
        if (msg.sender != ownerOf(agentId)) revert Unauthenticated();
        _;
    }

    // -- state variables --
    // royalty receiver
    address private _royaltyReceiver;
    // deployer
    address public _deployer;
    // admins
    mapping(address => bool) public _admins;

    modifier onlyDeployer() {
        require(msg.sender == _deployer, Errors.ONLY_DEPLOYER);
        _;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender], Errors.ONLY_ADMIN_ALLOWED);
        _;
    }

    function initialize(
        string memory name,
        string memory symbol,
        address deployer
    ) public initializer {
        require(deployer != address(0), Errors.INV_ADD);

        _deployer = deployer;

        __ERC721_init(name, symbol);
        __EAI721Intelligence_init();
        __EAI721Identity_init();
        __Rating_init(100);
        __EAI721Monetization_init();
        __EAI721Tokenization_init();
    }

    function changeDeployer(address newDeployer) external onlyDeployer {
        require(newDeployer != address(0), Errors.INV_ADD);
        if (_deployer != newDeployer) {
            _deployer = newDeployer;
        }
    }

    function allowAdmin(address newAdm, bool allow) external onlyDeployer {
        require(newAdm != address(0), Errors.INV_ADD);
        _admins[newAdm] = allow;
    }

    function changeCryptoAIDataAddress(address newAddr) external onlyDeployer {
        require(newAddr != address(0), Errors.INV_ADD);

        _setCryptoAIDataAddr(newAddr);
    }

    //@EAI721Identity
    function mint(
        uint256 tokenId,
        address to,
        uint256 dna,
        uint256[6] memory traits
    ) public virtual onlyAdmin {
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

    function setRoyaltyReceiver(address newRoyaltyReceiver) external onlyAdmin {
        require(newRoyaltyReceiver != address(0), Errors.INV_ADD);
        _royaltyReceiver = newRoyaltyReceiver;
    }

    function royaltyReceiver() external view returns (address) {
        return _royaltyReceiver;
    }

    /* @dev EIP2981 royalties implementation.
        EIP2981 standard royalties return.
    */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view virtual returns (address receiver, uint256 royaltyAmount) {
        receiver = _royaltyReceiver;
        royaltyAmount = (_salePrice * 500) / 10000; // 5%
    }

    uint256[50] private __gap;
}
