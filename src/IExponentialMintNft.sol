pragma solidity ^0.8.21;

/**
 * @title IExponentialMintNft
 */
interface IExponentialMintNft {
    error InsufficientMintValue(uint256 value);
    error OwnerCouldNotReceiveFunds();
    error DenominatorExceedsEthPrecision();
    error CannotMintAfterMintEnded();
    error CannotSetScriptAfterMintEnded();

    function mintTo(bytes32 tokenHash, address mintTo) payable external;
    function setFundRecipient(address _fundRecipient) external;
    function setBaseURI(string memory uri) external;
    function setProjectScript(string memory script) external;
    function endMint() external;

    /**
     * @return Price of the next token
     */
    function price() view external returns (uint256);

    function fundRecipient() view external returns (address);

    event MintEnded();
    event FundRecipientSet(address fundRecipient);
    event BaseURISet(string uri);
    event ProjectScriptUpdated();
}
