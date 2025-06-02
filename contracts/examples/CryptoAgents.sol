// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {EAI721Intelligence, ERC721Upgradeable, Initializable} from "../extensions/EAI721Intelligence.sol";
import {EAI721Identity} from "../extensions/EAI721Identity.sol";
import {Errors} from "../libs/helpers/Errors.sol";
import {IOnchainArtData} from "../interfaces/IOnchainArtData.sol";
import {EAI721Monetization} from "../extensions/EAI721Monetization.sol";
import {EAI721Tokenization} from "../extensions/EAI721Tokenization.sol";

contract CryptoAgents is
    Initializable,
    EAI721Intelligence,
    EAI721Identity,
    EAI721Monetization,
    EAI721Tokenization
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    // -- errors --
    error Unauthenticated();

    // -- modifiers --
    modifier onlyAgentOwner(uint256 agentId) override(EAI721Intelligence, EAI721Tokenization, EAI721Monetization) {
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
    ) initializer public {
        _deployer = deployer;

        __ERC721_init(name, symbol);
        __EAI721Identity_init(1);
    }

    function changeDeployer(address newAdm) external onlyDeployer {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        if (_deployer != newAdm) {
            _deployer = newAdm;
        }
    }

    function allowAdmin(address newAdm, bool allow) external onlyDeployer {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admins[newAdm] = allow;
    }

    function changeCryptoAiDataAddress(address newAddr) external onlyDeployer {
        require(newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        _setCryptoAiDataAddr(newAddr);
    }

    //@EAI721Identity
    function mint(
        address to,
        uint256 dna,
        uint256[6] memory traits
    ) public virtual onlyAdmin {
        _mint(to, dna, traits);
    }

    function tokenURI(uint256 agentId) public view override(ERC721Upgradeable, EAI721Identity) returns (string memory) {
        return EAI721Identity.tokenURI(agentId);
    }

    function setRoyaltyReceiver(address newRoyaltyReceiver) external onlyAdmin {
        require(newRoyaltyReceiver != address(0), Errors.INV_ADD);
        _royaltyReceiver = newRoyaltyReceiver;
    }

    function getRoyaltyReceiver() external view returns (address) {
        return _royaltyReceiver;
    }

    /* @dev EIP2981 royalties implementation.
    // EIP2981 standard royalties return.
    */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view virtual returns (address receiver, uint256 royaltyAmount) {
        receiver = _royaltyReceiver;
        royaltyAmount = _salePrice * 0 / 10000;
    }

    uint256[50] private __gap;
}