// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRating {
    // --- Events ---
    event Rated(
        address indexed user,
        uint256 indexed agentId,
        uint8 indexed stars,
        uint256 newTotalStarsSum,
        uint256 newTotalRatingCount
    );

    // --- Custom Errors ---
    error RatingOutOfRange(uint8 stars);

    // --- State-Changing Functions ---
    function rateStar(uint256 agentId, uint8 stars) external;

    // --- View functions ---
    function ratingScore(uint256 agentId) external view returns (uint256);
    function ratingCount(uint256 agentId) external view returns (uint256);
    function ratingDecimals() external view returns (uint256);
}
