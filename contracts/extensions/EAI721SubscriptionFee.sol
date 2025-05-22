// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IEAI721SubscriptionFee} from "../interfaces/IEAI721SubscriptionFee.sol";

abstract contract EAI721SubscriptionFee is IEAI721SubscriptionFee, ERC721Upgradeable {
    // --- Modifiers ---
    modifier onlyAgentOwner(uint256 agentId) {
        if (msg.sender != ownerOf(agentId)) revert Unauthenticated();
        _;
    }

    // --- State Variables ---
    // agentId => subscription fee
    mapping(uint256 => uint256) private _subscriptionFees;
   
    // initialization
    function __EAI721SubscriptionFee_init() internal onlyInitializing {
    }

    function __EAI721SubscriptionFee_init_unchained() internal onlyInitializing {
    }

    // {IEAI721SubscriptionFee-subscriptionFee}
    function subscriptionFee(uint256 agentId) public virtual view returns (uint256) {
        return _subscriptionFees[agentId];
    }

    // {IEAI721SubscriptionFee-setSubscriptionFee}
    function setSubscriptionFee(uint256 agentId, uint256 fee) public virtual onlyAgentOwner(agentId) {
        _subscriptionFees[agentId] = fee;
        emit SubscriptionFeeUpdated(agentId, fee);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[44] private __gap;
}