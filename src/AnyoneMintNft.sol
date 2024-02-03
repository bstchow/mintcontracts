pragma solidity ^0.8.23;

import { BaseNft } from "./BaseNft.sol";
import { IAnyoneMintNft } from "./IAnyoneMintNft.sol";

/**
 * @title AnyoneMintNft
 * @notice Mint NFTs for no price
 */
contract AnyoneMintNft is IAnyoneMintNft, BaseNft {
    constructor (string memory name, string memory symbol, address owner) BaseNft(name, symbol, owner) {}
    
    function mintTo(address _mintToAddress, bytes32 tokenHash) public {
        _internalMintTo(_mintToAddress, tokenHash);
    }

    function mintTo(address _mintToAddress) public {
        mintTo(_mintToAddress, generateSeed());
    }
}
