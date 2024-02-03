pragma solidity >=0.8.23;

import { LimitedStaticPricedMintNft } from "../LimitedStaticPricedMintNft.sol";
import { IPricedMintNft } from "../IPricedMintNft.sol";
import { IBaseNft } from "../IBaseNft.sol";

import "forge-std/Test.sol";

contract LimitedStaticPricedMintNftTest is Test {
    LimitedStaticPricedMintNft nft;
    
    address constant OWNER = address(uint160(uint256(keccak256("OWNER"))));
    address constant TEST_USER_1 = address(uint160(uint256(keccak256("TEST_USER_1"))));
    uint256 constant PRICE = 0.01 ether;
    uint256 constant MINT_LIMIT = 256;

    error ERC721InvalidSender(address sender);

    function setUp() public {
        nft = new LimitedStaticPricedMintNft("LimitedStaticPricedMintNft", "LSPMNFT", OWNER, PRICE, MINT_LIMIT);
        vm.deal(TEST_USER_1, 1000 ether);
    }

    function testSimpleMint() public {
        uint256 existingOwnerBalance = OWNER.balance;
        vm.startPrank(TEST_USER_1);
        nft.mintTo{ value: 0.01 ether}(TEST_USER_1, 0x0);
        
        assertEq(OWNER.balance, existingOwnerBalance + 10000000000000000);
        assertEq(nft.balanceOf(TEST_USER_1), 1);
    }

    function testMints(uint256 mintLimit) public {
        vm.assume(mintLimit <= 10000 && mintLimit > 0);
        nft = new LimitedStaticPricedMintNft("LimitedStaticPricedMintNft", "LSPMNFT", OWNER, PRICE, mintLimit);
        vm.startPrank(TEST_USER_1);
        for(uint256 i = 0; i < mintLimit; i++) {
            uint256 existingOwnerBalance = OWNER.balance;
            uint256 existingPrice = nft.price();
            bytes32 mintHash = bytes32(keccak256(abi.encodePacked(i))); 
            
            // Fail to mint if underpaying
            vm.expectRevert(abi.encodeWithSelector(IPricedMintNft.InsufficientMintValue.selector, existingPrice - 1));
            nft.mintTo{ value: existingPrice - 1}(TEST_USER_1, mintHash);

            nft.mintTo{ value: existingPrice}(TEST_USER_1, mintHash);
            assertEq(OWNER.balance, existingOwnerBalance + existingPrice);
            assertEq(nft.balanceOf(TEST_USER_1), i + 1);
        }
        console.log(nft.balanceOf(TEST_USER_1));
        uint256 existingPrice = nft.price();
        vm.expectRevert(IBaseNft.CannotMintAfterMintEnded.selector);
        nft.mintTo{ value: existingPrice}(TEST_USER_1, bytes32(keccak256(abi.encodePacked(mintLimit))));
    }

    function testCannotUnderpay(uint256 underpaymentAmount) public {
        uint256 existingPrice = nft.price();
        vm.expectRevert(abi.encodeWithSelector(IPricedMintNft.InsufficientMintValue.selector, existingPrice - 1));
        nft.mintTo{ value: existingPrice - 1}( TEST_USER_1, 0x0);
    }

    function testCannotRemint() public {
        uint256 existingPrice = nft.price();
        vm.startPrank(TEST_USER_1);
        nft.mintTo{ value: existingPrice}(TEST_USER_1, 0x0);
        
        existingPrice = nft.price();
        vm.expectRevert(abi.encodeWithSelector(ERC721InvalidSender.selector, address(0x0)));
        nft.mintTo{ value: existingPrice}(TEST_USER_1, 0x0);
    }

    function testOnlyOwnerSetters(address caller, address setToAddress, uint256 setToUint, uint96 setToUint96, string memory newUri) public {
        vm.assume(caller != OWNER);
        vm.startPrank(caller);

        vm.expectRevert();
        nft.setFundRecipient(setToAddress);
        vm.expectRevert();
        nft.setBaseURI(newUri);
    }

    function testSetBaseURI() public {
        string memory baseURI = "https://example.com/";
        vm.startPrank(OWNER);
        nft.setBaseURI("https://example.com/");

        uint256 existingPrice = nft.price();
        vm.startPrank(TEST_USER_1);
        bytes32 mintHash = bytes32(uint256(42));
        nft.mintTo{ value: existingPrice}(TEST_USER_1, mintHash);

        assertEq(nft.tokenURI(42), "https://example.com/42");
    }

    function testSetFundRecipient() public {
        address fundRecipient = address(uint160(uint256(keccak256("FUND_RECIPIENT"))));
        vm.startPrank(OWNER);
        nft.setFundRecipient(fundRecipient);
        assertEq(nft.fundRecipient(), fundRecipient);

        uint256 existingPrice = nft.price();
        uint256 existingFundRecipient = fundRecipient.balance;
        vm.startPrank(TEST_USER_1);
        nft.mintTo{ value: existingPrice}(TEST_USER_1, 0x0);
        
        assertEq(fundRecipient.balance, existingFundRecipient + existingPrice);
        assertEq(nft.balanceOf(TEST_USER_1), 1);
    }
}
