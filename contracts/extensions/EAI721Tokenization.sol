// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IEAI721Tokenization} from "../interfaces/IEAI721Tokenization.sol";

abstract contract EAI721Tokenization is Initializable, ERC721Upgradeable, IEAI721Tokenization  {
    // agentId => AI token address
    mapping(uint256 => address) private _aiTokens;

    modifier onlyAgentOwner(uint256 agentId) virtual {
        if (msg.sender != ownerOf(agentId)) revert EAI721TokenizationAuth();
        _;
    }

    // --- Initialization ---
    function __EAI721Tokenization_init() internal onlyInitializing {
    }

    function __EAI721Tokenization_init_unchained() internal onlyInitializing {
    }

    // {IEAI721Tokenization-setAITokenAddress}
    function setAITokenAddress(uint256 agentId, address newAIToken) public virtual onlyAgentOwner(agentId) {
        if (newAIToken == address(0)) revert InvalidAddress();
        _aiTokens[agentId] = newAIToken;

        emit AITokenAddressUpdated(agentId, newAIToken);
    }

    // {IEAI721Tokenization-aiToken}
    function aiToken(uint256 agentId) public virtual view returns (address) {
        return _aiTokens[agentId];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[44] private __gap;
}