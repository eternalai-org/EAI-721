// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {EAI721AgentAbility, ERC721Upgradeable, Initializable} from "../extensions/EAI721AgentAbility.sol";
import {EAI721OnChainArt} from "../extensions/EAI721OnChainArt.sol";
import {Errors} from "../libs/helpers/Errors.sol";
import {ICryptoAIData} from "../interfaces/ICryptoAIData.sol";

contract CryptoAI is
    Initializable,
    AccessControlUpgradeable,
    EAI721AgentAbility,
    EAI721OnChainArt
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    // -- state variables --
    address private _royaltyReceiver;

    function initialize(
        string memory name,
        string memory symbol,
        address deployer
    ) initializer public {
        _grantRole(DEFAULT_ADMIN_ROLE, deployer);

        __ERC721_init(name, symbol);
        __EAI721OnChainArt_init(1);
    }

    function changeCryptoAiDataAddress(address newAddr) external onlyRole(ADMIN_ROLE) {
        require(newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        _setCryptoAiDataAddr(newAddr);
    }

    //@EAI721OnChainArt
    function mint(
        address to,
        uint256 dna,
        uint256[5] memory traits
    ) public virtual onlyRole(ADMIN_ROLE) {
        _mint(to, dna, traits);
    }

    function unlock(uint256 tokenId, uint256 dna, uint256[5] memory traits) public virtual payable {
        require(cryptoAiDataAddr() != Errors.ZERO_ADDR, Errors.INV_ADD);
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(cryptoAiDataAddr());
        cryptoAIDataContract.unlockRenderAgent(tokenId, dna, traits);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, ERC721Upgradeable) returns (bool) {
        return
            AccessControlUpgradeable.supportsInterface(interfaceId) ||
            ERC721Upgradeable.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 agentId) public view override(ERC721Upgradeable, EAI721OnChainArt) returns (string memory) {
        return EAI721OnChainArt.tokenURI(agentId);
    }

    function setRoyaltyReceiver(address newRoyaltyReceiver) external onlyRole(ADMIN_ROLE) {
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