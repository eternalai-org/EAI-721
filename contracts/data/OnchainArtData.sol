// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IEAI721Intelligence.sol";
import "../interfaces/IEAI721Tokenization.sol";
import "../interfaces/IEAI721Monetization.sol";
import "../interfaces/IOnchainArtData.sol";
import "../libs/structs/CryptoAIStructs.sol";
import "../libs/helpers/Errors.sol";

contract OnchainArtData is Ownable, IOnchainArtData {
    uint256 public constant TOKEN_LIMIT = 0x2710;
    uint8 internal constant GRID_SIZE = 0x18;
    bytes16 internal constant _HEX_SYMBOLS = "0123456789abcdef";
    string private constant svgDataType = "data:image/svg+xml;utf8,";
    string internal constant SVG_HEADER =
        "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'>";
    string internal constant SVG_FOOTER = "</svg>";
    string internal constant SVG_RECT = "<rect x='";
    string internal constant SVG_Y = "' y='";
    string internal constant SVG_WIDTH = "' width='1' height='1' fill='%23";
    string internal constant SVG_CLOSE_RECT = "'/>";
    // placeholder
    string private constant htmlDataType = "data:text/html;base64,";
    string internal constant PLACEHOLDER_HEADER = "<script>let TokenID='";
    string internal constant PLACEHOLDER_FOOTER = "'</script>";

    // elements
    string[6] private partsName;
    // crypto ai agent address
    address public _cryptoAIAgentAddr;
    // seal flag
    bool private _contractSealed;

    // assets image after unlocking
    mapping(uint256 => CryptoAIStructs.Token) private unlockedTokens;
    mapping(string => CryptoAIStructs.ItemDetail) private items;

    // palette colors
    uint8[][] private palettes;
    CryptoAIStructs.DNA_TYPE private DNA_TYPES;
    mapping(bytes32 => bool) private usedPairs;

    // assets placeholder before unlocking
    string internal PLACEHOLDER_SCRIPT;
    string internal PLACEHOLDER_IMG;

    modifier unsealed() {
        require(!_contractSealed, Errors.CONTRACT_SEALED);
        _;
    }

    modifier _sealed() {
        require(_contractSealed, Errors.CONTRACT_SEALED);
        _;
    }

    modifier onlyAIAgentContract() {
        require(msg.sender == _cryptoAIAgentAddr, Errors.ONLY_AGENT_CONTRACT);
        _;
    }

    constructor() Ownable() {
        partsName = ["dna", "Collar", "Head", "Eyes", "Mouth", "Earring"];
    }

    function changePlaceHolderScript(
        string memory content
    ) external onlyOwner unsealed {
        PLACEHOLDER_SCRIPT = content;
    }

    function changePlaceHolderImg(
        string memory content
    ) external onlyOwner unsealed {
        PLACEHOLDER_IMG = content;
    }

    function changeCryptoAIAgentAddress(
        address newAddr
    ) external onlyOwner unsealed {
        require(newAddr != address(0), Errors.INV_ADD);
        if (_cryptoAIAgentAddr != newAddr) {
            _cryptoAIAgentAddr = newAddr;
        }
    }

    function sealContract() external unsealed onlyOwner {
        _contractSealed = true;
    }

    function unSealContract() external _sealed onlyOwner {
        _contractSealed = false;
    }

    function mintAgent(uint256 tokenId) external onlyAIAgentContract _sealed {
        require(_cryptoAIAgentAddr != address(0), Errors.INV_ADD);
        require(unlockedTokens[tokenId].tokenID == 0, Errors.TOKEN_ID_UNLOCKED);
        unlockedTokens[tokenId].tokenID = tokenId;
    }

    function unlockRenderAgent(
        uint256 tokenId,
        uint256 dna,
        uint256[6] memory traits
    ) external onlyAIAgentContract _sealed {
        // agent is minted on nft collection, and unlock render svg by rarity info
        require(
            unlockedTokens[tokenId].tokenID > 0,
            Errors.TOKEN_ID_NOT_EXISTED
        );
        require(unlockedTokens[tokenId].weight == 0, Errors.TOKEN_ID_UNLOCKED);
        unlockedTokens[tokenId].weight = 1;

        bytes32 pairHash = keccak256(abi.encodePacked(traits, dna));
        require(!usedPairs[pairHash], Errors.USED_PAIRs);
        usedPairs[pairHash] = true;
        unlockedTokens[tokenId].traits = traits;
        unlockedTokens[tokenId].dna = dna;
    }

    function checkUsedPairs(
        uint256[] memory traits
    ) public view returns (bool) {
        return usedPairs[keccak256(abi.encodePacked(traits))];
    }

    function tokenURI(
        uint256 tokenId
    ) external view returns (string memory result) {
        require(tokenId <= TOKEN_LIMIT, Errors.INV_TOKEN);
        require(
            unlockedTokens[tokenId].tokenID > 0,
            Errors.TOKEN_ID_NOT_EXISTED
        );
        result = string(
            abi.encodePacked(
                '{"name": "CryptoAgent #',
                Strings.toString(tokenId),
                '",',
                '"description": "The first-ever PFP collection for AI agents.",',
                '"image_data": "ipfs://bafybeibqwfzmw2vsg4ycmvyrdkd6ea6lsdnfuuypx5r7yixfppap6knr5a/',
                Strings.toString(tokenId),
                '.png",',
                '"image": "',
                agentImageSvg(tokenId),
                '", "attributes": ',
                agentAttributes(tokenId),
                "}"
            )
        );
    }

    function addDNA(
        string[] memory _names,
        uint16[] memory rarities
    ) public onlyOwner unsealed {
        DNA_TYPES.names = _names;
    }

    function addDNAVariant(
        string memory _DNAType,
        string[] memory _DNAName,
        uint16[] memory _rarities,
        uint16[][] memory _positions
    ) public onlyOwner unsealed {
        items[_DNAType].names = _DNAName;
        items[_DNAType].positions = _positions;
    }

    function addItem(
        string memory _itemType,
        string[] memory _names,
        uint256[] memory _rarities,
        uint16[][] memory _positions
    ) public onlyOwner unsealed {
        items[_itemType].names = _names;
        items[_itemType].positions = _positions;
    }

    function addMoreItem(
        string memory _itemType,
        string[] memory _names,
        uint256[] memory _rarities,
        uint16[][] memory _positions
    ) public onlyOwner unsealed {
        // Get existing data
        string[] memory existingNames = items[_itemType].names;
        uint16[][] memory existingPositions = items[_itemType].positions;

        // Create new arrays with combined length
        string[] memory newNames = new string[](
            existingNames.length + _names.length
        );
        uint16[][] memory newPositions = new uint16[][](
            existingPositions.length + _positions.length
        );

        // Copy existing data
        for (uint i = 0; i < existingNames.length; i++) {
            newNames[i] = existingNames[i];
            newPositions[i] = existingPositions[i];
        }

        // Append new data
        for (uint i = 0; i < _names.length; i++) {
            newNames[existingNames.length + i] = _names[i];
            newPositions[existingPositions.length + i] = _positions[i];
        }

        // Update storage
        items[_itemType].names = newNames;
        items[_itemType].positions = newPositions;
    }

    function setPalettes(uint8[][] memory _pallets) public onlyOwner unsealed {
        palettes = _pallets;
    }

    function agentAttributesValue(
        uint256 tokenId
    ) public view returns (string[] memory) {
        string[] memory attrs = new string[](partsName.length);
        for (uint8 i = 0; i < partsName.length; i++) {
            string memory value;
            if (i == 0) {
                value = items[DNA_TYPES.names[unlockedTokens[tokenId].dna]]
                    .names[unlockedTokens[tokenId].traits[i]];
            } else {
                value = items[partsName[i]].names[
                    unlockedTokens[tokenId].traits[i]
                ];
            }
            attrs[i] = value;
        }
        return attrs;
    }

    function agentAttributes(
        uint256 tokenId
    ) public view returns (string memory text) {
        bytes memory byteString;
        uint count = 0;
        for (uint8 i = 0; i < partsName.length; i++) {
            string memory traitName;
            string memory value;
            if (i == 0) {
                traitName = "DNA";
                value = DNA_TYPES.names[unlockedTokens[tokenId].dna];
            } else {
                traitName = partsName[i];
                value = items[partsName[i]].names[
                    unlockedTokens[tokenId].traits[i]
                ];
            }
            if (bytes(value).length != 0) {
                bytes memory objString = abi.encodePacked(
                    '{"trait_type":"',
                    traitName,
                    '","value":"',
                    value,
                    '"}'
                );
                if (i > 0) {
                    byteString = abi.encodePacked(byteString, ",");
                    count++;
                }
                byteString = abi.encodePacked(byteString, objString);
            }
        }

        byteString = abi.encodePacked(
            '{"trait_type": "Intelligence"',
            ',"value":"',
            IEAI721Intelligence(_cryptoAIAgentAddr).currentVersion(tokenId) > 0
                ? "Yes"
                : "Not yet",
            '"},',
            byteString
        );

        byteString = abi.encodePacked(
            '{"trait_type": "Tokenization"',
            ',"value":"',
            IEAI721Tokenization(_cryptoAIAgentAddr).aiToken(tokenId) !=
                address(0)
                ? "Yes"
                : "Not yet",
            '"},',
            byteString
        );

        byteString = abi.encodePacked(
            '{"trait_type": "Monetization"',
            ',"value":"',
            IEAI721Monetization(_cryptoAIAgentAddr).subscriptionFee(tokenId) > 0
                ? "Yes"
                : "Not yet",
            '"},',
            byteString
        );

        byteString = abi.encodePacked(
            '{"trait_type": "Number of Attributes"',
            ',"value":"',
            Strings.toString(count),
            '"},',
            byteString
        );

        text = string(abi.encodePacked("[", string(byteString), "]"));
    }

    function fractionalStr(
        uint fractionalPart,
        uint8 dec
    ) internal pure returns (string memory res) {
        while (fractionalPart > 0 && dec > 0) {
            if (fractionalPart % 10 == 0) {
                fractionalPart /= 10;
                dec--;
            } else {
                break;
            }
        }

        res = Strings.toString(fractionalPart);
        if (bytes(res).length < dec) {
            for (uint i = bytes(res).length; i < dec; i++) {
                res = string(abi.encodePacked("0", res));
            }
        }
    }

    function cryptoAIImage(uint256 tokenId) public view returns (bytes memory) {
        require(
            unlockedTokens[tokenId].tokenID > 0 &&
                unlockedTokens[tokenId].weight > 0,
            Errors.TOKEN_ID_NOT_UNLOCKED
        );

        uint16[][] memory data = new uint16[][](6);
        bytes[] memory dataPalette = new bytes[](6);
        for (uint256 i = 0; i < partsName.length; i++) {
            if (i == 0) {
                data[i] = items[DNA_TYPES.names[unlockedTokens[tokenId].dna]]
                    .positions[unlockedTokens[tokenId].traits[i]];
            } else {
                data[i] = items[partsName[i]].positions[
                    unlockedTokens[tokenId].traits[i]
                ];
            }
            uint256 k = 0;
            dataPalette[i] = new bytes((data[i].length / 3) * 5);
            for (uint256 j; j < data[i].length; j++) {
                if (!((j >= 2) && ((j - 2) % 3 == 0))) {
                    dataPalette[i][k] = bytes1(uint8(data[i][j]));
                } else {
                    uint8[] memory p = palettes[data[i][j]];
                    dataPalette[i][k] = bytes1(p[0]);
                    dataPalette[i][k + 1] = bytes1(p[1]);
                    dataPalette[i][k + 2] = bytes1(p[2]);
                    k += 2;
                }
                k++;
            }
        }
        bytes memory pixels = new bytes(2304);
        uint256 totalLength = dataPalette[0].length +
            dataPalette[1].length +
            dataPalette[2].length +
            dataPalette[3].length +
            dataPalette[4].length +
            dataPalette[5].length;
        for (uint256 i = 0; i < totalLength; i += 5) {
            uint256 idx;
            bytes memory pos;
            uint256 offset = dataPalette[0].length;
            uint256 prevOffset = 0;
            for (uint256 j = 0; j < 6; j++) {
                if (i < offset) {
                    pos = dataPalette[j];
                    idx = i - prevOffset;
                    break;
                }
                prevOffset = offset;
                if (j < 5) {
                    offset += dataPalette[j + 1].length;
                }
            }
            uint16 p = (uint16(uint8(pos[idx + 1])) *
                GRID_SIZE +
                uint16(uint8(pos[idx]))) << 2;

            assembly {
                let posData := add(pos, 0x20)
                let pixelsData := add(pixels, 0x20)

                mstore8(
                    add(pixelsData, p),
                    byte(0, mload(add(posData, add(idx, 2))))
                )
                mstore8(
                    add(pixelsData, add(p, 1)),
                    byte(0, mload(add(posData, add(idx, 3))))
                )
                mstore8(
                    add(pixelsData, add(p, 2)),
                    byte(0, mload(add(posData, add(idx, 4))))
                )
                mstore8(add(pixelsData, add(p, 3)), 0xFF)
            }
        }

        return pixels;
    }

    function cryptoAIImageHtml(
        uint256 tokenId
    ) public view returns (string memory result) {
        return
            string(
                abi.encodePacked(PLACEHOLDER_SCRIPT, Strings.toString(tokenId))
            );
    }

    function agentImageSvg(
        uint256 tokenId
    ) public view returns (string memory result) {
        require(
            unlockedTokens[tokenId].tokenID > 0 &&
                unlockedTokens[tokenId].weight > 0,
            Errors.TOKEN_ID_NOT_UNLOCKED
        );

        bytes memory pixels = cryptoAIImage(tokenId);
        string memory svg = "";
        bytes memory buffer = new bytes(8);
        uint p;
        for (uint y = 0; y < 24; y++) {
            for (uint x = 0; x < 24; x++) {
                assembly {
                    let multipliedY := mul(y, 24)
                    let sum := add(multipliedY, x)
                    p := mul(sum, 4)
                }
                if (uint8(pixels[p + 3]) > 0) {
                    assembly {
                        let hexSymbols := _HEX_SYMBOLS
                        let bufferPtr := add(buffer, 0x20)
                        let pixelsPtr := add(add(pixels, 0x20), p)
                        for {
                            let k := 0
                        } lt(k, 4) {
                            k := add(k, 1)
                        } {
                            let value := byte(0, mload(add(pixelsPtr, k)))
                            mstore8(
                                add(bufferPtr, add(mul(k, 2), 1)),
                                byte(and(value, 0xf), hexSymbols)
                            )
                            value := shr(4, value)
                            mstore8(
                                add(bufferPtr, mul(k, 2)),
                                byte(and(value, 0xf), hexSymbols)
                            )
                        }
                    }

                    svg = string(
                        abi.encodePacked(
                            svg,
                            abi.encodePacked(
                                SVG_RECT,
                                Strings.toString(x),
                                SVG_Y,
                                Strings.toString(y),
                                SVG_WIDTH,
                                string(buffer),
                                SVG_CLOSE_RECT
                            )
                        )
                    );
                }
            }
        }
        result = string(
            abi.encodePacked(svgDataType, SVG_HEADER, svg, SVG_FOOTER)
        );
    }
}
