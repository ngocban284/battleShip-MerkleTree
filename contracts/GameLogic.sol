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
    uint8 gridDementionX; // grid demention x
    uint8 gridDementionY; // grid demention y
    uint8 gridSquareDemention; // grid square demention


    /*
    ╔══════════════════════════════╗
    
    ║           CONTRUCTOR         ║
    
    ╚══════════════════════════════╝
    */

    constructor(
        uint8 _gridDementionX,
        uint8 _gridDementionY,
        uint8 _sumOfShipSizes,
        uint _destroyerShipSize,
        uint _submarineShipSize,
        uint _cruiserShipSize,
        uint _battleship,
        uint _carrier
    ){
        gridDementionX = _gridDementionX;
        gridDementionY = _gridDementionY;
        gridSquareDemention = _gridDementionX * _gridDementionY;
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
    
    
}
