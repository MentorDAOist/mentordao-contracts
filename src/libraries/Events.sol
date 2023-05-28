// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {DataTypes} from "./DataTypes.sol";

library Events {
    /**
     * @dev Emitted when the hub state is set.
     *
     * @param caller The caller who set the state.
     * @param prevState The previous protocol state, an enum of either `Paused` or `Unpaused`.
     * @param newState The newly set state, an enum of either `Paused` or `Unpaused`.
     */
    event StateSet(
        address indexed caller, DataTypes.ProtocolState indexed prevState, DataTypes.ProtocolState indexed newState
    );

    /**
     * @dev Emitted when the governance address is changed. We emit the caller even though it should be the previous
     * governance address, as we cannot guarantee this will always be the case due to upgradeability.
     *
     * @param caller The caller who set the governance address.
     * @param prevGovernance The previous governance address.
     * @param newGovernance The new governance address set.
     */
    event GovernanceSet(address indexed caller, address indexed prevGovernance, address indexed newGovernance);

    /**
     * @dev Emitted when the emergency admin is changed. We emit the caller even though it should be the previous
     * governance address, as we cannot guarantee this will always be the case due to upgradeability.
     *
     * @param caller The caller who set the emergency admin address.
     * @param oldEmergencyAdmin The previous emergency admin address.
     * @param newEmergencyAdmin The new emergency admin address set.
     */
    event EmergencyAdminSet(
        address indexed caller, address indexed oldEmergencyAdmin, address indexed newEmergencyAdmin
    );

    /**
     * @dev Emitted when the mentor address is whitelisted.
     *
     * @param mentor The mentor's address to whitelist.
     * @param whitelist The boolean to set whitelist state.
     */
    event MentorWhitelisted(address indexed mentor, bool indexed whitelist);

    /**
     * @dev Emitted when the mentor profile is created.
     */
    event MentorProfileCreated(
        address indexed addr,
        uint256 indexed mentorId,
        string indexed handle,
        string fullname,
        string position,
        string aboutMe,
        string imageURI,
        uint256 usdPerSession,
        uint256 sessionDuration
    );

    /**
     * @dev Emitted when the mentor profile data is updated.
     */
    event MentorProfileUpdated(
        address indexed addr,
        uint256 indexed mentorId,
        string indexed handle,
        string fullname,
        string position,
        string aboutMe,
        string imageURI,
        uint256 usdPerSession,
        uint256 sessionDuration
    );
}
