// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {DataTypes} from "../../libraries/DataTypes.sol";

/**
 * @title MentorHubStorage
 * @author MentorDAO
 *
 * @notice This is an abstract contract that *only* contains storage for the MentorHub contract. This
 * must be inherited last (bar interfaces) in order to preserve the MentorHub storage layout. Adding
 * storage variables should be done solely at the bottom of this contract.
 */
abstract contract MentorHubStorage {
    uint256 internal _mentorsCounter;
    mapping(uint256 => DataTypes.MentorStruct) internal _mentorById;
}
