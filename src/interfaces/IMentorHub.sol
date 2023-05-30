// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {DataTypes} from "../libraries/DataTypes.sol";

/**
 * @title IMentorHub
 * @author MentorDAO
 *
 * @notice This is the interface for the MentorHub contract, the main entry point for the MentorDAO Protocol.
 * You'll find all the events and external functions, as well as the reasoning behind them here.
 */
interface IMentorHub {
    // /**
    //  * @notice Initializes the MentorHub contract, setting the initial governance and emergency admin addresses as well as the name and symbol in
    //  * the MentorNFT contract.
    //  *
    //  * @param name The name to set for the hub NFT.
    //  * @param symbol The symbol to set for the hub NFT.
    //  * @param governance The governance address to set.
    //  * @param emergencyAdmin The emergency admin address to set.
    //  * @param dispatcher The address of wallet that verifies crosschain donations in BE and reflect it in protocol.
    //  */
    // function initialize(
    //     string calldata name,
    //     string calldata symbol,
    //     address governance,
    //     address emergencyAdmin,
    //     address dispatcher
    // ) external;

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
     * @notice Sets the dispatcher, which is a permissioned role able to verify crosschain donations and reflect it on protocol.
     */
    function setDispatcher(address newDispatcher) external;

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

    /**
     * @notice Whitelists the mentor address to allow profile minting. This function
     * can only be called by the governance address.
     *
     * @param mentor The mentor's address to whitelist.
     * @param whitelist The boolean to set whitelist state.
     */
    function whitelistMentor(address mentor, bool whitelist) external;

    /**
     * @notice Creates a mentor profile with the specified parameters, minting a mentor NFT to the given recipient. This
     * function must be called by/for a whitelisted mentor. An address can hold only a single mentor NFT.
     *
     * @param mentorData The parameters of {Mentor} type.
     * @return mentorId.
     */
    function createMentorProfile(DataTypes.Mentor calldata mentorData) external returns (uint256);

    function updateMentorProfile(DataTypes.Mentor calldata mentorData) external;

    function emitSessionBooked(DataTypes.BookSessionData calldata vars) external;

    function getGovernance() external view returns (address);

    function getEmergencyAdmin() external view returns (address);

    function isMentorWhitelisted(address mentor) external view returns (bool);

    function getMentor(uint256 mentorId) external view returns (DataTypes.Mentor memory);

    function getMentorIdByHandle(string calldata handle) external view returns (uint256);

    function getMentorIdByAddress(address addr) external view returns (uint256);
}
