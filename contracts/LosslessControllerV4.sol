// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

import "./interfaces/ILosslessERC20.sol";
import "./interfaces/ILosslessController.sol";

/// @title Lossless Controller Contract
/// @notice The controller contract is in charge of the communication and senstive data among all Lossless Environment Smart Contracts
contract LosslessControllerV4 is ILssController, Context {
    // IMPORTANT!: For future reference, when adding new variables for following versions of the controller. 
    // All the previous ones should be kept in place and not change locations, types or names.
    // If thye're modified this would cause issues with the memory slots.

    address override public admin;
    address override public recoveryAdmin;

    // --- V3 VARIABLES ---

    mapping(address => bool) override public whitelist;
    mapping(address => bool) override public blacklist;

    // --- MODIFIERS ---

    /// @notice Avoids execution from other than the Recovery Admin
    modifier onlyRecoveryAdmin() {
        require(msg.sender == recoveryAdmin, "LSS: Must be recoveryAdmin");
        _;
    }

    /// @notice Avoids execution from other than the Lossless Admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "LSS: Must be admin");
        _;
    }


    // --- ADMINISTRATION ---

    /// @notice This function sets a new admin
    /// @dev Only can be called by the Recovery admin
    /// @param _newAdmin Address corresponding to the new Lossless Admin
    function setAdmin(address _newAdmin) override public onlyRecoveryAdmin {
        require(_newAdmin != address(0), "LERC20: Cannot set same address");
        emit AdminChange(_newAdmin);
        admin = _newAdmin;
    }

    /// @notice This function sets a new recovery admin
    /// @dev Only can be called by the previous Recovery admin
    /// @param _newRecoveryAdmin Address corresponding to the new Lossless Recovery Admin
    function setRecoveryAdmin(address _newRecoveryAdmin) override public onlyRecoveryAdmin {
        require(_newRecoveryAdmin != address(0), "LERC20: Cannot set same address");
        emit RecoveryAdminChange(_newRecoveryAdmin);
        recoveryAdmin = _newRecoveryAdmin;
    }

    // --- V3 SETTERS ---

    /// @notice This function removes or adds an array of addresses from the whitelst
    /// @dev Only can be called by the Lossless Admin, only Lossless addresses 
    /// @param _addrList List of addresses to add or remove
    /// @param _value True if the addresses are being added, false if removed
    function setWhitelist(address[] calldata _addrList, bool _value) override public onlyAdmin {
        for(uint256 i = 0; i < _addrList.length;) {
            address adr = _addrList[i];
            whitelist[adr] = _value;
            unchecked {i++;}
        }
    }

    /// @notice This function removes or adds an array of addresses from the whitelst
    /// @dev Only can be called by the Lossless Admin, only Lossless addresses
    /// @param _addrList List of addresses to add or remove
    /// @param _value True if the addresses are being added, false if removed
    function setBlacklist(address[] calldata _addrList, bool _value) override public onlyAdmin {
        for(uint256 i = 0; i < _addrList.length;) {
            address adr = _addrList[i];
            blacklist[adr] = _value;
            unchecked {i++;}
        }
    }
    // --- BEFORE HOOKS ---

    /// @notice If address is protected, transfer validation rules have to be run inside the strategy.
    /// @dev isTransferAllowed reverts in case transfer can not be done by the defined rules.
    function beforeTransfer(address _sender, address _recipient, uint256 _amount) override external {
        if (!whitelist[_sender]) {
            require(!blacklist[_recipient], "LSS: _recipient is blacklisted");
        }
    }

    /// @notice If address is protected, transfer validation rules have to be run inside the strategy.
    /// @dev isTransferAllowed reverts in case transfer can not be done by the defined rules.
    function beforeTransferFrom(address _msgSender, address _sender, address _recipient, uint256 _amount) override external {
        if (!whitelist[_sender]) {
            require(!blacklist[_recipient], "LSS: _recipient is blacklisted");
        }
    }

    // The following before hooks are in place as a placeholder for future products.
    // Also to preserve legacy LERC20 compatibility

    function beforeMint(address _to, uint256 _amount) override external {}

    function beforeBurn(address _account, uint256 _amount) override external {}

    function beforeApprove(address _sender, address _spender, uint256 _amount) override external {}

    function beforeIncreaseAllowance(address _msgSender, address _spender, uint256 _addedValue) override external {}

    function beforeDecreaseAllowance(address _msgSender, address _spender, uint256 _subtractedValue) override external {}


    // --- AFTER HOOKS ---
    // * After hooks are deprecated in LERC20 but we have to keep them
    //   here in order to support legacy LERC20.

    function afterMint(address _to, uint256 _amount) external {}

    function afterApprove(address _sender, address _spender, uint256 _amount) external {}

    function afterBurn(address _account, uint256 _amount) external {}

    function afterTransfer(address _sender, address _recipient, uint256 _amount) override external {}

    function afterTransferFrom(address _msgSender, address _sender, address _recipient, uint256 _amount) external {}

    function afterIncreaseAllowance(address _sender, address _spender, uint256 _addedValue) external {}

    function afterDecreaseAllowance(address _sender, address _spender, uint256 _subtractedValue) external {}
}