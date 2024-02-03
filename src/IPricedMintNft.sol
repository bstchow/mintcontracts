pragma solidity ^0.8.23;

interface IPricedMintNft  {
    error InsufficientMintValue(uint256);
    error CouldNotSendFunds();

    event FundRecipientSet(address fundRecipient);

    /**
     * @return Price of the next mint
     */
    function price() view external returns (uint256);
    function fundRecipient() external view returns (address);

    function mintTo(address _mintToAddress, bytes32 tokenHash) external payable;
    
    // function mintTo(address _mintToAddress) external payable; Comment out to lower test complexity
    function setFundRecipient(address _fundRecipient) external;
}
