// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlogPost {
    address public owner;
    address public adminAddress;
    mapping(address => bool) public registeredUsers;

    struct Post {
        address author;
        string title;
        string content;
        uint256 likes;
    }

    Post[] public posts;
    mapping(uint256 => mapping(address => bool)) public postLikes;

    event PostCreated(uint256 postId, address author, string title, string content);
    event PostEdited(uint256 postId, string newContent);
    event PostDeleted(uint256 postId);
    event PostLiked(uint256 postId, address user);
    event AuthorsRewarded(uint256 totalRewards);

    function registerUser() external {
        require(!registeredUsers[msg.sender], "User already registered");
        registeredUsers[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not an admin");
        _;
    }

    modifier onlyRegisteredUser() {
        require(isUserRegistered(msg.sender), "Not a registered user");
        _;
    }

    function isUserRegistered(address _user) internal view returns (bool) {
        return registeredUsers[_user];
    }

    constructor(address _adminAddress) {
        owner = msg.sender;
        adminAddress = _adminAddress;
    }

    function createPost(string memory _title, string memory _content) external onlyRegisteredUser {
        posts.push(Post({
            author: msg.sender,
            title: _title,
            content: _content,
            likes: 0
        }));
        emit PostCreated(posts.length - 1, msg.sender, _title, _content);
    }

    function editPost(uint256 _postId, string memory _newContent) external onlyOwner {
        posts[_postId].content = _newContent;
        emit PostEdited(_postId, _newContent);
    }

    function deletePost(uint256 _postId) external onlyOwner {
        delete posts[_postId];
        emit PostDeleted(_postId);
    }

    function getPost(uint256 _postId) external view returns (Post memory) {
        require(_postId < posts.length, "Invalid post ID");
        return posts[_postId];
    }

    function getAllPosts() external view returns (Post[] memory) {
        return posts;
    }

    function likePost(uint256 _postId) external onlyRegisteredUser {
        require(!postLikes[_postId][msg.sender], "Already liked");
        postLikes[_postId][msg.sender] = true;
        posts[_postId].likes++;
        emit PostLiked(_postId, msg.sender);
    }

    function rewardAuthors() external onlyAdmin payable {
        // Calculate rewards based on post popularity and distribute Ether to authors
        uint256 totalRewards = msg.value;
        require(totalRewards > 0, "Invalid reward amount");
        
        // Distribute rewards to authors based on their posts
        for (uint256 i = 0; i < posts.length; i++) {
            if (posts[i].author != address(0)) {
                (bool success, ) = payable(posts[i].author).call{value: totalRewards / posts.length}("");
                require(success, "Reward transfer failed");
            }
        }

        emit AuthorsRewarded(totalRewards);
    }
}
