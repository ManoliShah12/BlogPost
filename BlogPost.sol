// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlogPost is Ownable {
    // ERC-20 Reward Token
    IERC20 public rewardToken;
    address public adminAddress;
    mapping(address => bool) public registeredUsers;
    // Struct to represent a blog post
    struct Post {
        address author;
        string title;
        string content;
        uint256 likes;
    }
    // Array to store all blog posts
    Post[] public posts;

    // Mapping to store the likes given by users to each post
    mapping(uint256 => mapping(address => bool)) public postLikes;

    // Event emitted when a new post is created
    event PostCreated(uint256 postId, address author, string title, string content);

    // Event emitted when a post is edited
    event PostEdited(uint256 postId, string newContent);

    // Event emitted when a post is deleted
    event PostDeleted(uint256 postId);

    // Event emitted when a user likes a post
    event PostLiked(uint256 postId, address user);

    // Event emitted when authors are rewarded
    event AuthorsRewarded(uint256 totalRewards);

    // Modifier to ensure that only the author of a post can perform certain actions
    modifier onlyAuthor(uint256 _postId) {
        require(msg.sender == posts[_postId].author, "Not the author");
        _;
    }

    // Modifier to limit certain functions to administrators for content moderation
   modifier onlyAdmin() {
    // Add admin check logic here
    require(msg.sender == adminAddress, "Not an admin");
    _;
   }

   modifier onlyRegisteredUser() {
    // Add user registration check logic here
    require(isUserRegistered(msg.sender), "Not a registered user");
    _;
   }

   function isUserRegistered(address _user) internal view returns (bool) {
    // Add your registration check logic here
    // For example, you might have a mapping or other data structure to store registered users
    return registeredUsers[_user];
    }
    // Constructor to set the ERC-20 Reward Token address
     constructor(address _rewardToken, address initialOwner) Ownable(initialOwner) {
        rewardToken = IERC20(_rewardToken);
    }

    // Function to create a new blog post
   function createPost(string memory _title, string memory _content) external onlyRegisteredUser {
    posts.push(Post({
        author: msg.sender,
        title: _title,
        content: _content,
        likes: 0
    }));
    emit PostCreated(posts.length - 1, msg.sender, _title, _content);
}

    // Function to edit an existing blog post
    function editPost(uint256 _postId, string memory _newContent) external onlyAuthor(_postId) {
        posts[_postId].content = _newContent;
        emit PostEdited(_postId, _newContent);
    }

    // Function to delete a blog post
    function deletePost(uint256 _postId) external onlyAuthor(_postId) {
        delete posts[_postId];
        emit PostDeleted(_postId);
    }

    // Function to retrieve information about a specific blog post
    function getPost(uint256 _postId) external view returns (Post memory) {
        require(_postId < posts.length, "Invalid post ID");
        return posts[_postId];
    }

    // Function to retrieve a list of all published blog posts
    function getAllPosts() external view returns (Post[] memory) {
        return posts;
    }

    // Function to like a blog post
    function likePost(uint256 _postId) external onlyRegisteredUser {
        require(!postLikes[_postId][msg.sender], "Already liked");
        postLikes[_postId][msg.sender] = true;
        posts[_postId].likes++;
        emit PostLiked(_postId, msg.sender);
    }

    // Function to reward authors based on post popularity
    function rewardAuthors() external onlyAdmin {
        // Add logic to calculate rewards based on post popularity and distribute tokens to authors
        uint256 totalRewards = 100; // Placeholder value, replace with actual calculation
        emit AuthorsRewarded(totalRewards);
    }
}
