// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC5643.sol";

contract SubscriptionModel is ERC721, IERC5643 {
    struct Subscription {
        uint64 expiration;
    }

    mapping(uint256 => Subscription) private _subscriptions;
    mapping(address => uint256) private _userSubscriptions;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
     * @dev Mint a new NFT with the given tokenId.
     * @param tokenId The ID of the NFT to be minted.
     */
    function mintNFT(uint256 tokenId) external {
        // You can implement the logic to create a new NFT here
        // For example, you can use the ERC721 _mint function to create a new token
        _mint(msg.sender, tokenId);
    }

    /**
     * @dev Renew or create a new subscription for the given tokenId.
     * @param tokenId The ID of the NFT for which the subscription is being renewed or created.
     * @param duration The duration of the subscription in seconds.
     */
    function renewSubscription(uint256 tokenId, uint64 duration) external payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        require(duration > 0, "Invalid duration.");

        Subscription storage subscription = _subscriptions[tokenId];

        if (subscription.expiration > block.timestamp) {
            // Renew existing subscription
            require(isRenewable(tokenId), "Subscription cannot be renewed.");
            subscription.expiration += duration;
        } else {
            // Create a new subscription
            subscription.expiration = uint64(block.timestamp) + duration;
            _userSubscriptions[msg.sender] = tokenId;
        }

        emit SubscriptionUpdate(tokenId, subscription.expiration);
    }

    /**
     * @dev Cancel the subscription for the given tokenId.
     * @param tokenId The ID of the NFT for which the subscription is being canceled.
     */
    function cancelSubscription(uint256 tokenId) external payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        require(_userSubscriptions[msg.sender] == tokenId, "No active subscription.");

        Subscription storage subscription = _subscriptions[tokenId];
        require(subscription.expiration > block.timestamp, "Subscription is already expired.");

        subscription.expiration = 0;
        delete _userSubscriptions[msg.sender];

        emit SubscriptionUpdate(tokenId, 0);
    }

    /**
     * @dev Get the expiration timestamp of the subscription for the given tokenId.
     * @param tokenId The ID of the NFT for which to retrieve the expiration timestamp.
     * @return The expiration timestamp of the subscription.
     */
    function expiresAt(uint256 tokenId) external view override returns (uint64) {
        return _subscriptions[tokenId].expiration;
    }

    /**
     * @dev Check if the subscription for the given tokenId can be renewed.
     * @param tokenId The ID of the NFT to check for renewability.
     * @return A boolean indicating whether the subscription can be renewed.
     */
    function isRenewable(uint256 tokenId) public view override returns (bool) {
        Subscription storage subscription = _subscriptions[tokenId];
        return subscription.expiration > block.timestamp;
    }

    // Event to notify about subscription expiration changes
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);

    // Other functions and features specific to your CryptoFit project can be added here.
}
