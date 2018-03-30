require("babel-polyfill");

const util = require("./util");

const Random = artifacts.require("./Random.sol");

contract("Random", function(accounts) {
  const u = accounts[0];
  let C;

  const deploy = async function() {
    C = await Random.new();
  };

  beforeEach(deploy);

  it("should work", async function() {
    await C.getPromise(15, 1, { from: u });
    await util.mineNBlocks(20);
    const val = await C.usePromise(1, { from: u });
    console.log("Nice entropy: ", val);
  });
});
