// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {DataTypes} from "./DataTypes.sol";
import {Constants} from "./Constants.sol";
import {Events} from "./Events.sol";
import {Errors} from "./Errors.sol";

/**
 * @title SignUpMentorLogic
 * @author MentorDAO
 *
 * @notice This is the library that contains the logic for mentor sign up.
 *
 * @dev The functions are external, so they are called from the hub via `delegateCall` under the hood. Furthermore,
 * expected events are emitted from this library instead of from the hub to alleviate code size concerns.
 */
library SignUpMentorLogic {
    function signUpMentor(
        uint256 mentorId,
        DataTypes.SignUpMentorData calldata vars,
        mapping(bytes32 => uint256) storage _mentorIdByHandleHash,
        mapping(address => uint256) storage _mentorIdByAddress,
        mapping(uint256 => DataTypes.Mentor) storage _mentorById
    ) external {
        bytes32 handleHash = keccak256(bytes(vars.handle));

        _mentorIdByAddress[msg.sender] = mentorId;
        _mentorIdByHandleHash[handleHash] = mentorId;

        _mentorById[mentorId].addr = msg.sender;
        _mentorById[mentorId].handle = vars.handle;
        _mentorById[mentorId].fullname = vars.fullname;
        _mentorById[mentorId].position = vars.position;
        _mentorById[mentorId].aboutMe = vars.aboutMe;
        _mentorById[mentorId].imageURI = vars.imageURI;
        _mentorById[mentorId].usdPerSession = vars.usdPerSession;
        _mentorById[mentorId].sessionDuration = vars.sessionDuration;
    }

    function _emitSignUpMentor(
        uint256 profileId,
        DataTypes.SignUpMentorData calldata vars,
        bytes memory followModuleReturnData
    ) internal {
        emit Events.ProfileCreated(
            profileId,
            msg.sender, // Creator is always the msg sender
            vars.to,
            vars.handle,
            vars.imageURI,
            vars.followModule,
            followModuleReturnData,
            vars.followNFTURI,
            block.timestamp
        );
    }

    function _validateHandle(string calldata handle) private pure {
        bytes memory byteHandle = bytes(handle);
        if (byteHandle.length == 0 || byteHandle.length > Constants.MAX_HANDLE_LENGTH) {
            revert Errors.HandleLengthInvalid();
        }

        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i = 0; i < byteHandleLength;) {
            if (
                (byteHandle[i] < "0" || byteHandle[i] > "z" || (byteHandle[i] > "9" && byteHandle[i] < "a"))
                    && byteHandle[i] != "." && byteHandle[i] != "-" && byteHandle[i] != "_"
            ) revert Errors.HandleContainsInvalidCharacters();
            unchecked {
                ++i;
            }
        }
    }
}
