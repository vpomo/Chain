var Chain = artifacts.require("./Chain.sol");

var chainContract;

var decimal = Number(1e18);
var buyOne = Number(0.2 * decimal);
var buyTwo = Number(0.4 * decimal);


contract('Chain', (accounts) => {
    var owner = accounts[0];

    it('should deployed contract Chain', async ()  => {
        assert.equal(undefined, chainContract);
        chainContract = await Chain.deployed();
        assert.notEqual(undefined, chainContract);
        //await chainContract.hghghghg();
    });

    it('get address contract Chain', async ()  => {
        assert.notEqual(undefined, chainContract.address);
    });

    it('check added balance', async ()  => {
        for (var i=1; i<16; i++) {
            console.log("i = ", i);
            await chainContract.buyChain(accounts[1], {from:accounts[1], value: buyOne});
            // var userAddress = await chainContract.users(i);
            // console.log("userAddress = ", userAddress);
        }
        await chainContract.dfdfdfd();
    });

    // it('check unique wallet', async ()  => {
    //     var count = await chainContract.getUserCellsCount(accounts[1]);
    //     console.log("count 1", Number(count));
    //     count = await chainContract.getUserCellsCount(accounts[4]);
    //     console.log("count 4", Number(count));
    //
    //     var lastUniqueWalletId = await chainContract.lastUniqueWalletId.call();
    //     console.log("lastUniqueWalletId", Number(lastUniqueWalletId));
    //     await chainContract.buyChain(accounts[2], {from:accounts[2], value: buyOne});
    //     await chainContract.buyChain(accounts[3], {from:accounts[3], value: buyOne});
    //     lastUniqueWalletId = await chainContract.lastUniqueWalletId.call();
    //     console.log("lastUniqueWalletId", Number(lastUniqueWalletId));
    // });
    //
    // it('check amount for buy', async ()  => {
    //     var balance = await chainContract.balanceAll();
    //     console.log("balance before", Number(balance));
    //     //await chainContract.buyChain(accounts[4], {from:accounts[4], value: buyTwo});
    //     balance = await chainContract.balanceAll();
    //     console.log("balance after", Number(balance));
    //     await chainContract.dfdfdfd();
    // });
    //
});

