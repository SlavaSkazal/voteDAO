const { expect } = require("chai");

describe("DAO contract", function () {

    //const ETHERS = 10**18;
    const ETHERS = 1;

    let voteContract;
    let VoteContract;
    let owner;
    let addr1;
    let addrs;

    beforeEach(async function () {
        voteContract = await ethers.getContractFactory("voteDAO");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        VoteContract = await voteContract.deploy();
        await VoteContract.deployed();
    });

    describe("Transactions", function () {

        it("Should the balance is replenished and balance request is working", async function () {  
            await VoteContract.connect(owner).deposit(5 * ETHERS);
            expect(await VoteContract.balanceOf(owner.address)).to.equal(5 * ETHERS);
        });

        it("Should balance can be replenished and withdrawn", async function () {  
            await VoteContract.connect(owner).deposit(5 * ETHERS);
            await VoteContract.connect(owner).withdraw(5 * ETHERS);
            expect(await VoteContract.balanceOf(owner.address)).to.equal(0);
        });

    });
  });