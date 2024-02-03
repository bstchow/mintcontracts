pragma solidity ^0.8.23;

import { BaseNft } from "./BaseNft.sol";
import { IPrivilegedMintNft } from "./IPrivilegedMintNft.sol";

/**
 * @title PrivilegedMintNft
 * @notice "Minter" can mint NFTs for no price.
 *         NFT's of any tokenHash can be minted
 */
contract PrivilegedMintNft is IPrivilegedMintNft, BaseNft {
    address public override minter;

    constructor(string memory name, string memory symbol, address owner) BaseNft(name, symbol, owner) {}

    function mintTo(address _mintToAddress, bytes32 tokenHash) public onlyMinter {
        _internalMintTo(_mintToAddress, tokenHash);
    }

    function mintTo(address _mintToAddress) public onlyMinter {
        mintTo(_mintToAddress, generateSeed());
    }

    function setMinter(address _minter) public override onlyOwner {
        minter = _minter;
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "MintNft: caller is not the minter");
        _;
    }
}
