// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

// returns the ether balance of a given address
async function getBalance(address) {
  const balanceBigInt = await hre.waffle.provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

// logs the ether balance for a list of addresses
async function printBalance(addresses) {
  let idx = 0;
  for (addr of addresses) {
    const balance = await getBalance(addr);
    console.log(`Addr # ${idx}: ${addr} has ${balance} ETH`);
    idx++;
  }
}

// logs the memo stored onchain from the coffee purchases
async function printMemos(memos) {
  for (memo of memos) {
   const timestamp = memo.timestamp;
   const tipper = memo.name;
   const tipperAddress = memo.from;
   const message = memo.message;
   console.log( `At ${timestamp}, ${tipper} ${tipperAddress} said: ${message}`);
  }
}



async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // Get example accounts
  const [ owner, tipper , tipper2, tipper3] = await hre.ethers.getSigners();

  // Deploy contract
  const BuyMeACoffee = await hre.ethers.getContractFactory("BuyMeACoffee");
  const buyMeACoffee = await BuyMeACoffee.deploy();
  await buyMeACoffee.deployed();
  console.log(`BuyMeACoffee deployed to ${buyMeACoffee.address}`);

  // Check balances before coffee purchase
  const addresses = [owner.address, tipper.address, buyMeACoffee.address];
  console.log("==start==");
  await printBalance(addresses);

  // Buy the owner a few coffees
  const tip = { value : hre.ethers.utils.parseEther("1") };
  await buyMeACoffee.connect(tipper).buyCoffee("Ethan", "bad but cheap" ,tip);
  await buyMeACoffee.connect(tipper2).buyCoffee("Tito", "not a bad coffee" ,tip);
  await buyMeACoffee.connect(tipper3).buyCoffee("Prince", "nothing compares 2 u" ,tip);
  
  // Check balances after coffee purchase
  console.log("==bought coffee==");
  await printBalance(addresses);

  // Withdraw funds
  await buyMeACoffee.connect(owner).withdrawTips();

  // CHeck balances after withdrawal
  console.log("==withdraw tips==");
  await printBalance(addresses);

  // Read all memos left for the owner
  let memos = await buyMeACoffee.connect(owner).getMemos();
  console.log("==owner memos==");
  await printMemos(memos);

}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
