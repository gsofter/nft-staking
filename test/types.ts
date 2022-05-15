import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import type { Fixture } from "ethereum-waffle";

import type { MOCK_ERC20, MOCK_ERC721, Staking } from "../src/types";

declare module "mocha" {
  export interface Context {
    staking: Staking;
    erc20Mock: MOCK_ERC20;
    erc721Mock: MOCK_ERC721;
    loadFixture: <T>(fixture: Fixture<T>) => Promise<T>;
    signers: Signers;
  }
}

export interface Signers {
  admin: SignerWithAddress;
  alice: SignerWithAddress;
  bob: SignerWithAddress;
}
