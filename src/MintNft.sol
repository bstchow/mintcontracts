pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IMintNft } from "./IMintNft.sol";

/**
 * @title ExponentialMintNft
 * @notice Mint NFTs for a price determined by an exponential function.
 *         NFT's of any tokenHash can be minted
 */
contract MintNft is IMintNft, ERC721Enumerable, Ownable {
    string _currentURI;

    uint256 public constant ETH_DECIMALS = 18;

    constructor (string memory name, string memory symbol, address owner) ERC721(name, symbol) Ownable(owner){
    }
    
    function mintTo(bytes32 tokenHash, address mintTo) public {
        _safeMint(mintTo, uint256(tokenHash));
    }

    function _baseURI() view internal override returns (string memory) {
        return _currentURI;
    }

    function setBaseURI(string memory uri) public override onlyOwner {
        _currentURI = uri;
    }
}
