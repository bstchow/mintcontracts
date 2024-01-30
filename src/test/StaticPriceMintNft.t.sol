pragma solidity >=0.8.21;

import { StaticPriceMintNft } from "../StaticPriceMintNft.sol";
import { IStaticPriceMintNft } from "../IStaticPriceMintNft.sol";

import "forge-std/Test.sol";

contract StaticPriceMintNftTest is Test {
    StaticPriceMintNft nft;
    
    address constant OWNER = address(uint160(uint256(keccak256("OWNER"))));
    address constant TEST_USER_1 = address(uint160(uint256(keccak256("TEST_USER_1"))));
    uint256 constant PRICE = 0.01 ether;

    error ERC721InvalidSender(address sender);

    function setUp() public {
        nft = new StaticPriceMintNft("StaticPriceMintNft", "SPMNFT", OWNER, PRICE);
        vm.deal(TEST_USER_1, 1000 ether);
    }

    function testSimpleMint() public {
        uint256 existingPrice = nft.price();
        uint256 existingOwnerBalance = OWNER.balance;
        vm.prank(TEST_USER_1);
        nft.mintTo{ value: existingPrice}(0x0, TEST_USER_1);
        
        assertEq(OWNER.balance, existingOwnerBalance + existingPrice);
        assertEq(nft.balanceOf(TEST_USER_1), 1);
    }

    function testMints(uint256 seed) public {
        vm.startPrank(TEST_USER_1);
        for(uint256 i = 0; i < 200; i++) {
            uint256 existingOwnerBalance = OWNER.balance;
            uint256 existingPrice = nft.price();
            bytes32 mintHash = bytes32(keccak256(abi.encodePacked(seed, i))); 
            
            // Fail to mint if underpaying
            vm.expectRevert(abi.encodeWithSelector(IStaticPriceMintNft.InsufficientMintValue.selector, existingPrice - 1));
            nft.mintTo{ value: existingPrice - 1}(mintHash, TEST_USER_1);

            nft.mintTo{ value: existingPrice}(mintHash, TEST_USER_1);
            assertEq(OWNER.balance, existingOwnerBalance + existingPrice);
            assertEq(nft.balanceOf(TEST_USER_1), i + 1);
        }
        vm.stopPrank();
    }

    function testCannotUnderpay(uint256 underpaymentAmount) public {
        uint256 existingPrice = nft.price();
        vm.expectRevert(abi.encodeWithSelector(IStaticPriceMintNft.InsufficientMintValue.selector, existingPrice - 1));
        nft.mintTo{ value: existingPrice - 1}(0x0, TEST_USER_1);
    }

    function testCannotRemint() public {
        uint256 existingPrice = nft.price();
        vm.prank(TEST_USER_1);
        nft.mintTo{ value: existingPrice}(0x0, TEST_USER_1);
        
        existingPrice = nft.price();
        vm.expectRevert(abi.encodeWithSelector(ERC721InvalidSender.selector, address(0x0)));
        nft.mintTo{ value: existingPrice}(0x0, TEST_USER_1);
    }

    function testOnlyOwnerSetters(address caller, address setToAddress, uint256 setToUint, uint96 setToUint96, string memory newUri) public {
        vm.assume(caller != OWNER);
        vm.prank(caller);

        vm.expectRevert();
        nft.setDefaultRoyalty(setToAddress, setToUint96);
        vm.expectRevert();
        nft.setFundRecipient(setToAddress);
        vm.expectRevert();
        nft.setBaseURI(newUri);
    }

    function testSetDefaultRoyalty(address royaltyReceiver) public {
        vm.assume(royaltyReceiver != address(0x0));
        uint96 royalty = 1000;
        vm.prank(OWNER);
        nft.setDefaultRoyalty(royaltyReceiver, royalty);
        (address receiver, uint256 royaltyAmount) = nft.royaltyInfo(0, 1000 ether);
        assertEq(receiver, royaltyReceiver, "Correct receiver");
        assertEq(royaltyAmount, 1000 ether * royalty / 10000, "Correct amount");
    }

    function testSetBaseURI() public {
        string memory baseURI = "https://example.com/";
        vm.prank(OWNER);
        nft.setBaseURI("https://example.com/");

        uint256 existingPrice = nft.price();
        vm.prank(TEST_USER_1);
        bytes32 mintHash = bytes32(uint256(42));
        nft.mintTo{ value: existingPrice}(mintHash, TEST_USER_1);

        assertEq(nft.tokenURI(42), "https://example.com/42");
    }

    function testSetFundRecipient() public {
        address fundRecipient = address(uint160(uint256(keccak256("FUND_RECIPIENT"))));
        vm.prank(OWNER);
        nft.setFundRecipient(fundRecipient);
        assertEq(nft.fundRecipient(), fundRecipient);

        uint256 existingPrice = nft.price();
        uint256 existingFundRecipient = fundRecipient.balance;
        vm.prank(TEST_USER_1);
        nft.mintTo{ value: existingPrice}(0x0, TEST_USER_1);
        
        assertEq(fundRecipient.balance, existingFundRecipient + existingPrice);
        assertEq(nft.balanceOf(TEST_USER_1), 1);
    }
}
