// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

import {MentorNFT} from "./MentorNFT.sol";
import {MentorGov} from "./MentorGov.sol";
import {MentorMultiState} from "./MentorMultiState.sol";
import {MentorHubStorage} from "./storage/MentorHubStorage.sol";

import {IMentorHub} from "../interfaces/IMentorHub.sol";

import {DataTypes} from "../libraries/DataTypes.sol";
import {Events} from "../libraries/Events.sol";
import {Errors} from "../libraries/Errors.sol";
import {MentorProfile} from "../libraries/MentorProfile.sol";

/**
 * @title MentorHub
 * @author MentorDAO
 *
 * @notice This is the main entrypoint of the MentorDAO Protocol. It contains governance functionality as well as
 * mentors & donation functionality.
 */
contract MentorHub is MentorNFT, MentorGov, MentorMultiState, MentorHubStorage, IMentorHub {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        string memory name,
        string memory symbol,
        address governance,
        address emergencyAdmin,
        address dispatcher
    )
        MentorNFT(name, symbol)
        MentorGov(governance, emergencyAdmin, dispatcher)
        MentorMultiState(DataTypes.ProtocolState.Unpaused)
    {
        // _disableInitializers();
    }

    // /// @inheritdoc IMentorHub
    // function initialize(
    //     string calldata name,
    //     string calldata symbol,
    //     address governance,
    //     address emergencyAdmin,
    //     address dispatcher
    // ) external override initializer {
    //     MentorNFT._initialize(name, symbol);
    //     MentorGov._initialize(governance, emergencyAdmin, dispatcher);
    //     MentorMultiState._initialize(DataTypes.ProtocolState.Paused);
    // }

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
    function setDispatcher(address newDispatcher) external override onlyGovernance {
        _setDispatcher(newDispatcher);
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
        if (!_mentorWhitelisted[msg.sender]) revert Errors.NotWhitelistedMentor();
        _;
    }

    modifier onlyMentor() {
        if (_mentorIdByAddress[msg.sender] == 0) revert Errors.NotMentor();
        _;
    }

    /// @inheritdoc IMentorHub
    function createMentorProfile(DataTypes.Mentor calldata mentorData)
        external
        override
        whenNotPaused
        onlyWhitelistedMentor
        returns (uint256)
    {
        unchecked {
            uint256 mentorId = ++_mentorsCounter;
            _mint(msg.sender, mentorId);
            MentorProfile.create(mentorId, mentorData, _mentorIdByHandleHash, _mentorIdByAddress, _mentorById);
            return mentorId;
        }
    }

    /// @inheritdoc IMentorHub
    function updateMentorProfile(DataTypes.Mentor calldata mentorData) external override whenNotPaused onlyMentor {
        uint256 mentorId = _mentorIdByAddress[msg.sender];
        MentorProfile.update(mentorId, mentorData, _mentorIdByHandleHash, _mentorById);
    }

    /// ******************************
    /// *****DISPATCHER FUNCTIONS*****
    /// ******************************

    /// @inheritdoc IMentorHub
    function emitSessionBooked(DataTypes.BookSessionData calldata vars) external onlyDispatcher {
        DataTypes.Mentor memory mentor = _mentorById[vars.mentorId];
        emit Events.SessionBooked(
            vars.mentorId, vars.mentee, vars.donationTxHash, mentor.usdPerSession, mentor.nonprofit, block.timestamp
        );
    }

    /// *********************************
    /// *****EXTERNAL VIEW FUNCTIONS*****
    /// *********************************

    /// @inheritdoc IMentorHub
    function getGovernance() external view override returns (address) {
        return _governance;
    }

    /// @inheritdoc IMentorHub
    function getEmergencyAdmin() external view override returns (address) {
        return _emergencyAdmin;
    }

    /// @inheritdoc IMentorHub
    function isMentorWhitelisted(address mentor) external view override returns (bool) {
        return _mentorWhitelisted[mentor];
    }

    /// @inheritdoc IMentorHub
    function getMentor(uint256 mentorId) external view override returns (DataTypes.Mentor memory) {
        return _mentorById[mentorId];
    }

    /// @inheritdoc IMentorHub
    function getMentorIdByHandle(string calldata handle) external view override returns (uint256) {
        bytes32 handleHash = keccak256(bytes(handle));
        return _mentorIdByHandleHash[handleHash];
    }

    /// @inheritdoc IMentorHub
    function getMentorIdByAddress(address addr) external view override returns (uint256) {
        return _mentorIdByAddress[addr];
    }

    /**
     * @dev Overrides the ERC721 tokenURI function to return the associated URI with a given mentor profile.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return MentorProfile.getTokenURI(tokenId, ownerOf(tokenId), _mentorById[tokenId]);
    }
}
