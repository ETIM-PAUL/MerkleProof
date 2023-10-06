// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, stdJson} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {AirDrop} from "../contracts/Airdrop.sol";

contract Airdrop is Test {
    AirDrop public airdrop;
    using stdJson for string;

    struct AccountMerkle {
        bytes32 leaf;
        bytes32[] proof;
    }

    AccountMerkle public account;

    bytes32 root =
        0xc87618c6c49eb4b0825fe2b7323eb2d0a34647d57571acbc0eed60825db81123;

    address account1 = 0x001Daa61Eaa241A8D89607194FC3b1184dcB9B4C;
    uint accountAmount = 45000000000000;

    bytes32[] public fakeProof = [
        vm.parseBytes32(
            "0x675d7edf838f68df7f1d463ecef23b3ac8c04d636d8c44fca583466c59bea990"
        ),
        vm.parseBytes32(
            "0x1916ed21514279507a3efc50fac4489a2027c88509d50a1f78fe4f4a45f4f0af"
        ),
        vm.parseBytes32(
            "0x43b1b011685f699f56c4c24033fdb47d8ba7bb46e8fad4903c89f7ff50716c3a"
        ),
        vm.parseBytes32(
            "0x1916ed21514279507a3efc50fac4489a2027c88509d50a1f78fe4f4a45f4f0af"
        )
    ];

    function setUp() public {
        airdrop = new AirDrop(root);
        string memory _root = vm.projectRoot();

        //read from merkle_tree.json file
        string memory path = string.concat(_root, "/merkle_tree.json");
        string memory json = vm.readFile(path);

        bytes memory res = json.parseRaw(
            string.concat(".", vm.toString(account1))
        );

        account = abi.decode(res, (AccountMerkle));
        console.logBytes32(account.proof[0]);
    }

    function test_onlyUnclaimedAddress() external {
        bool hasAddressClaim = airdrop.isTokenClaimed(account1);
        assertFalse(hasAddressClaim);
    }

    function test_isNotZeroAddress() external {
        account1 = 0x0000000000000000000000000000000000000000;
        vm.expectRevert("No Zero Address");
        airdrop.claimToken(account1, accountAmount, account.proof);
    }

    function test_amountGreaterThanZero() external {
        accountAmount = 0;
        vm.expectRevert("Amount must be greater than zero");
        airdrop.claimToken(account1, accountAmount, account.proof);
    }

    function test_expectInvalidProofError() external {
        vm.expectRevert("MerkleDistributor: Invalid proof.");
        airdrop.claimToken(account1, accountAmount, fakeProof);
    }

    function testFail_expectAddressNotWhiteListedToFail() external {
        account1 = 0x1b6e16403b06a51C42Ba339E356a64fE67348e92;
        bool success = airdrop.claimToken(account1, accountAmount, fakeProof);
        assertFalse(success);
    }

    function testFail_expectInvalidAmountOfWhiteListedAddressToFail() external {
        accountAmount = 48000000000000;
        bool success = airdrop.claimToken(account1, accountAmount, fakeProof);
        assertFalse(success);
    }

    function testClaimToken() external {
        airdrop.claimToken(account1, accountAmount, account.proof);
        assertEq(airdrop.balanceOf(account1), accountAmount);
    }
}
