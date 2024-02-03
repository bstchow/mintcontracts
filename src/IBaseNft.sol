pragma solidity ^0.8.23;

interface IBaseNft {
    event ProjectScriptUpdated();
    error CannotMintAfterMintEnded();
    
    // View functions
    function mintEnded() view external returns (bool);
    function projectScript() view external returns (string memory);
    function currentBaseURI() view external returns (string memory);
    function mintCount() view external returns (uint256);

    function setBaseURI(string memory uri) external;
    function setProjectScript(string memory script) external;
}
