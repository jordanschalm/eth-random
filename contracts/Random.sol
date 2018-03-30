pragma solidity ^0.4.18;

// Contract Random implements two-phase secure random number generation, meant
// to be used by contracts wishing to enforce strong randomness guarantees for
// users of the calling contract. If the calling contract is untrusted, this
// contract provides no security. The security of this RNG method depends on
// the calling contract:
// (a) enforcing that promise IDs are not manipulated between creation and use
// (b) enforcing that promise IDs must be used before another is created for
//     the same operation.
contract Random {

    // Caller => ID => block number.
    // Including the address prevents overwriting promises.
    mapping (address => mapping (uint256 => uint256)) private promiseIdToBlockNumber;

    // Creates a new promise, that can be used `waitBlocks` blocks after this
    // function is called. The caller can provide an ID, which should be unique
    // within the caller's "promise space" otherwise it will overwrite an
    // exising promise. It is up to the caller to prevent ID collisions.
    function getPromise(uint256 waitBlocks, uint256 id) public {
        // Must wait at least 10 blocks into the future
        require(waitBlocks > 10);

        // Commit the promise to the future block. The fact that we commit to
        // the block number before it arrives is where the security comes from.
        promiseIdToBlockNumber[msg.sender][id] = block.number + waitBlocks;
    }

    // Uses a created promise to retrieve a random value.
    function usePromise(uint256 id) public view returns (bytes32) {
        uint256 promiseBlock = promiseIdToBlockNumber[msg.sender][id];

        // Make sure block has been mined
        require(promiseBlock < block.number);
        // Make sure block hash is still accessible
        require(promiseBlock >= _safeSub(block.number, 256));

        // Retrieve and return the random value
        return block.blockhash(promiseBlock);
    }

    // Subtract two numbers, returning 0 rather than overflowing.
    function _safeSub(uint256 a, uint256 b) private pure returns (uint256) {
        if (a > b) {
            return a - b;
        }
        return 0;
    }
}
