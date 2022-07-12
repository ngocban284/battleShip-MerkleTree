// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IGameLogic.sol";
import "./lib/merkleTree/MerkleProof.sol";
import "./interfaces/IDataSchema.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract GameLogic is IDataSchema {

   

    /*
    ╔══════════════════════════════╗
    
    ║           VARIABLES          ║
    
    ╚══════════════════════════════╝
    */

    mapping (ShipType => uint) shipSizes; //ship size 
    mapping (ShipType => uint8[]) shipIndexes; // indexes of ships in the array
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


    function getShipTypeByIndex(uint8 _index) external view returns(ShipType){
        if (  _index < 1 || _index > 16) {
            return ShipType.None;
        }
        return shipFromIndex[_index];
    }
    
    function getShipIndexFromShipType(ShipType _shipType) external view returns(uint8[] memory){
        return shipIndexes[_shipType];
    }

     
    function getOrderedPositionAndAxis(string memory _position) external view returns(uint16[] memory,AxisType[5] memory){
        
        AxisType [5] memory axis = [ AxisType.None, AxisType.None, AxisType.None, AxisType.None, AxisType.None ];
        uint16[] memory orderedPositions = new uint16[](17);

        uint8 destroyerCount = 0;
        uint8 submarineCount = 2;
        uint8 cruiserCount = 5;
        uint8 battleshipCount = 8;
        uint8 carrierCount = 12;

        ShipPosition memory shipPosition = ShipPosition(ShipType.None, AxisType.None);
        string memory shipPositionKey = "";


        for (uint8 i = 0; i < 400; i += 4) {
            shipPositionKey = getSlice(i+1,i+2,_position);
            shipPosition = shipPositionMapping[shipPositionKey];
           

            //Destroyer
            if (shipPosition.ship == ShipType.Destroyer) {
                if ( axis[0] == AxisType.None ) {
                    axis[0] = shipPosition.axis;
                }
                orderedPositions[destroyerCount] = i/4 + 1;
                destroyerCount++;
            }

            //Shubmarine
            if (shipPosition.ship == ShipType.Submarine) {
                if ( axis[1] == AxisType.None ) {
                    axis[1] = shipPosition.axis;
                }
                orderedPositions[submarineCount] = i/4 + 1;
                submarineCount++;
            }


            //Cruiser
            if (shipPosition.ship == ShipType.Cruiser) {
                if ( axis[2] == AxisType.None ) {
                    axis[2] = shipPosition.axis;
                }
                orderedPositions[cruiserCount] = i/4 + 1;
                cruiserCount++;
            }

            //Battleship
            if (shipPosition.ship == ShipType.Battleship) {
                if ( axis[3] == AxisType.None ) {
                    axis[3] = shipPosition.axis;
                }
                orderedPositions[battleshipCount] = i/4 + 1;
                battleshipCount++;
            }

            //Carrier
            if (shipPosition.ship == ShipType.Carrier) {
                if ( axis[4] == AxisType.None ) {
                    axis[4] = shipPosition.axis;
                }
                orderedPositions[carrierCount] = i/4 + 1;
                carrierCount++;
            }
        }

        return (orderedPositions, axis);
    }

    function checkEqualArray(uint8[] memory _array1,uint8[] memory _array2) external pure returns(bool){
        if ( _array1.length != _array2.length ) {
            return false;
        }
        for (uint8 i = 0; i < _array1.length; i++) {
            if ( _array1[i] != _array2[i] ) {
                return false;
            }
        }
        return true;
    }

    function stringToBytes32(string memory source) external pure returns (bytes32 result){
        bytes memory emptyBytes =  bytes(source);

        if (emptyBytes.length == 0) {
            return 0x0;
        }
        
        assembly {
            result := mload(add(source,32))
        }
            
    }

    function bytes32ToString(bytes32 source) external pure returns (string memory result){
        if (source == 0x0) {
            return "";
        }
        assembly {
            result := mload(source)
        }
    }

    function getbytes32FromBytes(bytes memory _bytes,uint index) public pure returns (bytes32 ){
        bytes32 el;
        uint position = (index+1) * 32;

        require( position <= _bytes.length, "The value requested is not within the range of the bytes");

        assembly {
            el := mload(add(_bytes,position))
        }

        return el;
    }

    
    function getSliceOfBytesArray(uint256 _begin,uint256 _end,bytes memory _bytesArray) external pure returns(bytes memory){
        bytes memory result = new bytes(_end - _begin + 1);
   
        uint position = (_end + 1) * 32;

        require( position <= _bytesArray.length, "The value requested is not within the range of the bytes");

       
        for (uint256 i = 0; i <= _end - _begin; i++) {
            result[i] = _bytesArray[ i + _begin -1];
        }
        
        return result;
    }

    function getSlice(uint256 begin, uint256 end, string memory text) public pure returns (string memory) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = bytes(text)[i+begin-1];
        }
        return string(a);
    }

    function getShipPosition(string memory _position) external view returns(ShipPosition memory){
        return shipPositionMapping[_position];
    }

}
