// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./ERC20Interface.sol";

contract AirDrop {
    event TokenAirdropCreated(
        string name,
        uint256 id,
        address airDropTokenAddress
    );
    event TokenClaimed(uint256 airdropID, address account, uint256 amount);

    struct AirdropTokenDetails {
        string airDropName;
        bytes32 merkleRoot;
        address airDropTokenAddress;
        uint approvedAmount;
        uint maxUsers;
        uint claims;
    }

    mapping(uint => AirdropTokenDetails) allTokens;
    mapping(address => mapping(uint => bool)) hasAddressClaim;
    mapping(uint => bool) isAirdropExist;

    uint airDropCounter;

    modifier onlyUnclaimedAddress(address caller, uint airDropId) {
        require(
            !hasAddressClaim[caller][airDropId],
            "Only Unclaimed Addresses"
        );
        _;
    }

    function createAirdrop(
        string memory _airDropName,
        bytes32 _merkleRoot,
        address _airDropTokenAddress,
        uint _max
    ) external returns (uint airDropId) {
        airDropCounter++;
        AirdropTokenDetails storage airdrop = allTokens[airDropCounter];
        airdrop.airDropName = _airDropName;
        airdrop.merkleRoot = _merkleRoot;
        airdrop.airDropTokenAddress = _airDropTokenAddress;
        airdrop.maxUsers = _max;
        airdrop.claims = 0;
        isAirdropExist[airDropCounter] = true;
        emit TokenAirdropCreated(
            _airDropName,
            airDropCounter,
            _airDropTokenAddress
        );
        return (airDropCounter);
    }

    function isTokenClaimed(
        address _user,
        uint256 _airdropID
    ) public view returns (bool) {
        return hasAddressClaim[_user][_airdropID];
    }

    function claimToken(
        uint256 _airdropId,
        uint256 _amount,
        bytes32[] calldata _merkleProof
    )
        external
        onlyUnclaimedAddress(msg.sender, _airdropId)
        returns (bool claimed)
    {
        AirdropTokenDetails storage airdrop = allTokens[_airdropId];
        require(airdrop.maxUsers > 0, "Airdrop is not created yet");
        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(msg.sender, _amount));
        bytes32 merkleRoot = airdrop.merkleRoot;
        address token = airdrop.airDropTokenAddress;
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, node),
            "MerkleDistributor: Invalid proof."
        );

        // Mark it claimed and send the token.
        hasAddressClaim[msg.sender][_airdropId] = true;
        ERC20Interface(token).transferFrom(address(this), msg.sender, _amount);
        airdrop.claims++;
        //only emit when successful
        claimed = true;
        emit TokenClaimed(_airdropId, msg.sender, _amount);
    }
}
