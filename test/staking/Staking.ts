import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { expect } from "chai";
import { ethers } from "hardhat";

import type { MOCK_ERC20__factory, MOCK_ERC721__factory, Staking__factory } from "../../src/types";
import { Signers } from "../types";

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];
    this.signers.alice = signers[1];
    this.signers.bob = signers[2];

    const erc721MockFactory: MOCK_ERC721__factory = <MOCK_ERC721__factory>(
      await ethers.getContractFactory("MOCK_ERC721")
    );
    const erc20MockFactory: MOCK_ERC20__factory = <MOCK_ERC20__factory>await ethers.getContractFactory("MOCK_ERC20");

    this.erc721Mock = await erc721MockFactory.deploy();
    this.erc20Mock = await erc20MockFactory.deploy();
  });

  describe("Staking", function () {
    beforeEach(async function () {
      const stakingFactory: Staking__factory = <Staking__factory>await ethers.getContractFactory("Staking");
      this.staking = await stakingFactory.deploy(this.erc721Mock.address, this.erc20Mock.address);
    });

    it("offer function should be reverted for alice", async function () {
      await expect(this.staking.connect(this.signers.alice).offer(0, ethers.utils.parseEther("100"))).revertedWith(
        "Ownership token is required",
      );
    });

    it("offer function should be reverted for unapproved token id", async function () {
      await expect(this.staking.connect(this.signers.admin).offer(0, ethers.utils.parseEther("100"))).to.be.reverted;
    });

    it("offer function should work", async function () {
      await this.erc721Mock.connect(this.signers.admin).approve(this.staking.address, 0);
      await expect(this.staking.connect(this.signers.admin).offer(0, ethers.utils.parseEther("100")))
        .to.emit(this.staking, "StakeCreated")
        .withArgs(this.signers.admin.address, 0, ethers.utils.parseEther("100"));
      expect(await this.erc721Mock.ownerOf(0)).equal(this.staking.address);
    });
  });
});
