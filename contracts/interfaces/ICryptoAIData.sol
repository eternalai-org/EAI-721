// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface ICryptoAIData {
    /**
     * @notice Returns the metadata URI for a given token ID.
     * @param tokenId The ID of the token to query.
     * @return result The metadata URI as a string.
     */
    function tokenURI(
        uint256 tokenId
    ) external view returns (string memory result);

    /**
     * @notice Mints a new agent with the specified token ID.
     * @param tokenId The ID of the token to mint.
     */
    function mintAgent(uint256 tokenId) external;

    /**
     * @notice Unlocks the render agent for a given token, setting its DNA and traits.
     * @param tokenId The ID of the token to unlock.
     * @param dna The DNA value to assign to the agent.
     * @param traits An array of 5 trait values to assign to the agent.
     */
    function unlockRenderAgent(
        uint256 tokenId,
        uint256 dna,
        uint256[5] memory traits
    ) external;
}
