pragma solidity ^0.8.23;

import { StaticPricedMintNft } from "./StaticPricedMintNft.sol";

/**
 * @title LimitedMintNft + Static Priced Mint NFT
 * @notice Only allow minting a limited number of NFTs for a set price.
 */
contract LimitedStaticPricedMintNft is StaticPricedMintNft  {
    uint256 public immutable mintLimit;
    
    constructor(string memory name, string memory symbol, address owner, uint256 _price, uint256 _mintLimit) StaticPricedMintNft(name, symbol, owner, _price) {
        mintLimit = _mintLimit;
    }

    function mintEnded() view public override returns (bool) {
        return mintCount >= mintLimit;
    }
}