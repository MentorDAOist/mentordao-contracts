// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library Errors {
    error SignatureExpired();
    error ZeroSpender();
    error SignatureInvalid();
    error NotOwnerOrApproved();
    error NotHub();
    error NotGovernance();
    error NotGovernanceOrEmergencyAdmin();
    error EmergencyAdminCannotUnpause();
    error MentorNotWhitelisted();
    error MentorNFTNotTransferable();
    error MentorAlreadyRegistered();
    error HandleTaken();
    error HandleLengthInvalid();
    error HandleContainsInvalidCharacters();
    error HandleFirstCharInvalid();

    // State Errors
    error Paused();
}
