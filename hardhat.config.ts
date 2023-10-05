import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import 'dotenv/config';
require('dotenv').config();

const config: HardhatUserConfig = {
  solidity: '0.8.21',
  networks: {
    goerli: {
      url: process.env.GOERLIRPC,
      //@ts-ignore
      accounts: [process.env.PRIVATE_KEY],
    },
  },

  // etherscan: {
  //   // Your API key for Etherscan
  //   // Obtain one at https://etherscan.io/
  //   apiKey: process.env.BASE_API_KEY,
  // },
};

export default config;