// scripts/withdraw.js

const hre = require("hardhat");
const abi = require("../artifacts/contracts/BuyMeACoffee.sol/BuyMeACoffee.json");

async function getBalance(provider, address) {
  const balanceBigInt = await provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

async function main() {
  // Get the contract that has been deployed to Goerli.
  const contractAddress="0x4BFD1dfE0AC9a5e06603CadeD667427b59A55c1C";
  const contractABI = abi.abi;

  // Get the node connection and wallet connection.
  const provider = new hre.ethers.providers.AlchemyProvider("goerli", process.env.GOERLI_API_KEY);

  // Ensure that signer is the SAME address as the original contract deployer,
  // or else this script will fail with an error.
  const signer = new hre.ethers.Wallet(process.env.PRIVATE_KEY, provider);

  // Instantiate connected contract.
  const buyMeACoffee = new hre.ethers.Contract(contractAddress, contractABI, signer);

  // Check starting balances.
  console.log( `current balance of owner: ${signer.address} `, await getBalance(provider, signer.address), "ETH");
  let contractBalance = await getBalance(provider, buyMeACoffee.address);
  console.log("current balance of contract: ", await getBalance(provider, buyMeACoffee.address), "ETH");

  // buy coffee
  const tip = { value : hre.ethers.utils.parseEther("0.001") };
  await buyMeACoffee.connect(signer).buyCoffee("Ethan", "bad but cheap" ,tip);

  // Check ending balance.
  console.log("current balance of owner: ", await getBalance(provider, signer.address), "ETH");
   // Check contract ending balances.
   contractBalance = await getBalance(provider, buyMeACoffee.address);
   console.log("current balance of contract: ", contractBalance, "ETH");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
