// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IEAI721Monetization} from "../interfaces/IEAI721Monetization.sol";

abstract contract EAI721Monetization is ERC721Upgradeable, IEAI721Monetization {
    // --- Modifiers ---
    modifier onlyAgentOwner(uint256 agentId) virtual {
        if (msg.sender != ownerOf(agentId)) revert EAI721MonetizationAuth();
        _;
    }

    // --- State Variables ---
    // agentId => subscription fee
    mapping(uint256 => uint256) private _subscriptionFees;

    // initialization
    function __EAI721Monetization_init() internal onlyInitializing {}

    function __EAI721Monetization_init_unchained() internal onlyInitializing {}

    // {IEAI721Monetization-subscriptionFee}
    function subscriptionFee(uint256 agentId) public virtual view returns (uint256) {
        return _subscriptionFees[agentId];
    }

    // {IEAI721Monetization-setSubscriptionFee}
    function setSubscriptionFee(uint256 agentId, uint256 fee) public virtual onlyAgentOwner(agentId) {
        _subscriptionFees[agentId] = fee;
        emit SubscriptionFeeUpdated(agentId, fee);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[44] private __gap;
}