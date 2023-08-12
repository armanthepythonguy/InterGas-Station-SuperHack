// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MainStation is Ownable{

    address mailbox;
    uint256 domainId;
    address remoteStation;

    constructor(address _mailbox){
        mailbox = _mailbox;
    }

    modifier onlyMailbox(){
        require(msg.sender == mailbox, "Only mailbox can call this function !!!");
        _;
    }

    function initializeRemote(uint256 domain, address remote) external onlyOwner{
        domainId = domain;
        remoteStation = remote;
    }


    function handle(uint32 _origin, bytes32 _sender, bytes memory _body) external onlyMailbox(){
        require(_origin == domainId, "Only the registered chain can call this function !!!");
        require(bytes32ToAddress(_sender) == remoteStation, "Only remoteStation can call this function !!!");
        (bytes memory calldatas, address recipient) = abi.decode(_body, (bytes,address));
        recipient.call(calldatas);
    }

    // alignment preserving cast
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }

    receive() external payable{}

}