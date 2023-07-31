require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    // Define your Ethereum networks here
    // For example, use the Polygon testnet Mumbai
    mumbai: {
      url: 'https://polygon-mumbai.infura.io/v3/4458cf4d1689497b9a38b1d6bbf05e78', // Replace with your preferred RPC URL
      accounts: [process.env.PRIVATE_KEY_1], // Array of private keys of accounts to use for deployment
    },
    // Add other networks as needed
    // For production, you'll need to add the mainnet network
  },
  solidity: {
    version: '0.8.0', // Specify the Solidity compiler version for your contracts
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
