// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { IMentorHub } from '../interfaces/IMentorHub.sol';
import { MentorHubMultiState } from './base/MentorHubMultiState.sol';
import { MentorHubGov } from './base/MentorHubGov.sol';
import { MentorHubStorage } from './storage/MentorHubStorage.sol';
import { VersionedInitializable } from '../upgradeability/VersionedInitializable.sol';
import { DataTypes } from '../libraries/DataTypes.sol';
import { Events } from '../libraries/Events.sol';
import { Errors } from '../libraries/Errors.sol';

/**
 * @title MentorHub
 * @author MentorDAO
 *
 * @notice This is the main entrypoint of the MentorDAO Protocol. It contains governance functionality as well as
 * donating and mentor interaction functionality.
 */
contract MentorHub is IMentorHub, MentorHubGov, MentorHubMultiState, MentorHubStorage, VersionedInitializable {

    /// @inheritdoc IMentorHub
    function initialize(
        address newGovernance
    ) external override initializer {
        _setState(DataTypes.ProtocolState.Paused);
        _setGovernance(newGovernance);
    }

    // ***********************
    // ******VERSIONING*******
    // ***********************

    uint256 internal constant REVISION = 1;

    function getRevision() internal pure virtual override returns (uint256) {
        return REVISION;
    }

    // ***********************
    // *****GOV FUNCTIONS*****
    // ***********************

    /// @inheritdoc IMentorHub
    function setGovernance(address newGovernance) external override onlyGovernance {
        _setGovernance(newGovernance);
    }

    /// @inheritdoc IMentorHub
    function setEmergencyAdmin(address newEmergencyAdmin) external override onlyGovernance {
        _setEmergencyAdmin(newEmergencyAdmin);
    }

    // ***********************
    // *****MULTI STATE*******
    // ***********************

    /// @inheritdoc IMentorHub
    function setState(DataTypes.ProtocolState newState) external override onlyGovernanceOrEmergencyAdmin {
        if (msg.sender == _emergencyAdmin) {
            if (newState == DataTypes.ProtocolState.Unpaused)
                revert Errors.EmergencyAdminCannotUnpause();
            _validateNotPaused();
        }
        _setState(newState);
    }

}