pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
/**
 * @title ExponentialMintNft
 * @notice NFT's are designed to source entropy from Farcaster Frame 
 */
interface IMintNft {
    function mintTo(bytes32 tokenHash, address mintTo) external;
    function setBaseURI(string memory uri) external;
}
