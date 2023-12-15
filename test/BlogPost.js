const BlogPost = artifacts.require("BlogPost");

contract("BlogPost", (accounts) => {
  let blogPostInstance;

  before(async () => {
    // Deploy the BlogPost contract
    blogPostInstance = await BlogPost.deployed();

    // Register user accounts[1]
    await blogPostInstance.registerUser({ from: accounts[1] });

    // Debugging: Print user registration status
    const isRegistered = await blogPostInstance.registeredUsers.call(
      accounts[1]
    );
    console.log("Is registered:", isRegistered);

    // Create a post
    await blogPostInstance.createPost("Test Post Title", "Test Post Content", {
      from: accounts[0],
    });
  });

  it("should like a post", async () => {
    // Check if the user is registered
    const isRegistered = await blogPostInstance.registeredUsers.call(
      accounts[1]
    );
    assert.equal(isRegistered, true, "User should be registered");

    // Like the post
    await blogPostInstance.likePost(0, { from: accounts[1] });

    // Check if the post has a like
    const post = await blogPostInstance.getPost(0);
    assert.equal(post.likes, 1, "Likes count should be 1");
  });

  it("should reward authors", async () => {
    const rewardAmount = web3.utils.toWei("1", "ether");

    // Send Ether to the contract for rewards
    await web3.eth.sendTransaction({
      from: accounts[0],
      to: blogPostInstance.address,
      value: rewardAmount,
    });

    // Reward authors
    await blogPostInstance.rewardAuthors({ from: accounts[0] });

    // Check if the reward event is emitted
    const events = await blogPostInstance.getPastEvents("AuthorsRewarded");
    assert.equal(events.length, 1, "AuthorsRewarded event should be emitted");

    // Check if the reward distribution is correct (you may need to adjust this based on your logic)
    // For simplicity, we assume only one post and one author
    const post = await blogPostInstance.getPost(0);
    assert.equal(
      web3.utils.toWei(post.likes.toString(), "ether"),
      rewardAmount,
      "Reward distribution is incorrect"
    );
  });
});
