// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IDataSchema.sol";

interface IGameLogic is IDataSchema {
    
   function getPositionOccupiedByShip( ShipType[5] memory _ship, uint8[5] memory _position,AxisType[5] memory _axis) external view returns(uint8[] memory);
   function getShipTypeByIndex(uint8 _index) external view returns(ShipType);
   function getShipIndexFromShipType(ShipType _shipType) external view returns(uint8);
   function getOccupiedPositionAndAxis(string memory _position) external pure returns(uint8[] memory,AxisType[5] memory);
   function checkEqualArray(uint8[] memory _array1,uint8[] memory _array2) external pure returns(bool);
   function getSlice(uint256 _begin,uint256 _end,string memory _text) external pure returns(string memory);
   function getSliceOfBytesArray(uint256 _begin,uint256 _end,bytes memory _bytesArray) external pure returns(bytes memory);
   function getShipPosition(string memory _position) external pure returns(ShipPosition memory);
}
    
