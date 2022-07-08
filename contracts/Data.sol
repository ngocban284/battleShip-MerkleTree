// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IDataSchema.sol";
import "./interfaces/IGameLogic.sol";

contract Data is IDataSchema{

    IGameLogic public gameLogic;
    address battleShipContract;

    /*
    ╔══════════════════════════════╗
    
    ║           VARIABLES          ║
    
    ╚══════════════════════════════╝
    */

    uint public totalTilesRequired = 17; // host and client of tiles will be 17
    uint gameId = 0;
    uint minTimeRequiredForPlayerToRespond = 5 minutes; // min time to respond to a battle
    uint maxNumberOfMissiles ; // max number of missless turns in a battle
    uint minStakingAmout = uint( 0.001 ether ); // min amount of ether to stake in a battle
    uint totalNumberOfPlayers; // total number of players in the game
    uint rewardComissionRate; // reward comission rate
    uint canncelComissionRate; // canncel comission rate
    address[] public playerAddress; // array of player's address in the game
    address payable owner; // owner of the contract
    address payable transactionOfficer; // transaction officer of the contract
    bool isTest; // is test mode

    mapping(ShipType => uint) public shipSizes; // mapping of ship type to ship size
    mapping (uint => mapping (address => mapping ( uint => bytes32) )) revealedPositions; // mapping of game id to mapping of player address to mapping of position to revealed position
    mapping (uint => mapping (address => uint8[])) positionsAttacked; // mapping of game id to mapping of player address to array of positions attacked
    mapping(uint => mapping (address => string)) encryptedMerkleTree; // mapping of game id to mapping of player address to encrypted merkle tree of the player
    mapping(uint => mapping (address => bytes32)) merkleTreeRoot; // mapping of game id to mapping of player address to merkle tree root of the player
    mapping (uint => mapping (address => uint8)) lastFiredPositionIndex; // mapping of game id to mapping of player address to last fired position
    mapping (uint => address) turn; // mapping of game id to current turn
    mapping (uint => uint) lastPlayTime; // mapping of game id to last play time
    mapping (uint => mapping (address => ShipPosition[])) correctPositionsHit; // mapping of game id to mapping of player address to array of correct positions hit
    mapping (uint => mapping (address => VerificationStatusType[])) battleVerification; // each player's verification status in a match.
    mapping (uint => mapping (address => string)) revealedLeafs; // mapping of game id to mapping of player address to revealed leafs of the player
    mapping (GameModeType => Lobby) lobbyMapping; // mapping of game mode to lobby
    mapping (GameModeType => GameModeDetail) gameModeMapping; // mapping of game mode to game mode detail



}