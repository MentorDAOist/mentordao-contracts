// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {DataTypes} from "./DataTypes.sol";
import {Constants} from "./Constants.sol";
import {Events} from "./Events.sol";
import {Errors} from "./Errors.sol";

import "openzeppelin-contracts/contracts/utils/Base64.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

/**
 * @title MentorProfile
 * @author MentorDAO
 *
 * @notice This is the library that contains the logic for mentor profile.
 *
 * @dev The functions are external, so they are called from the hub via `delegateCall` under the hood. Furthermore,
 * expected events are emitted from this library instead of from the hub to alleviate code size concerns.
 */
library MentorProfile {
    function create(
        uint256 mentorId,
        DataTypes.Mentor calldata mentorData,
        mapping(bytes32 => uint256) storage _mentorIdByHandleHash,
        mapping(address => uint256) storage _mentorIdByAddress,
        mapping(uint256 => DataTypes.Mentor) storage _mentorById
    ) external {
        _validateHandle(mentorData.handle);
        _validateImageURI(mentorData.imageURI);

        bytes32 handleHash = keccak256(bytes(mentorData.handle));

        if (_mentorIdByHandleHash[handleHash] != 0) revert Errors.HandleTaken();

        _mentorIdByHandleHash[handleHash] = mentorId;
        _mentorIdByAddress[msg.sender] = mentorId;

        _mentorById[mentorId].handle = mentorData.handle;
        _mentorById[mentorId].fullname = mentorData.fullname;
        _mentorById[mentorId].position = mentorData.position;
        _mentorById[mentorId].aboutMe = mentorData.aboutMe;
        _mentorById[mentorId].imageURI = mentorData.imageURI;
        _mentorById[mentorId].calendly = mentorData.calendly;
        _mentorById[mentorId].usdPerSession = mentorData.usdPerSession;
        _mentorById[mentorId].sessionDuration = mentorData.sessionDuration;
        _mentorById[mentorId].nonprofit = mentorData.nonprofit;

        _emitMentorProfileCreated(mentorId, mentorData);
    }

    function update(
        uint256 mentorId,
        DataTypes.Mentor calldata mentorData,
        mapping(bytes32 => uint256) storage _mentorIdByHandleHash,
        mapping(uint256 => DataTypes.Mentor) storage _mentorById
    ) external {
        _validateImageURI(mentorData.imageURI);

        bytes32 prevHandleHash = keccak256(bytes(_mentorById[mentorId].handle));
        bytes32 newHandleHash = keccak256(bytes(mentorData.handle));
        if (prevHandleHash != newHandleHash) {
            _validateHandle(mentorData.handle);
            if (_mentorIdByHandleHash[newHandleHash] != 0) revert Errors.HandleTaken();
            _mentorIdByHandleHash[newHandleHash] = mentorId;
            _mentorIdByHandleHash[prevHandleHash] = 0;
            _mentorById[mentorId].handle = mentorData.handle;
        }

        _mentorById[mentorId].fullname = mentorData.fullname;
        _mentorById[mentorId].position = mentorData.position;
        _mentorById[mentorId].aboutMe = mentorData.aboutMe;
        _mentorById[mentorId].imageURI = mentorData.imageURI;
        _mentorById[mentorId].calendly = mentorData.calendly;
        _mentorById[mentorId].usdPerSession = mentorData.usdPerSession;
        _mentorById[mentorId].sessionDuration = mentorData.sessionDuration;
        _mentorById[mentorId].nonprofit = mentorData.nonprofit;

        _emitMentorProfileUpdated(mentorId, mentorData);
    }

    /**
     * @notice Generates the token URI for the mentor NFT.
     *
     * @dev The decoded token URI JSON metadata contains the following fields: name, description, image and attributes.
     * The image field contains an ipfs URI. JSON metadata is generated fully on-chain.
     *
     * @param mentorId The token ID of the mentor.
     * @param owner The address which owns the profile.
     * @param mentorData The mentor's data.
     *
     * @return string The mentor profile's token URI as a base64-encoded JSON string.
     */
    function getTokenURI(uint256 mentorId, address owner, DataTypes.Mentor memory mentorData)
        external
        pure
        returns (string memory)
    {
        string memory handleWithAtSymbol = string(abi.encodePacked("@", mentorData.handle));
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        '{"name":"',
                        handleWithAtSymbol,
                        '","description":"',
                        handleWithAtSymbol,
                        ' - Mentor at MentorDAO ","image":"',
                        mentorData.imageURI,
                        '","attributes":[{"trait_type":"id","value":"#',
                        Strings.toString(mentorId),
                        '"},{"trait_type":"owner","value":"',
                        Strings.toHexString(uint160(owner)),
                        '"},{"trait_type":"handle","value":"',
                        handleWithAtSymbol,
                        '"},{"trait_type":"fullname","value":"',
                        mentorData.fullname,
                        '"},{"trait_type":"position","value":"',
                        mentorData.position,
                        '"},{"trait_type":"aboutMe","value":"',
                        mentorData.aboutMe,
                        '"},{"trait_type":"calendly","value":"',
                        mentorData.calendly,
                        '"},{"trait_type":"usdPerSession","value":"',
                        Strings.toString(mentorData.usdPerSession),
                        '"},{"trait_type":"sessionDuration","value":"',
                        Strings.toString(mentorData.sessionDuration),
                        '"},{"trait_type":"nonprofit","value":"',
                        mentorData.nonprofit,
                        '"}]}'
                    )
                )
            )
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

    function _validateImageURI(string calldata imageURI) private pure {
        if (bytes(imageURI).length > Constants.MAX_PROFILE_IMAGE_URI_LENGTH) {
            revert Errors.ImageURILengthInvalid();
        }
        bytes memory imageURIBytes = bytes(imageURI);
        uint256 imageURIBytesLength = imageURIBytes.length;
        for (uint256 i = 0; i < imageURIBytesLength;) {
            if (imageURIBytes[i] == '"') {
                // Avoids embedding a user provided imageURI containing double-quotes to prevent injection attacks
                revert Errors.ImageURIInvalid();
            }
            unchecked {
                ++i;
            }
        }
    }

    function _emitMentorProfileCreated(uint256 mentorId, DataTypes.Mentor calldata mentorData) internal {
        emit Events.MentorProfileCreated(
            msg.sender, // Owner is always the msg sender
            mentorId,
            mentorData.handle,
            mentorData.fullname,
            mentorData.position,
            mentorData.aboutMe,
            mentorData.imageURI,
            mentorData.calendly,
            mentorData.usdPerSession,
            mentorData.sessionDuration,
            mentorData.nonprofit
        );
    }

    function _emitMentorProfileUpdated(uint256 mentorId, DataTypes.Mentor calldata mentorData) internal {
        emit Events.MentorProfileUpdated(
            msg.sender, // Owner is always the msg sender
            mentorId,
            mentorData.handle,
            mentorData.fullname,
            mentorData.position,
            mentorData.aboutMe,
            mentorData.imageURI,
            mentorData.calendly,
            mentorData.usdPerSession,
            mentorData.sessionDuration,
            mentorData.nonprofit
        );
    }
}
