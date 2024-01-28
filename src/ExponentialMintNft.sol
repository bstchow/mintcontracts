pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @title ExponentialMintNft
 * @notice Mint NFTs for a price determined by an exponential function.
 *         NFT's are designed to source entropy from Farcaster Frame inputs the Bonded Curve Frame
 */
contract ExponentialMintNft is ERC721Enumerable, Ownable {
    uint256 exponent;
    uint256 denominator;

    error InsufficientMintValue(uint256 value);
    error OwnerCouldNotReceiveFunds();

    constructor (string memory name, string memory symbol, address owner, uint256 _exponent, uint256 _denominator) ERC721(name, symbol) {
        transferOwnership(owner);
        exponent = _exponent;
        denominator = _denominator;
    }
    
    function mint(bytes32 tokenHash) public payable {
        if(msg.value < price()) {
            revert InsufficientMintValue(msg.value);
        }
        _safeMint(msg.sender, uint256(tokenHash));

       bool success = payable(owner()).send(msg.value);
       if(!success) {
        revert OwnerCouldNotReceiveFunds();
       }
    }

    /**
     * @return Price of the next token
     */
    function price() view public returns (uint256) {
        return ((totalSupply() + 1) ** exponent) / denominator;
    }
}
