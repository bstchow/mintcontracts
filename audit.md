# LimitedStaticPricedMintNft.sol Audit

### Access Control

- _PricedMintNft#mintTo_(address,bytes32)
    - 

## Findings
- _LimitedStaticPricedMintNft#mintEnded_
    - Natspec doesn't match impl. The natspec says "Price of the next token" but the impl returns
      a boolean that tells you if minting is over
    - Added test to verify the mint limit is enforced.