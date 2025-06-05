// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IOnchainArtData} from "../interfaces/IOnchainArtData.sol";
import {ERC721CInitializable} from "@limitbreak/creator-token-standards/src/erc721c/ERC721C.sol";

abstract contract EAI721Identity is Initializable, ERC721CInitializable {
    // --- State Variables ---
    address private _agentDataAddr;

    // --- Errors ---
    error InvalidAddr();
    error NotExist();
    error Existed();

    // initialization
    function __EAI721Identity_init() internal onlyInitializing {
        __EAI721Identity_init_unchained();
    }
    function __EAI721Identity_init_unchained() internal onlyInitializing {}

    function _setAgentDataAddr(address newAgentDataAddr) internal virtual {
        _agentDataAddr = newAgentDataAddr;
    }

    function agentDataAddr() public view virtual returns (address) {
        return _agentDataAddr;
    }

    function _mint(
        uint256 tokenId,
        address to,
        uint256 dna,
        uint256[6] memory traits
    ) internal virtual {
        if (to == address(0) || _agentDataAddr == address(0))
            revert InvalidAddr();
        if (_exists(tokenId)) revert Existed();

        _safeMint(to, tokenId);
        IOnchainArtData agentDataContract = IOnchainArtData(_agentDataAddr);
        agentDataContract.mintAgent(tokenId);
        agentDataContract.unlockRenderAgent(tokenId, dna, traits);
    }

    // {IEAI721-tokenURI}
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory result) {
        if (!_exists(tokenId)) revert NotExist();
        IOnchainArtData agentDataContract = IOnchainArtData(_agentDataAddr);
        result = agentDataContract.tokenURI(tokenId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[44] private __gap;
}
