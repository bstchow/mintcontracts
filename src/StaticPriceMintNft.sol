pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IStaticPriceMintNft } from "./IStaticPriceMintNft.sol";

/**
 * @title StaticPriceMintNft
 * @notice Mint NFTs for a price determined by an StaticPrice function.
 *         NFT's of any tokenHash can be minted
 */
contract StaticPriceMintNft is IStaticPriceMintNft, ERC721Enumerable, ERC2981, Ownable {
    uint256 currentPrice;
    string _currentBaseURI;

    address public fundRecipient;
    uint256 public constant ETH_DECIMALS = 18;

    constructor (string memory name, string memory symbol, address owner, uint256 _price) ERC721(name, symbol) Ownable(owner){
        currentPrice = _price;
        fundRecipient = owner;
    }

    /**
     * @return Price of the next token
     */
    function price() view public returns (uint256) {
        return currentPrice;
    }

    function _baseURI() view internal override returns (string memory) {
        return _currentBaseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mintTo(bytes32 tokenHash, address mintTo) public payable {
        if(msg.value < price()) {
            revert IStaticPriceMintNft.InsufficientMintValue(msg.value);
        }
        _safeMint(mintTo, uint256(tokenHash));

       bool success = payable(fundRecipient).send(msg.value);
       if(!success) {
        revert IStaticPriceMintNft.OwnerCouldNotReceiveFunds();
       }
    }

    function setDefaultRoyalty(address receiver, uint96 royalty) public override onlyOwner {
        _setDefaultRoyalty(receiver, royalty);
    }

    function setFundRecipient(address _fundRecipient) public override onlyOwner {
        fundRecipient = _fundRecipient;
    }

    function setBaseURI(string memory uri) public override onlyOwner {
        _currentBaseURI = uri;
    }
}
