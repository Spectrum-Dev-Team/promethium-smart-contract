// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./DataTypes.sol";
import "./interfaces/IPriceRouter.sol";
import "./RBAC.sol";

contract Registry is RBAC {
    uint256 public ITOKENS_AMOUNT_LIMIT = 12;
    address[] public positions;
    address[] public iTokens;

    IPriceRouter public router;
    mapping(address => bool) public isAdaptorSetup;

    event PositionAdded(address position, address admin);
    event ITokenAdded(address token, address admin);
    event PositionRemoved(address position, address admin);
    event ITokenRemoved(address position, address admin);

    constructor(address _priceRouter) {
        router = IPriceRouter(_priceRouter);
    }

    function getPositions() public view returns (address[] memory) {
        return positions;
    }

    function getITokens() public view returns (address[] memory) {
        return iTokens;
    }

    function addPosition(address position) public onlyOwner {
        require(!isAdaptorSetup[position], "Already added");

        positions.push(position);
        isAdaptorSetup[position] = true;

        emit PositionAdded(position, msg.sender);
    }

    function removePosition(uint256 index) public onlyOwner {
        address positionAddress = positions[index];
        isAdaptorSetup[positionAddress] = false;
        for (uint256 i = index; i < positions.length - 1; i++) {
            positions[i] = positions[i + 1];
        }
        positions.pop();

        emit PositionRemoved(positionAddress, msg.sender);
    }

    function addIToken(address token) public onlyOwner {
        require(!isAdaptorSetup[token], "Already added");

        IERC20(token).balanceOf(address(this));

        iTokens.push(token);
        isAdaptorSetup[token] = true;

        emit ITokenAdded(token, msg.sender);
    }

    function removeIToken(uint256 index) public onlyOwner {
        require(iTokens.length < ITOKENS_AMOUNT_LIMIT, "iTokens limit amount exceeded");
        address positionAddress = positions[index];
        require(IERC20(positionAddress).balanceOf(address(this)) == 0, "Itoken balance should be 0.");
        isAdaptorSetup[positionAddress] = false;

        for (uint256 i = index; i < iTokens.length - 1; i++) {
            iTokens[i] = iTokens[i + 1];
        }
        iTokens.pop();

        emit ITokenRemoved(positionAddress, msg.sender);
    }
}
