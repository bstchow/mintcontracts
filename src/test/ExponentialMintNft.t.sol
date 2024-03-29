pragma solidity >=0.8.23;

import { ExponentialPricedMintNft } from "../ExponentialPricedMintNft.sol";
import { IPricedMintNft } from "../IPricedMintNft.sol";

import "forge-std/Test.sol";

// TODO: Insufficient test coverage
contract ExponentialPricedMintNftTest is Test {
    uint256 exponent = 3;
    uint256 denominator = 1000000;
    ExponentialPricedMintNft nft;
    
    address constant OWNER = address(uint160(uint256(keccak256("OWNER"))));
    address constant TEST_USER_1 = address(uint160(uint256(keccak256("TEST_USER_1"))));

    error ERC721InvalidSender(address sender);

    function setUp() public {
        nft = new ExponentialPricedMintNft("ExponentialPricedMintNft", "EMNFT", OWNER, exponent, denominator);
        vm.deal(TEST_USER_1, 1000 ether);
    }

    function testSimpleMint() public {
        uint256 existingPrice = nft.price();
        uint256 existingOwnerBalance = OWNER.balance;
        vm.prank(TEST_USER_1);
        nft.mintTo{ value: existingPrice}(TEST_USER_1, 0x0);
        
        assertEq(OWNER.balance, existingOwnerBalance + existingPrice);
        assertEq(nft.balanceOf(TEST_USER_1), 1);
        assertGt(nft.price(), existingPrice);
    }

    function testMints(uint256 seed) public {
        vm.startPrank(TEST_USER_1);
        for(uint256 i = 0; i < 200; i++) {
            uint256 existingOwnerBalance = OWNER.balance;
            uint256 existingPrice = nft.price();
            bytes32 mintHash = bytes32(keccak256(abi.encodePacked(seed, i))); 
            
            // Fail to mint if underpaying
            vm.expectRevert(abi.encodeWithSelector(IPricedMintNft.InsufficientMintValue.selector, existingPrice - 1));
            nft.mintTo{ value: existingPrice - 1}(TEST_USER_1, mintHash);
            nft.mintTo{ value: existingPrice}(TEST_USER_1, mintHash);
            assertEq(OWNER.balance, existingOwnerBalance + existingPrice);
            assertEq(nft.balanceOf(TEST_USER_1), i + 1);
            assertGt(nft.price(), existingPrice, "Price should increase with each mint");
        }
        vm.stopPrank();
    }

    /**
     * Shouldn't be possible due to overflow protection but just in case
     */
    function testOverflow(uint256 seed) public {
        vm.startPrank(TEST_USER_1);
        nft = new ExponentialPricedMintNft("ExponentialPricedMintNft", "EMNFT", OWNER, 256, 10**18);
        
        uint256 existingPrice = nft.price();
        bytes32 mintHash = bytes32(seed); 

        vm.deal(TEST_USER_1, existingPrice);

        nft.mintTo{ value: existingPrice}(TEST_USER_1, mintHash);

        vm.expectRevert();
        existingPrice = nft.price();
        vm.expectRevert();
        nft.mintTo{ value: existingPrice}(TEST_USER_1, mintHash);
    }

    function testCannotUnderpay(uint256 underpaymentAmount) public {
        uint256 existingPrice = nft.price();
        vm.expectRevert(abi.encodeWithSelector(IPricedMintNft.InsufficientMintValue.selector, existingPrice - 1));
        nft.mintTo{ value: existingPrice - 1}(TEST_USER_1, 0x0);
    }

    function testCannotRemint() public {
        uint256 existingPrice = nft.price();
        vm.prank(TEST_USER_1);
        nft.mintTo{ value: existingPrice}(TEST_USER_1, 0x0);
        
        existingPrice = nft.price();
        vm.expectRevert(abi.encodeWithSelector(ERC721InvalidSender.selector, address(0x0)));
        nft.mintTo{ value: existingPrice}(TEST_USER_1, 0x0);
    }

    function testOnlyOwnerSetters(address caller, address setToAddress, uint256 setToUint, uint96 setToUint96, string memory newUri, string memory projectScript) public {
        vm.assume(caller != OWNER);
        vm.startPrank(caller);
        vm.expectRevert();
        nft.setFundRecipient(setToAddress);
        vm.expectRevert();
        nft.setBaseURI(newUri);
        vm.expectRevert();
        nft.setProjectScript(projectScript);
    }

    function testSetProjectScript(string memory script) public {
        vm.prank(OWNER);
        nft.setProjectScript(script);

        assertEq(nft.projectScript(), script);
    }

    function testSetBaseURI() public {
        string memory baseURI = "https://example.com/";
        vm.prank(OWNER);
        nft.setBaseURI("https://example.com/");

        uint256 existingPrice = nft.price();
        bytes32 mintHash = bytes32(uint256(42));
        nft.mintTo{ value: existingPrice}(TEST_USER_1, mintHash);

        assertEq(nft.tokenURI(42), "https://example.com/42");
    }

    function testSetFundRecipient() public {
        address fundRecipient = address(uint160(uint256(keccak256("FUND_RECIPIENT"))));
        vm.prank(OWNER);
        nft.setFundRecipient(fundRecipient);
        assertEq(nft.fundRecipient(), fundRecipient);

        uint256 existingPrice = nft.price();
        uint256 existingFundRecipient = fundRecipient.balance;
        nft.mintTo{ value: existingPrice}(TEST_USER_1, 0x0);
        
        assertEq(fundRecipient.balance, existingFundRecipient + existingPrice);
        assertEq(nft.balanceOf(TEST_USER_1), 1);
        assertGt(nft.price(), existingPrice);
    }
}
