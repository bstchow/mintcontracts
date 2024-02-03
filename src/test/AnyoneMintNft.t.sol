pragma solidity >=0.8.23;

import { AnyoneMintNft } from "../AnyoneMintNft.sol";
import { IAnyoneMintNft } from "../IAnyoneMintNft.sol";

import "forge-std/Test.sol";

// TODO: Insufficient test coverage
contract AnyoneMintNftTest is Test {
    AnyoneMintNft nft;
    
    address constant OWNER = address(uint160(uint256(keccak256("OWNER"))));
    address constant TEST_USER_1 = address(uint160(uint256(keccak256("TEST_USER_1"))));

    error ERC721InvalidSender(address sender);

    function setUp() public {
        nft = new AnyoneMintNft("AnyoneMintNft", "AMNFT", OWNER);
        vm.deal(TEST_USER_1, 1000 ether);
    }

    function testSimpleMint() public {
        vm.prank(TEST_USER_1);
        nft.mintTo(TEST_USER_1, 0x0);
    
        assertEq(nft.balanceOf(TEST_USER_1), 1);
    }

    function testMints(uint256 seed) public {
        vm.startPrank(TEST_USER_1);
        for(uint256 i = 0; i < 200; i++) {
            bytes32 mintHash = bytes32(keccak256(abi.encodePacked(seed, i))); 

            nft.mintTo(TEST_USER_1, mintHash);
            assertEq(nft.balanceOf(TEST_USER_1), i + 1);
        }
        vm.stopPrank();
    }

    function testCannotRemint() public {
        vm.prank(TEST_USER_1);
        nft.mintTo(TEST_USER_1, 0x0);
        
        vm.expectRevert(abi.encodeWithSelector(ERC721InvalidSender.selector, address(0x0)));
        nft.mintTo(TEST_USER_1, 0x0);
    }

    function testOnlyOwnerSetters(address caller, address setToAddress, uint256 setToUint, uint96 setToUint96, string memory newUri) public {
        vm.assume(caller != OWNER);
        vm.prank(caller);

        vm.expectRevert();
        nft.setBaseURI(newUri);
    }

    function testSetBaseURI() public {
        string memory baseURI = "https://example.com/";
        vm.prank(OWNER);
        nft.setBaseURI("https://example.com/");

        vm.prank(TEST_USER_1);
        bytes32 mintHash = bytes32(uint256(42));
        nft.mintTo(TEST_USER_1, mintHash);

        assertEq(nft.tokenURI(42), "https://example.com/42");
    }
}
