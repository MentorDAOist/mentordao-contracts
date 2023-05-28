// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";

import {Errors} from "../../libraries/Errors.sol";

/**
 * @title MentorNFT
 * @author MentorDAO
 *
 * @notice This is an abstract contract that implements ERC721 mentor NFT.
 * It is overrided to be non-transferable and minted only once per address.
 */
abstract contract MentorNFT is Initializable, ERC721Upgradeable {
    function _initialize(string calldata name, string calldata symbol) internal onlyInitializing {
        __ERC721_init(name, symbol);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721Upgradeable)
    {
        if (from != address(0)) revert Errors.MentorNFTNotTransferable();
        if (balanceOf(to) >= 1) revert Errors.MentorAlreadyRegistered();
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _validateCallerIsMentor(uint256 mentorId) internal view {
        if (msg.sender != ownerOf(mentorId)) revert Errors.NotMentor();
    }
}
