pragma solidity ^0.4.20;

contract Betting {
    //Declare contract variables
    address public owner;
    uint256 public minimumBet;      
    uint256 public totalBetOne;     //Bets on team 1
    uint256 public totalBetTwo;     //Bets on team 2
    uint256 public totalNumberOfBets;    //Total bets on game
    uint256 public maxAmountOfBets;     //Max bets on game
    
    address[] public players;       //Hold all current player addresses for game
    
    struct Player {     //Player can bet any amount of a team
        uint256 amountBet;
        uint16 teamSelected;
    }
    
    mapping(address => Player) public playerInfo;   //Keep track of which addresses map to which player
    
    function Betting() public {
        owner = msg.sender;
        minimumBet = 100000000000000;
    }

    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }
    
    //Set up a function to negate cheating - check if the player exists in the players array
    function checkPlayerExists(address player) public constant returns(bool) {
        for(uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) return true;
        }
        return false;
    }
    
    //Set up a function to bet if a player is allowed to play and bet higher than minimumBet
    function bet(uint8 _teamSelected) public payable {
        require(!checkPlayerExists(msg.sender));     //Make sure player doesn't exist
        require(msg.value > minimumBet);
        //Set player info in map
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].teamSelected = _teamSelected;
        players.push(msg.sender);    //Add address to players list
        //Increment correct betting pool 
        if (_teamSelected == 1) {
            totalBetOne += msg.value;
        }
        else {
            totalBetTwo += msg.value;
        }
    }
    
    //Distribute prizes to players with correct amounts
    function distributePrizes(uint16 teamWinner) public {
        address[1000] memory winners;   //Temp array
        uint256 count = 0;      //Count of array of winners
        uint256 loserBet = 0;   //Value of losers bets
        uint256 winnerBet = 0;  //Value of winners bets
        
        //Find players who select winners
        for (uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if (playerInfo[playerAddress].teamSelected == teamWinner) {
                winners[count] = playerAddress;
                count++;
            }
        }
        //Adjust winning and losing teams and their pools
        if (teamWinner == 1) {
            winnerBet = totalBetOne;
            loserBet = totalBetTwo;
        }
        else {
            winnerBet = totalBetTwo;
            loserBet = totalBetOne;
        }
        //Payout winners
        for (uint256 j = 0; j < count; j++) {
            if (winners[j] != address(0)) {     //Not 0x
                address addr = winners[j];
                uint256 bet = playerInfo[addr].amountBet;
                //Transfer money to user
                winners[j].transfer((bet*(10000+(LoserBet*10000/WinnerBet)))/10000 );
            }
        }
        //Reset variables
        delete playerInfo[playerAddress];
        players.length = 0;
        loserBet = 0;
        winnerBet = 0;
        totalBetOne = 0;
        totalBetTwo = 0;
    }
    
}
