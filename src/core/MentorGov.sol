// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
// import "openzeppelin-contracts-upgradeable/contracts/governance/GovernorUpgradeable.sol";

import {Events} from "../libraries/Events.sol";
import {DataTypes} from "../libraries/DataTypes.sol";
import {Errors} from "../libraries/Errors.sol";

/**
 * @title MentorGov
 * @author MentorDAO
 *
 * @notice This is an abstract contract that implements internal governence setting and validation.
 *
 * TODO: Multisig -> OZ Governor
 */
abstract contract MentorGov {
    address internal _governance;
    address internal _emergencyAdmin;
    address internal _dispatcher;

    constructor(address governance, address emergencyAdmin, address dispatcher) {
        _setGovernance(governance);
        _setEmergencyAdmin(emergencyAdmin);
        _setDispatcher(dispatcher);
    }

    // function _initialize(address governance, address emergencyAdmin, address dispatcher) internal onlyInitializing {
    //     _setGovernance(governance);
    //     _setEmergencyAdmin(emergencyAdmin);
    //     _setDispatcher(dispatcher);
    // }

    modifier onlyGovernance() {
        _validateCallerIsGovernance();
        _;
    }

    modifier onlyGovernanceOrEmergencyAdmin() {
        _validateCallerIsGovernanceOrEmergencyAdmin();
        _;
    }

    modifier onlyDispatcher() {
        _validateCallerIsDispatcher();
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

    function _setDispatcher(address newDispatcher) internal {
        address prevDispatcher = _dispatcher;
        _dispatcher = newDispatcher;
        emit Events.DispatcherSet(msg.sender, prevDispatcher, newDispatcher);
    }

    function _validateCallerIsGovernance() internal view {
        if (msg.sender != _governance) revert Errors.NotGovernance();
    }

    function _validateCallerIsGovernanceOrEmergencyAdmin() internal view {
        if (msg.sender != _governance && msg.sender != _emergencyAdmin) revert Errors.NotGovernanceOrEmergencyAdmin();
    }

    function _validateCallerIsDispatcher() internal view {
        if (msg.sender != _dispatcher) revert Errors.NotDispatcher();
    }
}
