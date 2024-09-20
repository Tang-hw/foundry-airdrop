// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    DeployMerkleAirdrop public deployer;
    MerkleAirdrop public airdrop;
    BagelToken public token;

    bytes32 public ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 private PROOF1 =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 private PROOF2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [PROOF1, PROOF2];
    address public gasPayer;
    address user;
    uint256 userPrivKey;
    uint256 public AMOUNT = 25 * 1e18;
    uint256 public START_AMOUNT = 100 * 1e18;

    function setUp() public {
        deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.run();
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digset = airdrop.getMessageHash(user, AMOUNT);
        //vm.prank(user);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digset);
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT);
    }
}
