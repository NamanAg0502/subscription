const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('SubscriptionModel', function () {
  let subscriptionModel;
  const tokenId = 1;
  let ownerAddress; // Define the ownerAddress variable

  // Deploy the SubscriptionModel contract before each test
  beforeEach(async function () {
    const SubscriptionModel = await ethers.getContractFactory(
      'SubscriptionModel'
    );
    subscriptionModel = await SubscriptionModel.deploy(
      'CryptoFit Subscription',
      'CFS'
    );
    await subscriptionModel.deployed();

    // Assign the owner's address to the ownerAddress variable
    const [owner] = await ethers.getSigners();
    ownerAddress = await owner.getAddress();

    // Mint a new NFT before each test
    await subscriptionModel.mintNFT(tokenId, { from: ownerAddress });
  });

  it('should renew the subscription and update the expiration date', async function () {
    const duration = 60 * 60 * 24 * 30; // Renew for 30 days

    // Call the renewSubscription function to set the expiration
    await subscriptionModel.renewSubscription(tokenId, duration, {
      from: ownerAddress,
    });

    // Call the expiresAt function to get the expiration date
    const expiration = await subscriptionModel.expiresAt(tokenId);

    // Calculate the expected expiration date (current timestamp + duration)
    const expectedExpiration = Math.floor(Date.now() / 1000) + duration;

    // Verify that the expiration date is approximately equal to the expected value
    // (Allowing for a slight delay in block timestamp)
    expect(expiration.toNumber()).to.be.closeTo(expectedExpiration, 5);
  });

  it('should cancel the subscription and set the expiration to zero', async function () {
    const duration = 60 * 60 * 24 * 30; // Renew for 30 days

    // Call the renewSubscription function to set the expiration
    await subscriptionModel.renewSubscription(tokenId, duration, {
      from: ownerAddress,
    });

    // Call the cancelSubscription function to cancel the subscription
    await subscriptionModel.cancelSubscription(tokenId, { from: ownerAddress });

    // Call the expiresAt function to get the expiration date
    const expiration = await subscriptionModel.expiresAt(tokenId);

    // Verify that the expiration is set to zero
    expect(expiration.toNumber()).to.equal(0);
  });
});
