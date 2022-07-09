// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDataSchema {
   
    enum PlayerType {
        None,
        Host,
        Client
    }

    enum ShipType {
        None,
        Destroyer,
        Submarine,
        Cruiser,
        Battleship,
        Carrier
    }

    enum AxisType {
        None,
        X,
        Y
    }

    enum GameModeType{
        None,
        Regular,
        Intermediate,
        Professional
    }

    enum VerificationStatusType{
        None,
        Verified,
        Unverified,
        Cheated
    }


    struct Battle{
        uint staked;    // how much ethers staked for this battle
        uint claimTime;   // when the reward is claimed
        uint createdAt;    // when the battle is created
        uint updatedAt;   // when the battle is updated
        uint startTime;    // when the battle starts
        uint maxTimeForPlayerDelay; // max time player can delay
        address host;      // who is the host of this battle
        address client;    // who is the client of this battle
        address turn;      // who is the next turn
        address winner;    // who is the winner
        GameModeType gameMode; // game mode of this battle
        bool isFinished;   // is the battle finished
        bool isRewardClaimed;   // is the reward claimed
        bool leafVerificationPassed;    //Determines if the winner Of the battle has passed the Leaf Verification Test
        bool shipPositionVerificationPassed;    //Determines if the winner has passed the ship position verification Test
    }

    struct Player{
        string name;    // name of the player
        uint matchesPlayed;   // how many matches played
        uint wins;    // how many wins
        uint losses;   // how many losses
        uint numberOfGameHosted;  // how many games are hosted by this player
        uint numberOfGameJoined;  // how many games are joined by this player
        uint totalStaking;   // total staked by this player
        uint totalEarning;   // total earning by this player
        uint createdAt;    // when the player is created
        uint updatedAt;   // when the player is updated
        bool isVerified;  // indicates whether or not the account of the captain has been set up
    }

    struct GameModeDetail{
        uint stake;    // how much ethers staked for this battle
        GameModeType gameMode; // game mode of this battle
        uint maxTimeForPlayerDelay; // max time player can delay 
    }

    struct Lobby{
        bool isOccupied;   // is the lobby occupied
        address occupant;  // who is the occupant of this lobby
        bytes32 positionRoot; // Holds the merkletree root of the player's positions
        string encryptedMerkleTree; //Holds the full merkle tree, encrypted with the user's private key.
    }

    struct BattleVerification
    {
        uint battleId;                  //battle id
        bytes32 previousPositionLeaf;   // previous position leaf
        bytes _previousPositionProof;   // previous position proof
        uint8 _attackingPosition;       // attacking position
        bytes[] proofs;                 // proofs
        bytes32[] leafs;                // leafs
        uint8[] indexes;                // indexes
    }
    
    struct AttackModel
    {
        address player;
        uint tiles;
    }

    struct ShipPosition
    {
        ShipType ship;
        AxisType axis;
    }

}
    
