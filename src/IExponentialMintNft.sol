pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
/**
 * @title ExponentialMintNft
 * @notice Mint NFTs for a price determined by an exponential function.
 *         NFT's are designed to source entropy from Farcaster Frame inputs the Bonded Curve Frame
 */
interface IExponentialMintNft is IERC721Enumerable {
    error InsufficientMintValue(uint256 value);
    error OwnerCouldNotReceiveFunds();
    error DenominatorExceedsEthPrecision();

    function mint(bytes32 tokenHash) external;
    
    /**
     * @return Price of the next token
     * @notice this will return 0 
     */
    function price() view external returns (uint256);
}
