pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IExponentialMintNft } from "./IExponentialMintNft.sol";

/**
 * @title ExponentialMintNft
 * @notice Mint NFTs for a price determined by an exponential function.
 *         NFT's of any tokenHash can be minted
 */
contract ExponentialMintNft is IExponentialMintNft, ERC721Enumerable, Ownable {
    uint256 exponent;
    uint256 denominator;

    string _currentBaseURI;

    address public fundRecipient;
    uint256 public constant ETH_DECIMALS = 18;
    bool mintEnded = false;

    constructor (string memory name, string memory symbol, address owner, uint256 _exponent, uint256 _denominator) ERC721(name, symbol) Ownable(owner){
        exponent = _exponent;
        denominator = _denominator;
        fundRecipient = owner;
        if(denominator > 10 ** ETH_DECIMALS) {
            revert IExponentialMintNft.DenominatorExceedsEthPrecision();
        }
    }
    
    function mintTo(bytes32 tokenHash, address mintTo) public payable {
        if(mintEnded) {
            revert IExponentialMintNft.MintEnded();
        }

        if(msg.value < price()) {
            revert IExponentialMintNft.InsufficientMintValue(msg.value);
        }
        _safeMint(mintTo, uint256(tokenHash));

       bool success = payable(fundRecipient).send(msg.value);
       if(!success) {
        revert IExponentialMintNft.OwnerCouldNotReceiveFunds();
       }
    }

    function endMint() public onlyOwner {
        mintEnded = true;
    }

    /**
     * @return Price of the next token
     * @notice this will return 0 
     */
    function price() view public returns (uint256) {
        return ((totalSupply() + 1) ** exponent) * 10 ** ETH_DECIMALS / denominator;
    }

    function _baseURI() view internal override returns (string memory) {
        return _currentBaseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setFundRecipient(address _fundRecipient) public override onlyOwner {
        fundRecipient = _fundRecipient;
    }

    function setBaseURI(string memory uri) public override onlyOwner {
        _currentBaseURI = uri;
    }
}
