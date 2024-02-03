pragma solidity ^0.8.23;

import { PricedMintNft } from "./PricedMintNft.sol";

/**
 * @title StaticPricedMintNft
 * @notice Mint NFTs for a static price
 */
contract StaticPricedMintNft is PricedMintNft {
    uint256 immutable currentPrice;

    constructor (string memory name, string memory symbol, address owner, uint256 _price) PricedMintNft(name, symbol, owner){
        currentPrice = _price;
    }

    /**
     * @return Price of the next token
     */
    function price() view public override returns (uint256) {
        return currentPrice;
    }
}
