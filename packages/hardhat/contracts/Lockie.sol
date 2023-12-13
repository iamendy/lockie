// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

//import "@openzeppelin/contracts@3.1.0/token/ERC20/ERC20.sol";
import "contracts/IERC20.sol";
import "@openzeppelin/contracts@3.1.0/access/Ownable.sol";
import "./ILendingPool.sol";

contract Lockie is Ownable {
    address public cusdAddress = 0x765DE816845861e75A25fCA122bb6898B8B1282a; //cUSD
    address public moola = 0x970b12522CA9b4054807a2c5B736149a5BE6f670; //moola lending pool
    address public mcusdAddress = 0x918146359264C492BD6934071c6Bd31C854EDBc3; //interest token

    //address public cusdAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1; //cUSD test

    enum LockStatus {
        INACTIVE,
        ACTIVE
    }

    uint256 lockPenaltyFee = 1; //1%

    struct LockAccount {
        uint256 balance;
        LockStatus status;
        uint256 createdAt;
        uint256 expiresAt;
    }

    struct Lock {
        uint256 amount;
        uint256 duration;
    }

    struct Save {
        address owner;
        uint256 amount;
        string rate;
        uint256 createdAt;
    }

    //tracks all user's succesful savings
    mapping(address => Save[]) public savings;

    //tracks all users account balance
    mapping(address => uint256) public balances;

    //tracks all users active piggy
    mapping(address => LockAccount) lockRecords;

    //tracks all user's succesful piggy
    mapping(address => Lock[]) lockHistory;

     //--- Piggy Events ---//
    event LockCreated(
        address indexed owner,
        uint256 amount,
        uint256 indexed createdAt,
        uint256 expiresAt
    );

    event LockUpdated(uint256 amount, uint256 updatedAt);

    event LockBroken(address indexed owner, uint256 saved, uint256 expiredAt);

    //---- Earning events ----//
    event Saved(
        address indexed owner,
        uint256 amount,
        string indexed rate,
        uint256 indexed createdAt
    );

    event Withdrawn(address indexed owner, uint256 amount, uint256 createdAt);

    //----- Lock functions -----//

    //create piggy (token Lock)
    function createPiggy(uint256 _amount, uint256 _duration) external {
        require(_amount > 0 && _duration > 0, "Invalid values");

        //transfer cUSD to contract
        IERC20(cusdAddress).transferFrom(msg.sender, address(this), _amount);

        //uint256 expiresAt = block.timestamp + (_duration * 86400); //convert to days

        //set an active record
        lockRecords[msg.sender] = LockAccount({
            balance: _amount,
            status: LockStatus.ACTIVE,
            createdAt: block.timestamp,
            expiresAt: block.timestamp + 60
            //expiresAt: _duration
        });

        emit LockCreated(msg.sender, _amount, _duration, block.timestamp);
    }

    //update piggy balance
    function updateBalance(uint256 _amount) external {
        require(
            lockRecords[msg.sender].status == LockStatus.ACTIVE,
            "Piggy is not ACTIVE"
        );
        require(_amount > 0, "Invalid amount");

        //transfer USDC to contract
        IERC20(cusdAddress).transferFrom(msg.sender, address(this), _amount);
        //update record
        lockRecords[msg.sender].balance += _amount;

        emit LockUpdated(_amount, block.timestamp);
    }


    //break record
    function breakPiggy() external {
        LockAccount memory account = lockRecords[msg.sender];

        require(account.status == LockStatus.ACTIVE, "No record");

        //penalize if broken before duration
        if (block.timestamp < (account.expiresAt)) {
            uint256 penaltyBalance = account.balance -
                ((lockPenaltyFee * account.balance) / 100);

            IERC20(cusdAddress).transfer(msg.sender, penaltyBalance);
        } else {
            //send to user
            IERC20(cusdAddress).transfer(msg.sender, account.balance);
            //push to history
            Lock memory lock = Lock({
                amount: account.balance,
                duration: account.expiresAt - account.createdAt
            });

            lockHistory[msg.sender].push(lock);
        }

        //reset record
        account.balance = 0;
        account.createdAt = 0;
        account.expiresAt = 0;
        account.status = LockStatus.INACTIVE;

        lockRecords[msg.sender] = account;
        emit LockBroken(msg.sender, account.balance, block.timestamp);
    }

    //get user's piggy history
    function getHistory(address _owner)
        external
        view
        returns (Lock[] memory)
    {
        return lockHistory[_owner];
    }

    //get piggie record
    function getRecord(address _owner) external view returns (LockAccount memory) {
        return lockRecords[_owner];
    }

    //checks if a user has an active Piggy
    function isActive(address _owner) external view returns (bool) {
        uint256 status = uint256(lockRecords[_owner].status);
        return status > 0 ? true : false;
    }

    
    //----- Earn functions -----//
    function deposit(uint256 _amount, string calldata _rate) external {
        require(_amount > 0, "Invalid values");

        //calculate charge
        //uint256 balanceAfterCharge = _amount - deductCharge(_amount);

        //get the fund
        IERC20(cusdAddress).transferFrom(msg.sender, address(this), _amount);

        //approve Moola
        IERC20(cusdAddress).approve(moola, _amount);

        //lend balance on Moola onbehalf of the user
        ILendingPool(moola).deposit(
            cusdAddress,
            _amount,
            msg.sender,
            0
        );

        //save details
        savings[msg.sender].push(
            Save({
                owner: msg.sender,
                amount: _amount,
                rate: _rate,
                createdAt: block.timestamp
            })
        );

        //update balance record
        balances[msg.sender] += _amount;

        emit Saved(msg.sender, _amount, _rate, block.timestamp);
    }

    function deductCharge(uint256 _amount) internal pure returns (uint256) {
        uint256 fee = _amount / 100; // 1%

        return fee;
    }

    //get rate for calculating APY
    function getRate() external view returns (DataTypes.ReserveData memory) {
        DataTypes.ReserveData memory state = ILendingPool(moola).getReserveData(
            cusdAddress
        );
        return state;
    }

    function getSavingsBal(address _user) external view returns (uint256 bal) {
        return balances[_user];
    }

    function getSavings(address _owner) external view returns (Save[] memory) {
        return savings[_owner];
    }

    //recover service charge
    function withdrawCharges() external onlyOwner {
        IERC20(cusdAddress).transfer(
            owner(),
            IERC20(cusdAddress).balanceOf(address(this))
        );
    }
}
