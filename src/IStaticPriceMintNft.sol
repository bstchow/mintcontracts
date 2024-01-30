pragma solidity ^0.8.21;

/**
 * @title IStaticPriceMintNft
 * @notice Mint NFTs for a static price
 */
interface IStaticPriceMintNft {
    error InsufficientMintValue(uint256 value);
    error OwnerCouldNotReceiveFunds();

    function mintTo(bytes32 tokenHash, address mintTo) payable external;
    function setDefaultRoyalty(address receiver, uint96 royalty) external;
    function setFundRecipient(address _fundRecipient) external;
    function setBaseURI(string memory uri) external;

    /**
     * @return Price of the next token
     */
    function price() view external returns (uint256);

    function fundRecipient() view external returns (address);
}
