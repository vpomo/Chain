pragma solidity >0.4.99 <0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Chain {
    using SafeMath for uint256;

    address payable public administration;

    uint public PLACE_COST = 0.2 ether;
    uint public PAYMENT_FOR_ADMIN = 0.04 ether;
    uint public PAYMENT_FOR_EACH_USER = 0.04 ether;
    uint public PAYMENT_FOR_USER = 0.24 ether;

    mapping(uint => UserStruct) public users;
    mapping(address => uint[]) public userCells;
    mapping(uint => address) public uniqueWallet;
    mapping(address => bool) public whitelist;

    uint _lastUserId = 0;
    uint _lastPaymentUserId = 0;
    uint _lastUniqueWalletId = 0;

    struct UserStruct {
        address wallet;
        uint balance;
        uint currentDate;
    }

    event Buy(uint userId, address user);
    event Withdraw(uint cellId, address user);
    event Payment(uint amount, address indexed wallet);
    event FailedPayment(uint amount, address indexed wallet);
    event AddedBalance(uint userId);
    event AddedUniqueWallet(uint id, address wallet);
    event AddWhitelist(address indexed walletUser, address indexed admin);

    modifier onlyAdmin() {
        require(msg.sender == administration, "Caller is not the administration");
        _;
    }

    modifier onlyWhitelist(){
        address _customerAddress = msg.sender;
        require(whitelist[_customerAddress]);
        _;
    }

    constructor(address payable _administration) public {
        require(_administration != address(0));
        administration = _administration;
        whitelist[_administration] = true;
        whitelist[msg.sender] = true;
    }

    // fallback function can be used to buy tokens
    function() payable external {
        uint value = msg.value;
        if (value == PLACE_COST) {
            buyChain(msg.sender);
        } else {
            sendToWallet(value, msg.sender);
        }
    }

    function buyChain(address _user) payable public {
        require(msg.value == PLACE_COST);
        _lastUserId++;
        checkUserValue(_lastUserId);
        UserStruct memory userStruct = UserStruct({
            wallet : _user,
            balance : 0,
            currentDate : now
            });
        users[_lastUserId] = userStruct;
        checkUniqueWallet(_user);
        userCells[_user].push(_lastUserId);
        checkPaymentUser();
        sendToWallet(PAYMENT_FOR_ADMIN, administration);
        emit Buy(_lastUserId, _user);
    }

    function checkUserValue(uint _userNumber) private {
        uint unit = _userNumber.div(6);
        uint remain = _userNumber % 6;
        if (remain == 0) {//6, 12
            if (_userNumber > 1) {
                addBalance(_userNumber, unit * 2, 4);
            }
        }
        if (remain == 1) {//7, 13
            if (_userNumber > 1) {
                addBalance(_userNumber, unit * 2 + 1, 4);
            }
        }
        if (remain == 2) {//8, 14
            if (_userNumber > 2) {
                addBalance(_userNumber, (unit + 1) * 2, 3);
            }
            addBalance(_userNumber, unit * 2 + 1, 1);
        }
        if (remain == 3) {//9, 15
            if (_userNumber > 3) {
                addBalance(_userNumber, (unit + 1) * 2 + 1, 2);
            }
            addBalance(_userNumber, unit * 2 + 1, 2);
        }
        if (remain == 4) {//10, 16
            if (_userNumber > 4) {
                addBalance(_userNumber, 6 + (unit - 1), 1);
            }
            addBalance(_userNumber, unit * 2 + 1, 3);
        }
        if (remain == 5) {//11, 17
            addBalance(_userNumber, unit * 2 + 1, 4);
        }
    }

    function addBalance(uint _userNumber, uint _id, uint _count) private {
        uint condition = _userNumber.sub(_id).sub(_count);
        for (uint i = _userNumber.sub(_id); i > condition; i--) {
            users[i].balance = users[i].balance.add(PAYMENT_FOR_EACH_USER);
            emit AddedBalance(i);
        }
    }

    function checkUniqueWallet(address _wallet) private {
        if (userCells[_wallet].length == 0) {
            _lastUniqueWalletId++;
            uniqueWallet[_lastUniqueWalletId] = _wallet;
            emit AddedUniqueWallet(_lastUniqueWalletId, _wallet);
        }
    }

    function checkPaymentUser() private {
        if (users[_lastPaymentUserId + 1].balance == PAYMENT_FOR_USER) {
            withdraw(_lastPaymentUserId);
            _lastPaymentUserId++;
        }
    }

    function sendToWallet(uint _amount, address _wallet) private {
        if (0 < _amount && _amount <= _balanceAll()) {
            if (address(uint160(_wallet)).send(_amount)) {
                emit Payment(_amount, _wallet);
            } else {
                emit FailedPayment(_amount, _wallet);
            }
        }
    }

    function _balanceAll() private view returns (uint) {
        return address(this).balance;
    }

    function balanceAll() onlyWhitelist public view returns (uint) {
        return _balanceAll();
    }

    function getLastUserId() onlyWhitelist public view returns (uint) {
        return _lastUserId;
    }

    function getLastPaymentUserId() onlyWhitelist public view returns (uint) {
        return _lastPaymentUserId;
    }

    function getLastUniqueWalletId() onlyWhitelist public view returns (uint) {
        return _lastUniqueWalletId;
    }

    function getUserCellsCount(address _user) onlyWhitelist public view returns (uint) {
        return userCells[_user].length;
    }

    function getUserByCellId(uint _id) onlyWhitelist public view returns (address wallet, uint currentDate, uint balance) {
        UserStruct memory userStruct = users[_id];
        wallet = userStruct.wallet;
        currentDate = userStruct.currentDate;
        balance = userStruct.balance;
    }

    function getCellIdByUserAndArrayNumber(address _user, uint _number) onlyWhitelist public view returns (uint) {
        require(getUserCellsCount(_user) > _number, "Out of bounds array");
        return userCells[_user][_number];
    }

    function withdraw(uint _id) private {
        require(PAYMENT_FOR_USER <= _balanceAll(), "Increase amount larger than balance.");
        if (users[_id].balance >= PAYMENT_FOR_USER) {
            sendToWallet(PAYMENT_FOR_USER, users[_id].wallet);
            users[_id].balance = 0;
            emit Withdraw(_id, users[_id].wallet);
        }
    }

    function setWhitelist(address _newUser, bool _status) onlyAdmin public {
        whitelist[_newUser] = _status;
        emit AddWhitelist(_newUser, msg.sender);
    }

    function adminWithdraw(uint _amount) external onlyAdmin {
        require(_amount <= _balanceAll(), "Increase amount larger than balance.");
        sendToWallet(_amount, administration);
        emit Withdraw(0, administration);
    }

    function finish() external onlyAdmin {
        selfdestruct(administration);
    }
}
