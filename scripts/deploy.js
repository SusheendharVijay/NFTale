const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Annoying Dog", "Flowey", "Sans"], // Names
    [
      "https://i.imgur.com/pKra7We.gif", // gifs
      "https://i.imgur.com/EcmBZoZ.gif",
      "https://imgur.com/6wEO7cv.gif",
    ],
    ["Insult Appearance!", "Tell them to eat veggies", "Refuse to say gm!"],
    // HP values
    [100, 200, 300],
    //attack damage
    [10, 30, 50],
    "Greater Doge", //boss name
    10000, // boss hp
    60, // boss damage
    "https://imgur.com/gallery/j086aiq" // boss image
  );
  await gameContract.deployed();
  console.log("game contract deployed to: ", gameContract.address);
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
