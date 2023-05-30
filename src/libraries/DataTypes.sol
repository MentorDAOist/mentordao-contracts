// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @title DataTypes
 * @author MentorDAO
 *
 * @notice A standard library of data types used throughout the MentorDAO Protocol.
 */
library DataTypes {
    /**
     * @notice An enum containing the different states the protocol can be in, limiting certain actions.
     *
     * @param Unpaused The fully unpaused state.
     * @param Paused The fully paused state.
     */
    enum ProtocolState {
        Unpaused,
        Paused
    }

    /**
     * @notice A struct containing the necessary information to reconstruct an EIP-712 typed data signature.
     *
     * @param v The signature's recovery parameter.
     * @param r The signature's r parameter.
     * @param s The signature's s parameter
     * @param deadline The signature's deadline
     */
    struct EIP712Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    /**
     * @notice A struct containing mentor data.
     *
     * @param handle The human-readable and unique username.
     * @param fullname The full name displayed on the website.
     * @param position The working position or the expertise. Displayed as a subtitle.
     * @param aboutMe The bio.
     * @param imageURI The image URI. IPFS by default.
     * @param calendly The calendly id to book a session in sync with web2 calendars.
     * @param usdPerSession The USD amount to be donated during a session booking.
     * @param sessionDuration The session duration in minutes.
     * @param nonprofit The nonprofit ID on Endaoment / Giveth / Gitcoin to donate funds to.
     */
    struct Mentor {
        string handle;
        string fullname;
        string position;
        string aboutMe;
        string imageURI;
        string calendly;
        uint256 usdPerSession;
        uint256 sessionDuration;
        string nonprofit;
    }

    struct BookSessionData {
        uint256 mentorId;
        address mentee;
        bytes32 donationTxHash;
    }
}
