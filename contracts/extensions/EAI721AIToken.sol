// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IEAI721AIToken} from "../interfaces/IEAI721AIToken.sol";
import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

abstract contract EAI721AIToken is IEAI721AIToken, Initializable, ERC721Upgradeable {
    // agentId => AI token address
    mapping(uint256 => address) private _aiTokens;

    modifier onlyAgentOwner(uint256 agentId) {
        if (msg.sender != ownerOf(agentId)) revert Unauthenticated();
        _;
    }

    // --- Initialization ---
    function __EAI721AIToken_init() internal onlyInitializing {
    }

    function __EAI721AIToken_init_unchained() internal onlyInitializing {
    }

    // {IEAI721AIToken-setAITokenAddress}
    function setAITokenAddress(uint256 agentId, address newAIToken) external virtual onlyAgentOwner(agentId) {
        if (newAIToken == address(0)) revert InvalidAddress();
        _aiTokens[agentId] = newAIToken;

        emit AITokenAddressUpdated(agentId, newAIToken);
    }

    // {IEAI721AIToken-aiToken}
    function aiToken(uint256 agentId) external virtual view returns (address) {
        return _aiTokens[agentId];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[44] private __gap;
}