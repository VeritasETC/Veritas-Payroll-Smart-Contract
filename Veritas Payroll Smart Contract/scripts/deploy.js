// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
    const currentTimestampInSeconds = Math.round(Date.now() / 1000);
    const unlockTime = currentTimestampInSeconds + 60;

    const lockedAmount = hre.ethers.utils.parseEther("0.001");

    const Payroll = await hre.ethers.getContractFactory("Payroll");
    const payroll = await Payroll.deploy();

    await payroll.deployed();

    console.log(
        `Payroll with ${ethers.utils.formatEther(
            lockedAmount
        )}ETH and unlock timestamp ${unlockTime} deployed to ${payroll.address}`
    );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();
