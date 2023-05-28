// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
// import "openzeppelin-contracts-upgradeable/contracts/governance/GovernorUpgradeable.sol";

import {Events} from "../../libraries/Events.sol";
import {DataTypes} from "../../libraries/DataTypes.sol";
import {Errors} from "../../libraries/Errors.sol";

/**
 * @title MentorGov
 * @author MentorDAO
 *
 * @notice This is an abstract contract that implements internal governence setting and validation.
 *
 * TODO: Multisig -> OZ Governor
 */
abstract contract MentorGov is Initializable {
    address internal _governance;
    address internal _emergencyAdmin;

    function _initialize(address governance, address emergencyAdmin) internal onlyInitializing {
        _setGovernance(governance);
        _setEmergencyAdmin(emergencyAdmin);
    }

    modifier onlyGovernance() {
        _validateCallerIsGovernance();
        _;
    }

    modifier onlyGovernanceOrEmergencyAdmin() {
        _validateCallerIsGovernanceOrEmergencyAdmin();
        _;
    }

    function _setGovernance(address newGovernance) internal {
        address prevGovernance = _governance;
        _governance = newGovernance;
        emit Events.GovernanceSet(msg.sender, prevGovernance, newGovernance);
    }

    function _setEmergencyAdmin(address newEmergencyAdmin) internal {
        address prevEmergencyAdmin = _emergencyAdmin;
        _emergencyAdmin = newEmergencyAdmin;
        emit Events.EmergencyAdminSet(msg.sender, prevEmergencyAdmin, newEmergencyAdmin);
    }

    function _validateCallerIsGovernance() internal view {
        if (msg.sender != _governance) revert Errors.NotGovernance();
    }

    function _validateCallerIsGovernanceOrEmergencyAdmin() internal view {
        if (msg.sender != _governance && msg.sender != _emergencyAdmin) revert Errors.NotGovernanceOrEmergencyAdmin();
    }
}