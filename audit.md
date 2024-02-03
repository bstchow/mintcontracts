# LimitedStaticPricedMintNft Audit
Audited by @daltboy11

Base assumptions
- `owner` and `fundRecipient` are non-malicious
- I did not look closely at the openzeppelin contracts as they are already heavily used and tested in the wild

## Findings and Recommendations

No major issues. Several minor recommendations (❓) and one medium question (❓❓)

### StaticPricedMintNft
- Make currentPrice immutable

### LimitedStaticPricedMintNft
- Make mintLimit immutable
- ❓ _mintEnded_
    - Natspec doesn't match impl. The natspec says "Price of the next token" but the impl returns
      a boolean that tells you if minting is over
    - Added test to verify the mint limit is enforced.

### BaseNft
- ❓ I don't see burn functionality. I assumed that was intended but there's a comment that suggests otherwise
  ```
  // totalSupply is not equivalent because it decreases after burn
  uint256 public mintCount = 0;
  ```
- `generateSeed()` is predictable but afaik it's only used to influence the artwork. It doesn't affect the price,
  who can mint, and the artwork doesn't have rarity levels,so it looks like an acceptable use of pseudorandomness.
- Minor, but there's no event emitted for setting `currentBaseUri`

### PricedMintNft
- ❓❓ This could be intentional.. but the _whole_ message value is sent to the fundRecipient even if it exceeds the mint price.
- If the `fundingRecipient` is set to the `owner` by default then consider simplifying the contract by removing the
  separate `fundingRecipient` address and always sending the funds to the owner.
- The application defined error `CouldNotSendFunds` isn't necessary if you use `transfer` instead of send.
  And `transfer`, like `send`, does propagates a fixed amount of 2300 gas.
  ```
  // Reverts if there is an error caused by the receiver
  payable(fundRecipient).transfer(msg.value);
  ```
- ❓ `fundRecipient` can be set to the 0 address. This is minor but if this happens on accident then some mint funds could be lost.

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


#### Proxies
Not applicable to this project

#### Safe operations
- `send` in PricedMintNft#_mintTo looks fine. The usage of `send` appears fine.

#### Checks-effects-interactions
- `PricedMintNft`
  - `mintTo(address,bytes32)`
    - it follows the pattern _and_ has a reentrancy guard. Doubly safe!

There are no other external functions to check for.