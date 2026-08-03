// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV2Router {
    function addLiquidity(
        address tokenA, address tokenB,
        uint amountADesired, uint amountBDesired,
        uint amountAMin, uint amountBMin,
        address to, uint deadline
    ) external payable returns (uint amountA, uint amountB, uint liquidity);
    function WETH() external pure returns (address);
}

contract PenniesCheq {
    string public constant name = "PENNIES CHEQ";
    string public constant symbol = "✓";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1_000_000_000_000_000 * 10**18;   // 1000 trillion
    uint256 public constant BURN_FEE = 100;                         // 1%

    address public owner;
    IUniswapV2Router public router;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() { require(msg.sender == owner); _; }

    constructor(address _router) {
        owner = msg.sender;
        router = IUniswapV2Router(_router);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from zero");
        require(to != address(0), "ERC20: transfer to zero");
        require(balanceOf[from] >= amount, "ERC20: insufficient balance");

        uint256 burnAmount = (amount * BURN_FEE) / 10000;
        uint256 sendAmount = amount - burnAmount;

        balanceOf[from] -= amount;
        totalSupply -= burnAmount;
        balanceOf[to] += sendAmount;

        emit Transfer(from, to, sendAmount);
        if (burnAmount > 0) {
            emit Transfer(from, address(0), burnAmount);
        }
    }

    function addLiquidity(uint tokenAmount, uint ethAmount) external onlyOwner {
        approve(address(router), tokenAmount);
        router.addLiquidity{value: ethAmount}(
            address(this), router.WETH(),
            tokenAmount, ethAmount,
            0, 0, msg.sender, block.timestamp
        );
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }
}
