document.addEventListener("DOMContentLoaded", async ()=>{
    await initWeb3();
    await displayPosts();
});
let contractInstance;
let currentAccount;
async function initWeb3() {
    if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        try {
            await ethereum.enable();
            const accounts = await web3.eth.getAccounts();
            currentAccount = accounts[0];
        } catch (error) {
            console.error("User denied account access");
        }
    } else if (window.web3) window.web3 = new Web3(web3.currentProvider);
    else console.error("No Ethereum provider detected");
    const networkId = await web3.eth.net.getId();
    const deployedNetwork = BlogPost.networks[networkId];
    if (deployedNetwork) contractInstance = new web3.eth.Contract(BlogPost.abi, deployedNetwork.address);
    else console.error("Contract not deployed on the current network");
}
async function displayPosts() {
    const postsContainer = document.getElementById("postsContainer");
    const posts = await contractInstance.methods.getAllPosts().call();
    posts.forEach((post)=>{
        const postElement = document.createElement("div");
        postElement.innerHTML = `
            <div class="card mt-3">
                <div class="card-body">
                    <h5 class="card-title">${post.title}</h5>
                    <p class="card-text">${post.content}</p>
                    <p class="card-text">Likes: ${post.likes}</p>
                    <button class="btn btn-primary" onclick="likePost(${post.id})">Like</button>
                </div>
            </div>
        `;
        postsContainer.appendChild(postElement);
    });
}
async function createPost() {
    const postTitle = document.getElementById("postTitle").value;
    const postContent = document.getElementById("postContent").value;
    await contractInstance.methods.createPost(postTitle, postContent).send({
        from: currentAccount
    });
    // Refresh posts after creating a new post
    document.getElementById("postsContainer").innerHTML = "";
    await displayPosts();
}
async function likePost(postId) {
    const postIdInput = document.getElementById("postId");
    const selectedPostId = postId || postIdInput.value;
    await contractInstance.methods.likePost(selectedPostId).send({
        from: currentAccount
    });
    // Refresh posts after liking a post
    document.getElementById("postsContainer").innerHTML = "";
    await displayPosts();
}

//# sourceMappingURL=index.c36f364e.js.map
