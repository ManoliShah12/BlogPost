// Update the contract import to match actual contract name and location
import contract from "../build/contracts/BlogPost.json";

web3.eth.defaultAccount = web3.eth.accounts[0];
const blogPostContract = new web3.eth.Contract(
  contract.abi,
  "0xDE44F8Ab6593247f7827dE3006ac1c1dab49dD28"
);

// Function to create a post
async function createPost() {
  const postTitle = document.getElementById("postTitle").value;
  const postContent = document.getElementById("postContent").value;

  if (postTitle.trim() === "" || postContent.trim() === "") {
    alert("Post title and content cannot be empty");
    return;
  }

  const accounts = await web3.eth.getAccounts();
  await blogPostContract.methods
    .createPost(postTitle, postContent)
    .send({ from: accounts[0] });
  loadPosts();
}

// Function to like a post
async function likePost() {
  const postId = prompt("Enter post ID to like:");

  const accounts = await web3.eth.getAccounts();
  await blogPostContract.methods.likePost(postId).send({ from: accounts[0] });
  loadPosts();
}

// Function to comment on a post
async function commentPost() {
  const postId = prompt("Enter post ID to comment on:");
  const comment = prompt("Enter your comment:");

  const accounts = await web3.eth.getAccounts();
  await blogPostContract.methods
    .commentPost(postId, comment)
    .send({ from: accounts[0] });
  loadPosts();
}

// Function to load and display posts
async function loadPosts() {
  const postsList = document.getElementById("postsList");
  postsList.innerHTML = "";

  const posts = await blogPostContract.methods.getAllPosts().call();

  posts.forEach((post) => {
    const postElement = document.createElement("div");
    postElement.innerHTML = `<strong>${post.title}</strong><br>${post.content}<br>Likes: ${post.likes}<br>Comments: ${post.comments}<br><hr>`;
    postsList.appendChild(postElement);
  });
}
window.onload = async function () {
  // Display blog section
  document.getElementById("blogSection").style.display = "block";
  await loadPosts();
};
