pragma solidity ^0.8.23;

import { IBaseNft } from "./IBaseNft.sol";

/**
 * @title IAnyoneMintNft
 */
interface IAnyoneMintNft is IBaseNft {
    function mintTo(address _mintToAddress, bytes32 tokenHash) external;
    function mintTo(address _mintToAddress) external;
}
