pragma solidity ^0.8.23;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { BaseNft } from "./BaseNft.sol";
import { IPricedMintNft } from "./IPricedMintNft.sol";



/**
 * @title PricedMintNft
 * @notice Mint NFTs for a price
 */
abstract contract PricedMintNft is IPricedMintNft, BaseNft, ReentrancyGuard {
    address public override fundRecipient;

    constructor (string memory name, string memory symbol, address owner) BaseNft(name, symbol, owner) {
        fundRecipient = owner;
    }

    /**
     * @return Price of the next mint
     */
    function price() virtual view public returns (uint256);

    function mintTo(address _mintToAddress, bytes32 tokenHash) public payable nonReentrant {
        if(msg.value < price()) {
            revert IPricedMintNft.InsufficientMintValue(msg.value);
        }
        _internalMintTo(_mintToAddress, tokenHash);

        bool success = payable(fundRecipient).send(msg.value);
       if(!success) {
        revert IPricedMintNft.CouldNotSendFunds();
       }
    }

    // Remove to lower test complexity
    // function mintTo(address _mintToAddress) public payable nonReentrant {
    //     mintTo(_mintToAddress, generateSeed());
    // }

    function setFundRecipient(address _fundRecipient) public override onlyOwner {
        fundRecipient = _fundRecipient;
        emit FundRecipientSet(_fundRecipient);
    }
}
