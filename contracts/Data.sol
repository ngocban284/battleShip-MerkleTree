// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IDataSchema.sol";
import "./interfaces/IGameLogic.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Data is IDataSchema ,OwnableUpgradeable {

    IGameLogic public gameLogicAddress;
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
    address payable addressOwner; // owner of the contract
    address payable transactionOfficer; // transaction officer of the contract
    bool isTest; // is test mode

    mapping(ShipType => uint8) public shipSizes; // mapping of ship type to ship size
    mapping (uint => Battle) battles;  //The mapping of battles
    mapping (address => Player) players;  //The mapping of captains
    mapping (uint => mapping (address => mapping ( uint => bytes32) )) revealedPositions; // mapping of game id to mapping of player address to mapping of position to revealed position
    mapping (uint => mapping (address => uint8[])) positionsAttacked; // mapping of game id to mapping of player address to array of positions attacked
    mapping(uint => mapping (address => string)) encryptedMerkleTree; // mapping of game id to mapping of player address to encrypted merkle tree of the player
    mapping(uint => mapping (address => bytes32)) merkleTreeRoots; // mapping of game id to mapping of player address to merkle tree root of the player
    mapping (uint => mapping (address => uint8)) lastFiredPositionIndex; // mapping of game id to mapping of player address to last fired position
    mapping (uint => address) turns; // mapping of game id to current turn
    mapping (uint => uint) lastPlayTime; // mapping of game id to last play time
    mapping (uint => mapping (address => ShipPosition[])) correctPositionsHit; // mapping of game id to mapping of player address to array of correct positions hit
    mapping (uint => mapping (address => VerificationStatusType)) battleVerification; // each player's verification status in a match.
    mapping (uint => mapping (address => string)) revealedLeafs; // mapping of game id to mapping of player address to revealed leafs of the player
    mapping (GameModeType => Lobby) lobbyMapping; // mapping of game mode to lobby
    mapping (GameModeType => GameModeDetail) gameModeMapping; // mapping of game mode to game mode detail

     /*
    ╔══════════════════════════════╗
    
    ║           MODIFIER           ║
    
    ╚══════════════════════════════╝
    */

    modifier onlyContractOwner {
       require( msg.sender == addressOwner , "Only owner can call this function" );
        _;
    }

    modifier onlyAuthorized {
        bool isBattleShipContract = msg.sender == battleShipContract;
        require(isBattleShipContract || isTest , "Only the battle ship contract can perform this action");
        _;
    }


      /*
    ╔══════════════════════════════╗
    
    ║           CONTRUCTOR         ║
    
    ╚══════════════════════════════╝
    */

    function  initialize(
        bool _isTest,
        address _gameLogicAddress,
        uint8 _destroyerShipSize,
        uint8 _submarineShipSize,
        uint8 _cruiserShipSize,
        uint8 _battleship,
        uint8 _carrier,
        uint8 _maxNumberOfMissiles
    ) external initializer{
    
        shipSizes[ShipType.Destroyer] = _destroyerShipSize;
        shipSizes[ShipType.Submarine] = _submarineShipSize;
        shipSizes[ShipType.Cruiser] = _cruiserShipSize;
        shipSizes[ShipType.Battleship] = _battleship;
        shipSizes[ShipType.Carrier] = _carrier;
        
        gameLogicAddress = IGameLogic(_gameLogicAddress);
        addressOwner = payable(msg.sender);
        maxNumberOfMissiles = _maxNumberOfMissiles;
        isTest = _isTest;

        gameModeMapping[GameModeType.Regular] = GameModeDetail(
            minStakingAmout,
            GameModeType.Regular,
            minTimeRequiredForPlayerToRespond
        );

        gameModeMapping[GameModeType.Intermediate] = GameModeDetail(
            minStakingAmout,
            GameModeType.Intermediate,
            minTimeRequiredForPlayerToRespond
        );

        gameModeMapping[GameModeType.Professional] = GameModeDetail(
            minStakingAmout,
            GameModeType.Professional,
            minTimeRequiredForPlayerToRespond
        );

    }


      /*
    ╔══════════════════════════════╗
    
    ║           FUNCTION           ║
    
    ╚══════════════════════════════╝
    */
    
    // Battle
    function getBattle(uint256 _battleId)public view returns ( Battle memory){
        Battle memory battle = battles[_battleId];
        return battle;
    }

    function updateBattle(uint256 _battleId, Battle memory _battle)external onlyAuthorized returns(bool){
   
        _battle.updatedAt = block.timestamp;
        if (_battle.createdAt < 1) {
            _battle.createdAt = block.timestamp;
        }

        battles[_battleId] = _battle;
        return true;
    }

    function getNewBattleId() external returns(uint){
        gameId++;
        return gameId;
    }


    // Rules
    function getContractOwner() external view returns(address){
        return addressOwner;
    }

    function setBattleContractAddress(address _address) external returns(bool){
        battleShipContract = _address;
        return true;
    }

    function setGameLogicContractAddress(address _address) external returns(bool){
        gameLogicAddress = IGameLogic(_address);
        return true;
    }

    function getGameModeDetails(GameModeType _gameMode) external view returns(GameModeDetail memory){
        return gameModeMapping[_gameMode];
    }

    function setGameModeDetails(GameModeType _gameMode,GameModeDetail memory _gameModeDetails) external returns(bool){
        gameModeMapping[_gameMode] = _gameModeDetails;
        return true;
    }

    function getLobby(GameModeType  _gameMode) external view returns(Lobby memory){
        return lobbyMapping[_gameMode];
    }

    function updateLobby(GameModeType _gameMode,Lobby memory _lobby) external  returns(bool){
        lobbyMapping[_gameMode] = _lobby;
        return true;
    }



    // Player

    function getPlayer(address _playerAddress) external view returns(Player memory){
        return players[_playerAddress];
    }

    function updatePlayer(address _playerAddress, Player memory _player) external returns(bool){
        _player.updatedAt = block.timestamp;
        if(_player.createdAt < 1) _player.createdAt = block.timestamp;
        players[_playerAddress] = _player;
        return true;
    }

    //

    function getEncryptedMerkleTree(uint _battleId,address _playerAddress) external view returns(string memory){
        return encryptedMerkleTree[_battleId][_playerAddress];
    }


    function setEncryptedMerkleTree(uint _battleId,address _playerAddress,string memory _encryptedMerkleTree) external returns(bool){
        encryptedMerkleTree[_battleId][_playerAddress] = _encryptedMerkleTree;
        return true;
    }


    function getRevealedMerkleTree(uint _battleId,address _playerAddress,uint8 _position) external view returns( bytes32 ){
        return revealedPositions[_battleId][_playerAddress][_position];
    }


    function setRevealedMerkleTree(uint _battleId,address _playerAddress,uint8 _position,bytes32 _revealedPosition) external  returns(bool){
        revealedPositions[_battleId][_playerAddress][_position] = _revealedPosition;
        return true;
    }

    function getMerkleTreeRoot(uint _battleId,address _playerAddress) external view returns(bytes32){
        return merkleTreeRoots[_battleId][_playerAddress];
    }

    function setMerkleTreeRoot(uint _battleId,address _playerAddress,bytes32 _root) external returns(bool){
        merkleTreeRoots[_battleId][_playerAddress] = _root;
        return true;
    }

    function getLastFiredPosition(uint _battleId,address _playerAddress) external view returns(uint8){
        return lastFiredPositionIndex[_battleId][_playerAddress];
    }

    function setLastFiredPosition(uint _battleId,address _playerAddress,uint8 _position) external returns(bool){
        lastFiredPositionIndex[_battleId][_playerAddress] = _position;
        return true;
    }

    function getTurn(uint _battleId) external view returns(address){
        return turns[_battleId];
    }

    function setTurn(uint _battleId,address _playerAddress) external returns(bool){
        turns[_battleId] = _playerAddress;
        return true;
    }

    function getLastPlayTime(uint _battleId) external view returns(uint){
        return lastPlayTime[_battleId];
    }

    function setLastPlayTime(uint _battleId,uint _time) external returns(bool){
        lastPlayTime[_battleId] = _time;
        return true;
    }

    function getPositionAttacked(uint _battleId,address _playerAddress) external view returns(uint8[] memory){
        return positionsAttacked[_battleId][_playerAddress];
    }

    function addPositionAttacked(uint _battleId,address _playerAddress,uint8 _position) external  returns(bool){
        positionsAttacked[_battleId][_playerAddress].push(_position);
        return true;
    } 

    function getCorrectPositionHit(uint _battleId,address _playerAddress) external view returns(ShipPosition[] memory){
        return correctPositionsHit[_battleId][_playerAddress];
    }  

    function addCorrectPositionHit(uint _battleId,address _playerAddress,ShipPosition memory _ShipPosition) external returns(bool){
        correctPositionsHit[_battleId][_playerAddress].push(_ShipPosition);
        return true;
    } 

    function getVerificationStatus (uint _battleId,address _playerAddress) external view returns(VerificationStatusType){
        return battleVerification[_battleId][_playerAddress];
    }

    function setVerificationStatus (uint _battleId,address _playerAddress,VerificationStatusType _status) external returns(bool){
        battleVerification[_battleId][_playerAddress] = _status;
        return true;
    }

    function getTransactionOfficer() external view returns(address){
        return transactionOfficer;
    }

    function setTransactionOfficer(address payable _transactionOfficer) external  returns(bool){
        transactionOfficer = _transactionOfficer;
        return true;
    }

    function getRevealedLeafs(uint _battleId,address _playerAddress) external view returns(string memory){
        return revealedLeafs[_battleId][_playerAddress];
    }

    function setRevealedLeafs(uint _battleId,address _playerAddress,string memory _revealedLeafs) external  returns(bool){
        revealedLeafs[_battleId][_playerAddress] = _revealedLeafs;
        return true;
    }
}