const BlogPost = artifacts.require("BlogPost");

module.exports = function (deployer) {
  // Deploy the BlogPost contract
  deployer.deploy(
    BlogPost,
    /* adminAddress */ "0xDE44F8Ab6593247f7827dE3006ac1c1dab49dD28"
  );
};
