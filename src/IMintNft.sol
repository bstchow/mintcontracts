pragma solidity ^0.8.21;

/**
 * @title IMintNft
 */
interface IMintNft {
    function mintTo(bytes32 tokenHash, address mintTo) external;
    function setBaseURI(string memory uri) external;
}
