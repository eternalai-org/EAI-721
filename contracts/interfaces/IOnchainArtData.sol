// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IOnchainArtData {
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
        uint256[6] memory traits
    ) external;

    /**
     * @notice Returns the attributes of an agent.
     * @param agentId The ID of the agent to query.
     * @return result The attributes of the agent as a string.
     */
    function agentAttributes(
        uint256 agentId
    ) external view returns (string memory result);

    /**
     * @notice Returns the SVG image of an agent in svg format.
     * @param agentId The ID of the agent to query.
     * @return result The SVG image of the agent as a string.
     */
    function agentImageSvg(
        uint256 agentId
    ) external view returns (string memory result);

    /**
     * @notice Returns the image of an agent in bytes format.
     * @param agentId The ID of the agent to query.
     * @return result The image of the agent as a bytes.
     */
    function agentImage(
        uint256 agentId
    ) external view returns (bytes memory result);
}
