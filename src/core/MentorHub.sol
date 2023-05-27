// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

import {MentorNFT} from "./base/MentorNFT.sol";
import {MentorGov} from "./base/MentorGov.sol";
import {MentorMultiState} from "./base/MentorMultiState.sol";
import {MentorHubStorage} from "./storage/MentorHubStorage.sol";

import {IMentorHub} from "../interfaces/IMentorHub.sol";

import {SignUpMentorLogic} from "../libraries/SignUpMentorLogic.sol";
import {DataTypes} from "../libraries/DataTypes.sol";
import {Events} from "../libraries/Events.sol";
import {Errors} from "../libraries/Errors.sol";

/**
 * @title MentorHub
 * @author MentorDAO
 *
 * @notice This is the main entrypoint of the MentorDAO Protocol. It contains governance functionality as well as
 * mentors & donation functionality.
 */
contract MentorHub is Initializable, MentorNFT, MentorGov, MentorMultiState, MentorHubStorage, IMentorHub {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @inheritdoc IMentorHub
    function initialize(string calldata name, string calldata symbol, address governance, address emergencyAdmin)
        external
        override
        initializer
    {
        MentorNFT._initialize(name, symbol);
        MentorGov._initialize(governance, emergencyAdmin);
        MentorMultiState._initialize(DataTypes.ProtocolState.Paused);
    }

    /// ***********************
    /// *****GOV FUNCTIONS*****
    /// ***********************

    /// @inheritdoc IMentorHub
    function setGovernance(address newGovernance) external override onlyGovernance {
        _setGovernance(newGovernance);
    }

    /// @inheritdoc IMentorHub
    function setEmergencyAdmin(address newEmergencyAdmin) external override onlyGovernance {
        _setEmergencyAdmin(newEmergencyAdmin);
    }

    /// @inheritdoc IMentorHub
    function setState(DataTypes.ProtocolState newState) external override onlyGovernanceOrEmergencyAdmin {
        if (msg.sender == _emergencyAdmin) {
            if (newState == DataTypes.ProtocolState.Unpaused) {
                revert Errors.EmergencyAdminCannotUnpause();
            }
            _validateNotPaused();
        }
        _setState(newState);
    }

    /// @inheritdoc IMentorHub
    function whitelistMentor(address mentor, bool whitelist) external override onlyGovernance {
        _mentorWhitelisted[mentor] = whitelist;
        emit Events.MentorWhitelisted(mentor, whitelist);
    }

    /// **************************
    /// *****MENTOR FUNCTIONS*****
    /// **************************

    modifier onlyWhitelistedMentor() {
        if (!_mentorWhitelisted[msg.sender]) revert Errors.MentorNotWhitelisted();
        _;
    }

    /// @inheritdoc IMentorHub
    function signUpMentor(DataTypes.SignUpMentorData calldata data)
        external
        override
        whenNotPaused
        onlyWhitelistedMentor
        returns (uint256)
    {
        unchecked {
            uint256 mentorId = ++_mentorsCounter;

            _mint(msg.sender, mentorId);

            SignUpMentorLogic.signUpMentor(mentorId, data, _mentorIdByHandleHash, _mentorIdByAddress, _mentorById);

            return mentorId;
        }
    }

    /// *********************************
    /// *****EXTERNAL VIEW FUNCTIONS*****
    /// *********************************

    /// @inheritdoc IMentorHub
    function isMentorWhitelisted(address mentor) external view override returns (bool) {
        return _mentorWhitelisted[mentor];
    }

    /// @inheritdoc IMentorHub
    function getGovernance() external view override returns (address) {
        return _governance;
    }

    /// @inheritdoc IMentorHub
    function getEmergencyAdmin() external view override returns (address) {
        return _emergencyAdmin;
    }

    /// @inheritdoc IMentorHub
    function getMentor(uint256 mentorId) external view override returns (DataTypes.Mentor memory) {
        return _mentorById[mentorId];
    }
}
