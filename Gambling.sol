pragma solidity ^0.4.4;

contract Gambling {
    //Declare fields
    uint private winningNumber;     //Number that was randomly generated between 1-100
    address[] private winningPlayers;   //Array of winnings addresses
    uint8 maxPlayers;   //Max players in a game
    uint8 minPlayers;   //Min players in a game
    uint8 currentPlayers;   //Number of current playerss
    address host;   //Hoting address
    bool finished = false;      //Is the game still going? 
    address[] players;      //All players in game
    uint256 pot;   //Pot of all stakes
    mapping (address => uint256) playersMapping;   //All players in game map to number guessed
    mapping (address => bool) validPlayersMapping;  //Make sure no repeat players
    //Declare events
    //A logger for the winners and the coordinating number
    event ChooseWinner(uint _winningNumber, address[] _winningPlayers);
    //A logger for the random number we generated
    event RandomNumberGenerated(uint);
    
    //Declare functions
    //Constructor
    function Gambling() {
        address _host = msg.sender;
        host = _host;
        maxPlayers = 10;
        minPlayers = 2; 
        winningNumber = 1;
        pot = 0;
    }
    
    //Function allowing a user to join a game fairly, then transfer 1eth to contract
    function joinGame(uint256 guess) payable {
        require(!finished);     //Game must be going on
        require(guess >= 1);  //Guess is between 1 and 100
        require(guess <= 100);  //Guess is between 1 and 100
        require(msg.sender != host);    //Host can't play
        require(currentPlayers+1 < maxPlayers);     //Can't exceed max number
        require(!validPlayersMapping[msg.sender]);       //Player not already in game
        require(msg.value == 1 ether,"Amount should be equal to 1 Ether");    //Player must stake 1eth to the pot
        players.push(msg.sender);
        //STAKE HERE
        pot += msg.value;
        playersMapping[msg.sender] = guess;
        validPlayersMapping[msg.sender] = true;
        currentPlayers++;
    }
    
    //Function to choose the winners of the pool based on the random winning number
    function chooseWinner(uint _winningNumber) internal{
        winningNumber = _winningNumber;
        uint numWinners = 0;    //Keep track when we found one or more
        uint256 offset = 0;     //Keep an offset incase the winner isn't clear off the jump
        while (numWinners == 0) {       //Find at least one winner
            for (uint i=0; i<players.length; i++) {
                address tempAddress = players[i];
                //Check if guess + offset is winner
                if (playersMapping[tempAddress]+offset == _winningNumber) {
                    numWinners++;
                    winningPlayers.push(tempAddress);
                }
                //Check if guess - offset is winner
                if (playersMapping[tempAddress]-offset == _winningNumber) {
                    numWinners++;
                    winningPlayers.push(tempAddress);
                }
            }
            //Adjust offset to +/- 1 and continue search for winning players
            offset++;
            offset = offset % 100;
        }
        //Event logging
        ChooseWinner(winningNumber, winningPlayers);
        //PAYOUT HERE
        for (uint j=0; j<winningPlayers.length; j++) {
            address addr = winningPlayers[j];
            addr.transfer((pot/winningPlayers.length));
        }
    }
    
    //Function to generate a random number from block hash
    function generateRandomNumber() {
        require(!finished);
        finished = true;
        uint random_number = uint(block.blockhash(block.number-1))%100 + 1;
        RandomNumberGenerated(random_number);
        chooseWinner(random_number);
    }
    
    //Getters for testing
    function getWinningNumber() constant returns (uint) {
        return winningNumber;
    }
    function getWinnersAddresses() constant returns (address[]) {
        return winningPlayers;
    }
    function getPlayers() constant returns (address[]) {
        return players;
    }
    function getPot() constant returns (uint256) {
        return pot;
    }
}