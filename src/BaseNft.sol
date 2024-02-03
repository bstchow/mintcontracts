pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IBaseNft } from "./IBaseNft.sol"; 
/**
 * @title BaseNft
 * @notice Base NFT contract
 *         NFT's of any tokenHash can be minted
 */
abstract contract BaseNft is IBaseNft, ERC721Enumerable, Ownable {    
    // Script
    string public projectScript;

    // Metadata
    string public currentBaseURI;

    // totalSupply is not equivalent because it decreases after burn
    uint256 public mintCount = 0;
    
    constructor (string memory name, string memory symbol, address owner) ERC721(name, symbol) Ownable(owner){
    }

    // View functions
    function mintEnded() virtual view public returns (bool) {
        return false;
    }

    function _baseURI() view internal override returns (string memory) {
        return currentBaseURI;
    }

    // Write functions
    function _internalMintTo(address _mintToAddress, bytes32 tokenHash) internal {
        if(mintEnded()) {
            revert CannotMintAfterMintEnded();
        }

        _safeMint(_mintToAddress, uint256(tokenHash));
        mintCount++;
    }

    /**
     * @return pseudorandom bytes32 seed based on the blockhash, sender's address and number of mints
     */
    function generateSeed() public view returns (bytes32) {
        return keccak256(abi.encodePacked(blockhash(block.number), msg.sender, mintCount));
    }

    function setBaseURI(string memory uri) public override onlyOwner {
        currentBaseURI = uri;
    }

    function setProjectScript(string memory script) public onlyOwner {
        projectScript = script;
        emit ProjectScriptUpdated();
    }
}
