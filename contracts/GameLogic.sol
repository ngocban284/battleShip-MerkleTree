// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IGameLogic.sol";
import "./lib/merkleTree/MerkleProof.sol";
import "./interfaces/IDataSchema.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract GameLogic is IDataSchema{

    /*
    ╔══════════════════════════════╗
    
    ║           VARIABLES          ║
    
    ╚══════════════════════════════╝
    */

    mapping (ShipType => uint) shipSizes; //ship size 
    mapping (ShipType => uint[]) shipIndexes; // indexes of ships in the array
    mapping (uint8 => ShipType) shipFromIndex; // index to ship
    mapping (string => ShipPosition) shipPositionMapping; // ship positions
    uint8 sumOfShipSizes; // sum of ship sizes
    uint8 gridDimensionX; // grid demention x
    uint8 gridDimensionY; // grid demention y
    uint8 gridSquareDimension; // grid square demention


    /*
    ╔══════════════════════════════╗
    
    ║           CONTRUCTOR         ║
    
    ╚══════════════════════════════╝
    */

    constructor(
        uint8 _gridDimentionX,
        uint8 _gridDimentionY,
        uint8 _sumOfShipSizes,
        uint _destroyerShipSize,
        uint _submarineShipSize,
        uint _cruiserShipSize,
        uint _battleship,
        uint _carrier
    ){
        gridDimensionX = _gridDimentionX;
        gridDimensionY = _gridDimentionY;
        gridSquareDimension = _gridDimentionX * _gridDimentionY;
        sumOfShipSizes = _sumOfShipSizes;

        shipSizes[ShipType.Destroyer] = _destroyerShipSize;
        shipSizes[ShipType.Submarine] = _submarineShipSize;
        shipSizes[ShipType.Cruiser] = _cruiserShipSize;
        shipSizes[ShipType.Battleship] = _battleship;
        shipSizes[ShipType.Carrier] = _carrier;

        for (uint8 i = 0; i < _submarineShipSize; i++) {
            ShipType shipType = ShipType.None;
            
            if (i==0 || i==1) {

                shipType = ShipType.Destroyer;
                shipIndexes[shipType].push(i);

            }else if (i>1 && i<5) {

                shipType = ShipType.Submarine;
                shipIndexes[shipType].push(i);

            }else if(i>4 && i<8) {

                shipType = ShipType.Cruiser;
                shipIndexes[shipType].push(i);

            }else if(i>7 && i<12) {

                shipType = ShipType.Battleship;
                shipIndexes[shipType].push(i);
            }else{
                shipType = ShipType.Carrier;
                shipIndexes[shipType].push(i);
            }

            shipFromIndex[i] = shipType;
        }


        shipPositionMapping["11"] = ShipPosition(ShipType.Destroyer, AxisType.X);
        shipPositionMapping["12"] = ShipPosition(ShipType.Destroyer, AxisType.X);
        shipPositionMapping["21"] = ShipPosition(ShipType.Submarine, AxisType.X);
        shipPositionMapping["22"] = ShipPosition(ShipType.Submarine, AxisType.X);
        shipPositionMapping["31"] = ShipPosition(ShipType.Cruiser, AxisType.X);
        shipPositionMapping["32"] = ShipPosition(ShipType.Cruiser, AxisType.X);
        shipPositionMapping["41"] = ShipPosition(ShipType.Battleship, AxisType.X);
        shipPositionMapping["42"] = ShipPosition(ShipType.Battleship, AxisType.X);
        shipPositionMapping["51"] = ShipPosition(ShipType.Carrier, AxisType.X);
        shipPositionMapping["52"] = ShipPosition(ShipType.Carrier, AxisType.X);
       
    }


    /*
    ╔══════════════════════════════╗
    
    ║           FUNCTION           ║
    
    ╚══════════════════════════════╝
    */

    function getPositionOccupiedByShip( ShipType[5] memory _ship, uint8[5] memory _position,AxisType[5] memory _axis) external view returns(uint8[] memory){
        uint8[] memory combinedShipPositions = new uint8[](sumOfShipSizes);
        uint8 combinedShipPositionIndex = 0;
        uint8[] memory locationStatus;

        for (uint8 i = 0; i < _position.length; i++) {

            uint sizeOfShip = shipSizes[_ship[i]];
            uint8 startingPosition = _position[i];
            AxisType axis = _axis[i];

            uint8 incrementer = axis == AxisType.X ? 1 : gridDimensionX;
            uint8 maxTile = uint8(startingPosition + (sizeOfShip - 1) * incrementer);

            require( maxTile < gridSquareDimension, "Ship is out of bounds");

            if ( axis == AxisType.X ) {
                for (uint8 j = startingPosition; j <= maxTile; j++) {
                    uint lowerLimitFactor = (startingPosition - (startingPosition % gridDimensionX)) / gridDimensionX;
                    uint upperLimitFactor = (maxTile - (maxTile % gridDimensionX)) / gridDimensionX;
                    require (lowerLimitFactor == upperLimitFactor, "Invalid Ship placement");
                }
                
            }

            for (uint8 j = startingPosition; j <= maxTile; j++) {
                uint8 position = startingPosition + (j * incrementer);
                require(locationStatus[position] == 0, "Ships can not overlap");
                locationStatus[position] = 1;
                combinedShipPositions[combinedShipPositionIndex] = position;
                combinedShipPositionIndex++;
            }
        }

    }
    
    
}
