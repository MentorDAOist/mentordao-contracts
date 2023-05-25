// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { Events } from '../../libraries/Events.sol';
import { DataTypes } from '../../libraries/DataTypes.sol';
import { Errors } from '../../libraries/Errors.sol';

/**
 * @title MentorHubMultiState
 * @author MentorDAO
 *
 * @notice This is an abstract contract that implements internal MentorHub state setting and validation.
 */
abstract contract MentorHubMultiState {
    DataTypes.ProtocolState private _state;

    modifier whenNotPaused() {
        _validateNotPaused();
        _;
    }

    /**
     * @notice Returns the current protocol state.
     *
     * @return ProtocolState The Protocol state, an enum, where:
     *      0: Unpaused
     *      1: Paused
     */
    function getState() external view returns (DataTypes.ProtocolState) {
        return _state;
    }

    function _setState(DataTypes.ProtocolState newState) internal {
        DataTypes.ProtocolState prevState = _state;
        _state = newState;
        emit Events.StateSet(msg.sender, prevState, newState, block.timestamp);
    }

    function _validateNotPaused() internal view {
        if (_state == DataTypes.ProtocolState.Paused) revert Errors.Paused();
    }
}
