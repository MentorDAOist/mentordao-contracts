// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { DataTypes } from '../libraries/DataTypes.sol';

/**
 * @title IMentorHub
 * @author MentorDAO
 *
 * @notice This is the interface for the MentorHub contract, the main entry point for the MentorDAO Protocol.
 * You'll find all the events and external functions, as well as the reasoning behind them here.
 */
interface IMentorHub {
    /**
     * @notice Initializes the MentorHub contract, setting the initial governance address.
     *
     * @param newGovernance The governance address to set.
     */
    function initialize(
        address newGovernance
    ) external;

    /**
     * @notice Sets the privileged governance role. This function can only be called by the current governance
     * address.
     *
     * @param newGovernance The new governance address to set.
     */
    function setGovernance(address newGovernance) external;

    /**
     * @notice Sets the emergency admin, which is a permissioned role able to set the protocol state. This function
     * can only be called by the governance address.
     *
     * @param newEmergencyAdmin The new emergency admin address to set.
     */
    function setEmergencyAdmin(address newEmergencyAdmin) external;

    /**
     * @notice Sets the protocol state to either a global pause or an unpaused state. This function
     * can only be called by the governance address or the emergency admin address.
     *
     * Note that this reverts if the emergency admin calls it if:
     *      1. The emergency admin is attempting to unpause.
     *      2. The emergency admin is calling while the protocol is already paused.
     *
     * @param newState The state to set, as a member of the ProtocolState enum.
     */
    function setState(DataTypes.ProtocolState newState) external;
}