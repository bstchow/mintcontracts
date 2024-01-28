pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IExponentialMintNft } from "./IExponentialMintNft.sol";

/**
 * @title ExponentialMintNft
 * @notice Mint NFTs for a price determined by an exponential function.
 *         NFT's are designed to source entropy from Farcaster Frame inputs the Bonded Curve Frame
 */
contract ExponentialMintNft is ERC721Enumerable, Ownable {
    uint256 exponent;
    uint256 denominator;

    uint256 public constant ETH_DECIMALS = 18;

    constructor (string memory name, string memory symbol, address owner, uint256 _exponent, uint256 _denominator) ERC721(name, symbol) {
        transferOwnership(owner);
        exponent = _exponent;
        denominator = _denominator;
        if(denominator > 10 ** ETH_DECIMALS) {
            revert IExponentialMintNft.DenominatorExceedsEthPrecision();
        }
    }
    
    function mint(bytes32 tokenHash) public payable {
        if(msg.value < price()) {
            revert IExponentialMintNft.InsufficientMintValue(msg.value);
        }
        _safeMint(msg.sender, uint256(tokenHash));

       bool success = payable(owner()).send(msg.value);
       if(!success) {
        revert IExponentialMintNft.OwnerCouldNotReceiveFunds();
       }
    }

    /**
     * @return Price of the next token
     * @notice this will return 0 
     */
    function price() view public returns (uint256) {
        return ((totalSupply() + 1) ** exponent) * 10 ** ETH_DECIMALS / denominator;
    }

    function baseURI() view public returns (string memory) {
        return "https://farcaster.exchange/nft/";
    }

    function setUri(string memory uri) public onlyOwner {
        _setBaseURI(uri);
    }
}
