pragma solidity ^0.8.23;

/**
 * @title IPrivilegedMintNft
 */
interface IPrivilegedMintNft {
    function mintTo(address _mintToAddress, bytes32 tokenHash) external;
    function mintTo(address _mintToAddress) external;
    function setMinter(address _minter) external;

    function minter() external view returns (address);
}
