// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@hyperlane-xyz/core/contracts/interfaces/IInterchainGasPaymaster.sol";
import "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";

contract RemoteStation is Ownable{

    address mailbox;
    address interchainGasPaymaster;
    address mainStation;

    constructor(address _mailbox, address _interchainGasPaymaster, address _mainStation){
        mailbox = _mailbox;
        interchainGasPaymaster = _interchainGasPaymaster;
        mainStation = _mainStation;
    }

    function sendTransaction(uint8 v, bytes32 r, bytes32 s, bytes memory data, uint8 destDomain, address recipient, uint256 originGas) payable external {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        bytes32 eip712DomainHash = keccak256(
        abi.encode(
            keccak256(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            ),
            keccak256(bytes("RemoteStation")),
            keccak256(bytes("1")),
            chainId,
            address(this)
        )
        );
        bytes32 hashStruct = keccak256(
            abi.encode(
                keccak256("transact(bytes calldata)"),
                keccak256(data)
            )
        );
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
        address signer = ecrecover(hash, v, r, s);
        require(signer == msg.sender, "Only the signer can send transactions");
        int256 derivedPrice = getDerivedPrice(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada, 0x0715A7794a1dc8e42615F059dD6e406A6594651A, 18);
        require(msg.value >= (uint256(derivedPrice)*originGas)/10^18, "Less gas fees was paid !!!");
        bytes32 messageId = IMailbox(mailbox).dispatch(destDomain, addressToBytes32(mainStation), abi.encode(data, recipient));
        uint256 quote = IInterchainGasPaymaster(interchainGasPaymaster).quoteGasPayment(destDomain, 10000);
        IInterchainGasPaymaster(interchainGasPaymaster).payForGas{value: quote}(
            messageId,
            destDomain,
            10000,
            address(this)
        );
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function getDerivedPrice(
        address _base,
        address _quote,
        uint8 _decimals
    ) public view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 basePrice, , , ) = AggregatorV3Interface(_base)
            .latestRoundData();
        uint8 baseDecimals = AggregatorV3Interface(_base).decimals();
        basePrice = scalePrice(basePrice, baseDecimals, _decimals);

        (, int256 quotePrice, , , ) = AggregatorV3Interface(_quote)
            .latestRoundData();
        uint8 quoteDecimals = AggregatorV3Interface(_quote).decimals();
        quotePrice = scalePrice(quotePrice, quoteDecimals, _decimals);

        return (basePrice * decimals) / quotePrice;
    }

    function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }

    function getPayout() external onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }

}