// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IDataSchema.sol";

interface IData is IDataSchema {
    

    // Battle
    function getBattle(uint256 _battleId)external view returns ( Battle memory);
    function updateBattle(uint256 _battleId, Battle memory _battle)external returns(bool);
    function getNewBattleId() external returns(uint);


    // Rules
    function getContractOwner() external view returns(address);
    function setBattleContractAddress(address _address) external returns(bool);
    function setGameLogicContractAddress(address _address) external returns(bool);
    function getGameModeDetails(GameModeType _gameMode) external view returns(GameModeDetail memory);
    function setGameModeDetails(GameModeType _gameMode,GameModeDetail memory _gameModeDetails) external returns(bool);
    function getLobby(GameModeType _gameMode) external view returns(Lobby memory);
    function updateLobby(GameModeType _gameMode,Lobby memory _lobby) external  returns(bool);


    // Player
    function getPlayer(address _playerAddress) external view returns(Player memory);
    function updatePlayer(address _playerAddress, Player memory _player) external returns(bool);

    // 
    function getEncryptedMerkleTree(uint _battleId,address _playerAddress) external view returns(string memory);
    function setEncryptedMerkleTree(uint _battleId,address _playerAddress,string memory _encryptedMerkleTree) external returns(bool);

    //
    function getRevealedMerkleTree(uint _battleId,address _playerAddress,uint8 _position) external view returns( bytes32 );
    function setRevealedMerkleTree(uint _battleId,address _playerAddress,uint8 _position,bytes32 _revealedPosition) external  returns(bool);

    //
    function getMerkleTreeRoot(uint _battleId,address _playerAddress) external view returns(bytes32);
    function setMerkleTreeRoot(uint _battleId,address _playerAddress,bytes32 _root) external returns(bool);

    //
    function getLastFiredPosition(uint _battleId,address _playerAddress) external view returns(uint8);
    function setLastFiredPosition(uint _battleId,address _playerAddress,uint8 _position) external returns(bool);

    //
    function getTurn(uint _battleId) external view returns(address);
    function setTurn(uint _battleId,address _playerAddress) external returns(bool);

    // 
    function getLastPlayTime(uint _battleId) external view returns(uint);
    function setLastPlayTime(uint _battleId,uint _time) external returns(bool);

    //
    function getPositionAttacked(uint _battleId,address _playerAddress) external view returns(uint8);
    function addPositionAttacked(uint _battleId,address _playerAddress,uint8 _position) external  returns(bool);

    //
    function getCorrectPositionHit(uint _battleId,address _playerAddress) external view returns(ShipPosition[] memory);
    function addCorrectPositionHit(uint _battleId,address _playerAddress,ShipPosition memory _ShipPosition) external returns(bool);

    //
    function getVerificationStatus (uint _battleId,address _playerAddress) external view returns(VerificationStatusType);
    function setVerificationStatus (uint _battleId,address _playerAddress,VerificationStatusType _status) external returns(bool);

    //
    function getTransactionOfficer() external view returns(address);
    function setTransactionOfficer(address payable _transactionOfficer) external  returns(bool);

    //
    function getRevealedLeafs(uint _battleId,address _playerAddress) external view returns(string memory);
    function setRevealedLeafs(uint _battleId,address _playerAddress,string memory _revealedLeafs) external  returns(bool);
}