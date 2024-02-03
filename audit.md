# LimitedStaticPricedMintNft.sol Audit

## Findings and Recommendations

### StaticPricedMintNft
- Make currentPrice immutable

### LimitedStaticPricedMintNft
- Make mintLimit immutable
- _mintEnded_
    - Natspec doesn't match impl. The natspec says "Price of the next token" but the impl returns
      a boolean that tells you if minting is over
    - Added test to verify the mint limit is enforced.

### BaseNft
- I don't see burn functionality. I assume that was intended but there's a comment that suggests otherwise
  ```
  // totalSupply is not equivalent because it decreases after burn
  uint256 public mintCount = 0;
  ```

### Checklist

#### Access Control
- `PricedMintNft`
  - `mintTo(address,bytes32)`
    - public function, expected
  - `setFundRecipient(address)`
    - onlyOwner - checks out.
- `BaseNft`
  - `setBaseURI`
    - onlyOwner - checks out
  - `setProjectScript`
    - onlyOwner - checks out