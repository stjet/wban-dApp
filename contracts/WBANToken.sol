// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/BEP20.sol";

contract WBANToken is BEP20("Wrapped Banano", "wBAN") {
    mapping (address => uint256) private _bnbBalances;

    /**
     * @dev Creates `amount` tokens and assigns them to `recipient`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `recipient` must have deposited enough BNB through `bnbDeposit`
     */
    function mintTo(address recipient, uint256 amount, uint256 gaslimit) public onlyOwner {
        require(gaslimit > 0, "Gas limit can't be zero");
        // check if recipient has deposited enough BNB to cover for gas costs
        uint256 _gasCost = gaslimit * tx.gasprice;
        require(_bnbBalances[recipient] > _gasCost, "Insufficient BNB deposited");
        // enough BNB were deposited, let's mint!
        _bnbBalances[recipient] = _bnbBalances[recipient].sub(_gasCost);
        _mint(recipient, amount);
        emit Fee(recipient, _gasCost);
    }

    /**
     * @dev Keep track of users BNB deposits in order to pay for later owner initiated transactions.
     */
    function bnbDeposit() external payable {
        _bnbBalances[_msgSender()] = _bnbBalances[_msgSender()].add(msg.value);
        // solhint-disable-next-line indent
        payable(owner()).transfer(msg.value);
        emit BNBDeposit(_msgSender(), msg.value);
    }

    /**
     * @dev Returns the amount of BNB deposited in order to pay for owner initiated transactions.
     */
    function bnbBalanceOf(address account) external view returns (uint256) {
        return _bnbBalances[account];
    }

    /**
     * @dev Emitted when `value` BNB are deposited.
     */
    event BNBDeposit(address indexed from, uint256 value);

    /**
     * @dev Emitted when a fee is needed from `bnbBalance` in order to compensate
     * 			for owner transactions costs on behalf of the user
     */
    event Fee(address indexed from, uint256 value);

}
