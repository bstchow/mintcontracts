pragma solidity >=0.8.21;

import { ExponentialMintNft } from "../ExponentialMintNft.sol";
import { IExponentialMintNft } from "../IExponentialMintNft.sol";

import "forge-std/Test.sol";

contract ExponentialMintNftTest is Test {
    uint256 exponent = 2;
    uint256 denominator = 20000;
    ExponentialMintNft nft;
    
    address constant OWNER = address(uint160(uint256(keccak256("OWNER"))));
    address constant TEST_USER_1 = address(uint160(uint256(keccak256("TEST_USER_1"))));

    function setUp() public {
        nft = new ExponentialMintNft("ExponentialMintNft", "EMNFT", OWNER, exponent, denominator);
        vm.deal(TEST_USER_1, 1000 ether);
    }

    function testSimpleMint() public {
        uint256 existingPrice = nft.price();
        uint256 existingOwnerBalance = OWNER.balance;
        vm.prank(TEST_USER_1);
        nft.mint{ value: existingPrice}(0x0);
        
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
            vm.expectRevert(abi.encodeWithSelector(IExponentialMintNft.InsufficientMintValue.selector, existingPrice - 1));
            nft.mint{ value: existingPrice - 1}(mintHash);

            nft.mint{ value: existingPrice}(mintHash);
            assertEq(OWNER.balance, existingOwnerBalance + existingPrice);
            assertEq(nft.balanceOf(TEST_USER_1), i + 1);
            assertGt(nft.price(), existingPrice, "Price should increase with each mint");
        }
        vm.stopPrank();
    }

    function testCannotUnderpay(uint256 underpaymentAmount) public {
        uint256 existingPrice = nft.price();
        vm.expectRevert(abi.encodeWithSelector(IExponentialMintNft.InsufficientMintValue.selector, existingPrice - 1));
        nft.mint{ value: existingPrice - 1}(0x0);
    }

    function testCannotRemint() public {
        uint256 existingPrice = nft.price();
        vm.prank(TEST_USER_1);
        nft.mint{ value: existingPrice}(0x0);
        
        existingPrice = nft.price();
        vm.expectRevert("ERC721: token already minted");
        nft.mint{ value: existingPrice}(0x0);
    }
}
