var adrressContractMain=   "0x587797388e99f63c31cf357d9b06157a2ee1f83d";
var adrressContractRopsten="0x40acC4f11e9aE693477923993AbF99C1Fdd4DE76";
var adrressContractKovan=  "0x40acC4f11e9aE693477923993AbF99C1Fdd4DE76";

var contractController;
var decimal = 10e18;
var lastPaymentId = 0;
var wallet;

window.addEventListener('load', function () {
    if (typeof web3 !== 'undefined') {
        console.log("Web3 detected!");
        window.web3 = new Web3(web3.currentProvider);
		ethereum.enable(function(error, data){
				console.log("ethereum.enable", data);
		});
        // Now you can start your app & access web3 freely:
        var currentNetwork = web3.version.network;
        web3.eth.getAccounts(function(error, data){
            var accounts = data;
            wallet = accounts[0];
            console.log("wallet", wallet);
            $('#myAddress').html(wallet);
            initContracts();
        });
    } else {
        console.log("Please use Chrome or Firefox, install the Metamask extension and retry the request!");
        $('#noweb3message').show();
    }
})

function startApp() {
    contractController.administration(function (error, data) {
        console.log("contractAdmin", data);
        $('#contractAdmin').html(data);
    });

    contractController.balanceAll(function (error, data) {
        $('#contractBalance').html(Number(data)*10/decimal);
    });
    contractController.getLastUserId(function (error, data) {
        var lastUserId = Number(data);
        $('#lastUserId').html(lastUserId);
        contractController.getUserByCellId(lastUserId, function (error, data) {
            if (data[0] === "0x0000000000000000000000000000000000000000" || data[0] === "0x") {
                $('#contractLastStake').html("Нет ставок");
            } else {
                $('#contractLastStake').html(timeConverter(data[1]));
            }
        });
    });
    contractController.getLastPaymentUserId(function (error, data) {
        var lastPaymentUserId = Number(data);
        if (lastPaymentUserId === 0) {
            $('#lastPaymentUserId').html(lastPaymentUserId);
        } else {
            $('#lastPaymentUserId').html(lastPaymentUserId-1);
        }
    });

    contractController.getLastUniqueWalletId(function (error, data) {
        $('#lastUniqueWalletId').html(Number(data));
    });

    contractController.getLastUniqueWalletId(function (error, count) {
        var countWallet = Number(count);
        var x1 = 0;
        var x2 = 0;
        var x3 = 0;
        var x4 = 0;
        var x5 = 0;
        var x6 = 0;
        for(var i=0; i< countWallet; i++) {
            contractController.uniqueWallet((i+1), function (error, wallet) {
                contractController.getUserCellsCount(wallet, function (error, cellsCount) {
                    var stakes = Number(cellsCount);
                    if (stakes === 1) {
                        x1 = x1 + 1;
                    }
                    if (stakes === 2) {
                        x2 = x2 + 1;
                    }
                    if (stakes === 3) {
                        x3 = x3 + 1;
                    }
                    if (stakes === 4) {
                        x4 = x4 + 1;
                    }
                    if (stakes === 5) {
                        x5 = x5 + 1;
                    }
                    if (stakes > 5) {
                        x6 = x6 + 1;
                    }
                    $('#oneStake').html(Number(x1));
                    $('#twoStake').html(Number(x2));
                    $('#threeStake').html(Number(x3));
                    $('#forStake').html(Number(x4));
                    $('#fiveStake').html(Number(x5));
                    $('#overStake').html(Number(x6));
                });
            });

        }
    });
}

function viewCell() {
    $('#cellData').show();
    var cellId = Number($('#cellId').val());
    contractController.getUserByCellId(cellId, function (error, data) {
        console.log("viewCell", JSON.stringify(data));
        if (data === null || data[0] === "0x0000000000000000000000000000000000000000" || data[0] === "0x") {
            $('#cellData').hide();
        } else {
            $('#cellWallet').html(data[0]);
            $('#cellDate').html(timeConverter(data[1]));
            $('#cellBalance').html(Number(data[2])*10/decimal);
        }
    });
}

function withdraw() {
    console.log("amount value", Number($('#withdrawEth').val()));
    var amount = Number($('#withdrawEth').val())*decimal/10;
    console.log("amount with decimal", amount);
    if(amount >0) {
        contractController.adminWithdraw(amount, function (error, data) {
        });
    }
}

function destruct() {
    contractController.finish(function (error, data) {
    });
}

function initContracts() {
    var addressContractController = {
        "1": adrressContractMain,
        "3": adrressContractRopsten,
        "42": adrressContractKovan
    }

    var current_network = web3.version.network;
    console.log("current_network", current_network);
    var myWalletAddress = web3.eth.accounts[0];
    if (myWalletAddress == undefined) {
        console.log("Your wallet is closed!");
    }

    $('#userWalletForAdministration').html(myWalletAddress);
    $('#userWalletForOwner').html(myWalletAddress);
    $('#contractAddress').html(addressContractController[current_network]);
    var htmlValue;
    if (current_network === '3') {
        htmlValue = '<a href="https://ropsten.etherscan.io/address/' + adrressContractRopsten + '"' + '>' + adrressContractRopsten + ' </a>';
    }
    if (current_network === '42') {
        htmlValue = '<a href="https://kovan.etherscan.io/address/' + adrressContractKovan + '"' + '>' + adrressContractKovan + ' </a>';
    }
    if (current_network === '1') {
        htmlValue = '<a href="https://etherscan.io/address/' + adrressContractMain + '"' + '>' + adrressContractMain + ' </a>';
    }
   console.log("htmlValue", htmlValue);

    $('#contractAddressLink').html(htmlValue);

    $.ajax({
        url: 'abi.txt',
        dataType: 'json',

        success: function (data) {
            var abiContractController = data;
            contractController = web3.eth.contract(abiContractController).at(addressContractController[current_network]);
            startApp();
        }
    });

}

function timeConverter(UNIX_timestamp) {
    if (UNIX_timestamp === 0) {
        return "";
    }
    var a = new Date(UNIX_timestamp * 1000);
    // var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
    var year = a.getFullYear();
    var month = months[a.getMonth()];
    var date = a.getDate();
    var hour = a.getHours();
    var min = a.getMinutes();
    var sec = a.getSeconds();
    var time = date + '/' + month + '/' + year + '/' + hour + ':' + min + ':' + sec;
    return time;
}

