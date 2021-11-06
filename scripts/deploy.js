const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Annoying Dog", "Flowey", "Sans"], // Names
    [
      "https://imgur.com/pKra7We", // gifs
      "https://imgur.com/t/undertale/EcmBZoZ",
      //   "https://imgur.com/6wEO7cv",
      "https://imgur.com/gallery/15UmAMe",
    ],
    ["Insult Appearance!", "Tell them to eat veggies", "Refuse to say gm!"],
    // HP values
    [100, 200, 300],
    //attack damage
    [10, 30, 50],
    // attack cooldown
    [15, 18, 20],
    "Greater Doge", //boss name
    10000, // boss hp
    60, // boss damage
    "https://imgur.com/gallery/j086aiq" // boss image
  );
  await gameContract.deployed();
  console.log("game contract deployed to: ", gameContract.address);

  let txn;
  // Use character index as 1,2,3 etc, don't bother with 0-indexing
  txn = await gameContract.mintCharacterNFT(3);
  await txn.wait();
  console.log("Minted NFT #1");

  // Use character index as 1,2,3 etc, don't bother with 0-indexing
  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();
  console.log("Minted NFT #2");

  // Use character index as 1,2,3 etc, don't bother with 0-indexing
  txn = await gameContract.mintCharacterNFT(1);
  await txn.wait();
  console.log("Minted NFT #3");

  const getTokenURI = await gameContract.tokenURI(1);
  console.log("token URI for #1 NFT:", getTokenURI);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (err) {
    console.log(err);
    process.exit(1);
  }
};

runMain();
