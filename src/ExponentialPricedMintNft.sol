pragma solidity ^0.8.23;

import { PricedMintNft } from "./PricedMintNft.sol";

/**
 * @title ExponentialPricedMintNft
 * @notice Mint NFTs for a price determined by an exponential function
 */
contract ExponentialPricedMintNft is PricedMintNft {
    error DenominatorExceedsEthPrecision();

    // Pricing
    uint256 public exponent;
    uint256 public denominator;

    // Payments
    uint256 public constant ETH_DECIMALS = 18;

    constructor (string memory name, string memory symbol, address owner, uint256 _exponent, uint256 _denominator) PricedMintNft(name, symbol, owner) {
        exponent = _exponent;
        denominator = _denominator;
        fundRecipient = owner;
        if(denominator > 10 ** ETH_DECIMALS) {
            revert DenominatorExceedsEthPrecision();
        }
    }

    /**
     * @return Price of the next token
     */
    function price() view public override returns (uint256) {
        return ((mintCount + 1) ** exponent) * 10 ** ETH_DECIMALS / denominator;
    }
}
