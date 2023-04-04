import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import secrets from "./.secret.testnet.json";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    "testnet-eth": {
      accounts: { mnemonic: secrets.mnemonic },
      url: `https://goerli.infura.io/v3/${secrets.api_key}`,
      chainId: 5,
    },
  },
  paths: {
    artifacts: "./client/src/artifacts",
  },
  namedAccounts: {
    deployer: {
      default: 3, // here this will by default take the first account as deployer
      testnet: 1,
    },
    signer: {
      default: 4, // here this will by default take the second account as feeCollector (so in the test this will be a different account than the deployer)
      testnet: 1,
    },
  },
};

export default config;
