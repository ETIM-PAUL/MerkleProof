// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract AirDrop is ERC20 {
    event TokenClaimed(address account, uint256 amount);

    mapping(address => bool) hasAddressClaim;
    mapping(uint => bool) isAirdropExist;

    bytes32 merkleRoot;

    constructor(bytes32 _merkleRoot) ERC20("Joe Tokens", "JOE", 18) {
        merkleRoot = _merkleRoot;
    }

    modifier onlyUnclaimedAddress(address caller) {
        require(!hasAddressClaim[caller], "Only Unclaimed Addresses");
        _;
    }

    function isTokenClaimed(address _user) public view returns (bool) {
        return hasAddressClaim[_user];
    }

    function claimToken(
        address _address,
        uint256 _amount,
        bytes32[] calldata _merkleProof
    ) external onlyUnclaimedAddress(_address) returns (bool claimed) {
        require(_address != address(0), "No Zero Address");
        require(_amount > 0, "Amount must be greater than zero");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(_address, _amount));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, node),
            "MerkleDistributor: Invalid proof."
        );

        // Mark it claimed and send the token.
        hasAddressClaim[_address] = true;
        claimed = true;
        _mint(_address, _amount);
        emit TokenClaimed(msg.sender, _amount);
    }
}
