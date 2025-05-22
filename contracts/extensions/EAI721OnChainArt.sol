// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Upgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ICryptoAIData} from "../interfaces/ICryptoAIData.sol";

abstract contract EAI721OnChainArt is  ERC721Upgradeable {
    // --- Constants ---
    uint256 public constant TOKEN_SUPPLY_LIMIT = 10000;

    // --- State Variables ---
    uint256 private _indexMint;
    address private _cryptoAiDataAddr;

    // --- Errors ---
    error InvalidAddr();
    error NotExist();

    // initialization
    function __EAI721OnChainArt_init(uint256 indexMint) internal onlyInitializing {
        __EAI721OnChainArt_init_unchained(indexMint);
    }
    function __EAI721OnChainArt_init_unchained(uint256 indexMint) internal onlyInitializing {
        _indexMint = indexMint;
    }

    function _setCryptoAiDataAddr(address newCryptoAiDataAddr) internal {
        _cryptoAiDataAddr = newCryptoAiDataAddr;
    }

    function cryptoAiDataAddr() public view virtual returns (address) {
        return _cryptoAiDataAddr;
    }

    function _mint(
        address to,
        uint256 dna,
        uint256[6] memory traits
    ) internal virtual {
        if (to == address(0) || _cryptoAiDataAddr == address(0)) revert InvalidAddr();

        require(_indexMint <= TOKEN_SUPPLY_LIMIT);
        _safeMint(to, _indexMint);
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(_cryptoAiDataAddr);
        cryptoAIDataContract.mintAgent(_indexMint);
        cryptoAIDataContract.unlockRenderAgent(_indexMint, dna, traits);

        _indexMint += 1;
    }

    // {IEAI721-tokenURI}
    function tokenURI(uint256 tokenId) public virtual view override returns (string memory result) {
        require(_exists(tokenId), 'ERC721: Token does not exist');
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(_cryptoAiDataAddr);
        result = cryptoAIDataContract.tokenURI(tokenId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[44] private __gap;
}
