// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

interface ERC20Interface {
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
