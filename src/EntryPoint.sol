// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./MainStation.sol";
import "./RemoteStation.sol";
import "@hyperlane-xyz/core/contracts/interfaces/IInterchainGasPaymaster.sol";
import "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";

contract EntryPoint{


    uint256 tokenCounter;
    mapping(uint256 => mapping(address => address)) deployments;

    address mailbox;
    address interchainGasPaymaster;
    address remoteEntryPoint;

    constructor(address _mailbox, address _interchainGasPaymaster, address _remoteEntryPoint){
        mailbox = _mailbox;
        interchainGasPaymaster = _interchainGasPaymaster;
        remoteEntryPoint = _remoteEntryPoint;
    }


    function createDeployment(uint32 domainId) payable external{
        MainStation mainContract = new MainStation(0xCC737a94FecaeC165AbCf12dED095BB13F037685);
        bytes32 messageId = IMailbox(mailbox).dispatch(domainId, addressToBytes32(remoteEntryPoint), abi.encode(tokenCounter));
        uint256 quote = IInterchainGasPaymaster(interchainGasPaymaster).quoteGasPayment(domainId, 10000);
        IInterchainGasPaymaster(interchainGasPaymaster).payForGas{value: quote}(
            messageId,
            domainId,
            200000,
            address(this)
        );
        tokenCounter++;
    }

    function handle(uint32 _origin, bytes32 _sender, bytes memory _body) external{
        
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

}