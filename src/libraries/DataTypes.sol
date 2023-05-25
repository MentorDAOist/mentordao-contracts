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
     * @param imageURI The URI to be used for the profile's image.
     */
    struct MentorStruct {
        address addr;
        string name;
        string imageURI;
    }
}
