// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

import {Events} from "../libraries/Events.sol";
import {DataTypes} from "../libraries/DataTypes.sol";
import {Errors} from "../libraries/Errors.sol";

/**
 * @title MentorMultiState
 * @author MentorDAO
 *
 * @notice This is an abstract contract that implements internal protocol state setting and validation.
 */
abstract contract MentorMultiState is Initializable {
    DataTypes.ProtocolState private _state;

    /**
     * @notice Initializes the MentorMultiState contract, setting the initial state.
     *
     * @param state The initial protocol state.
     */
    function _initialize(DataTypes.ProtocolState state) internal onlyInitializing {
        _setState(state);
    }

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

    /**
     * @notice Sets the new protocol state.
     *
     * @param newState The new protocol state.
     */
    function _setState(DataTypes.ProtocolState newState) internal {
        DataTypes.ProtocolState prevState = _state;
        _state = newState;

        emit Events.StateSet(msg.sender, prevState, newState);
    }

    function _validateNotPaused() internal view {
        if (_state == DataTypes.ProtocolState.Paused) revert Errors.Paused();
    }
}
