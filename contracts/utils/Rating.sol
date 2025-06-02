// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IRating} from "../interfaces/IRating.sol";

abstract contract Rating is IRating, Initializable {
    // --- Constants ---
    uint8 public constant MAX_RATING = 5;
    uint8 public constant MIN_RATING = 1;

    // --- Storage ---
    uint256 private _ratingDecimals;
    mapping(uint256 agentId => uint256) private _totalStars;
    mapping(uint256 agentId => uint256) private _totalRatingCount;

    uint256[10] private __gap;

    // --- Initialization ---
    function __Rating_init(uint256 ratingDecimals_) internal onlyInitializing {
        __Rating_init_unchained(ratingDecimals_);
    }

    function __Rating_init_unchained(
        uint256 ratingDecimals_
    ) internal onlyInitializing {
        _ratingDecimals = ratingDecimals_;
    }

    // --- Functions ---
    function rateStar(uint256 agentId, uint8 stars) external {
        if (stars < MIN_RATING || stars > MAX_RATING) {
            revert RatingOutOfRange(stars);
        }
        // Add new rating
        _totalStars[agentId] += stars;
        _totalRatingCount[agentId]++;

        emit Rated(
            msg.sender,
            agentId,
            stars,
            _totalStars[agentId],
            _totalRatingCount[agentId]
        );
    }

    function ratingScore(uint256 agentId) external view returns (uint256) {
        if (_totalRatingCount[agentId] == 0) {
            return 0;
        }
        // Multiply by 100 for 2 decimal places
        // 451 means 4.51
        return
            (_totalStars[agentId] * _ratingDecimals) /
            _totalRatingCount[agentId];
    }

    function ratingDecimals() external view returns (uint256) {
        return _ratingDecimals;
    }

    function ratingCount(uint256 agentId) external view returns (uint256) {
        return _totalRatingCount[agentId];
    }
}
