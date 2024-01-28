pragma solidity >=0.8.21;

import { ExponentialMintNft } from "../ExponentialMintNft.sol";
import "forge-std/Test.sol";

contract ExponentialMintNftTest is Test {
    uint256 exponent;
    uint256 denominator;
    address owner = address(uint160(keccak256("OWNER")));
    ExponentialMintNft nft;

    function setUp() public {
        exponent = 2;
        denominator = 20000;
        owner = msg.sender;
        nft = new ExponentialMintNft("ExponentialMintNft", "EMNFT", owner, exponent, denominator);
    }

    function testSimpleMint() public {
        address sender = address(0x1);
        uint256 originalPrice = nft.price();
        vm.prank(sender);
        nft.mint(0x0);
        
        assert(nft.balanceOf(msg.sender) == 1);
        assert(nft.price() > originalPrice);
    }

    function testFuzzedMint() public {
        vm.prank(0x1);
        nft.mint(0x0);
        for(uint256 i = 0; i < 10; i++) {
            uint256 originalPrice = nft.price();
            nft.mint(bytes32(i));
            assert(nft.balanceOf(msg.sender) == i + 1);
            assert(nft.price() > originalPrice);
        }
    }

    function testCannotRemint() public {
        vm.prank(0x1);
        nft.mint(0x0);
        nft.mint(0x0);
        assert(nft.balanceOf(msg.sender) == 1);
    }
}
