import { ethers } from "hardhat";

async function main() {

  const airdrop = await ethers.deployContract("AirDrop");

  await airdrop.waitForDeployment();

  console.log("Merkel Airdrop contract deployed to", airdrop.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
