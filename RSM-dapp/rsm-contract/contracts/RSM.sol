// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
//pragma experimental ABIEncoderV2; 
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



contract RSM is IERC20 {
  using SafeMath for uint256;
  mapping (address => uint256) _balances;
  mapping (address => mapping (address => uint256)) _allowed;
  
  uint256 public _totalSupply;
  string public name;
  string public symbol;
  uint public decimals;
  
  constructor() {
  name = "Royalty";
  symbol = "RSM";
  decimals = 0;
  _totalSupply = 100000000;
  _balances[msg.sender] = _totalSupply;
  emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public override view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address owner,address spender)public override view returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public override returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

 
  function approve(address spender, uint256 value) public override returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }


  function transferFrom(address from, address to, uint256 value) public override returns (bool)
  {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)public returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

 
  function decreaseAllowance(address spender, uint256 subtractedValue)public returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  
  function _mint(address account, uint256 amount) internal {
    require(account != address(0));
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0));
    require(amount <= _balances[account]);

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      amount);
    _burn(account, amount);
  }
  
}

contract Royalties is RSM {
    
    // Talent struct to save the data related to Talent
    struct Talent{
        address payable by;
        string name;
        string description;
        uint cost;
        uint limit;
    }
    
    // Saves the number of times the Talent has been used
    struct TimesUsed {
        uint times;
    }
    
    // To save the names of all talent pieces
    string[] TPNames;

    uint count;
    
    
    address payable public owner;
    mapping(uint => Talent[]) data;
    mapping(uint => TimesUsed[]) TU;
    mapping (address=>uint) TalentPieceOwner;
    mapping (address=>uint) TalentPieceUsers;
    mapping(address=> uint) balances;
    
    
    constructor() {
        owner = payable(msg.sender);
    }
    
    // Modifier to restrict function use to only admin   
    modifier onlyAdmin{
        require(msg.sender==owner,'onlyAdmin');
        _;
    }
    
    // Modifier to restrict function use to only Talent Piece Owner
    modifier onlyTalentPieceOwner { 
        require(TalentPieceOwner[msg.sender]==1);
        _;
    }
    
    // Modifier to restrict function use to only user
    modifier onlyUser {
        require(TalentPieceUsers[msg.sender]==1 && msg.sender!=owner);
        _;
    }
    
    // Function to register a Talent Piece Owner and can be called only by admin
    function registerTalentPieceOwner(address role, bool talentOwner) public onlyAdmin {
        transfer(role, 100);
        if(talentOwner) {
            TalentPieceOwner[role] = 1;
            TalentPieceUsers[role] = 1;
        }
        else
            TalentPieceUsers[role] = 1;
    }
    
    // Function to create a Talent Piece which can be called only by a Talent Piece Owner
    function createTalentPiece(string memory name,string memory description, uint cost, uint limit) public onlyTalentPieceOwner {
            Talent memory piece;
            //TPNames memory TTT;
            piece.by = payable(msg.sender);
            piece.name = name;
            piece.description = description;
            piece.cost = cost;
            piece.limit = limit;
            data[count].push(piece);
            
            TPNames.push(name);
            
            count+=1;
    }
    
    // To use Talent Piece which can be used only by a user
    function useTalentPiece(uint number) public onlyUser returns (Talent[] memory show) {
        show = data[number];
        if(TU[number].length+1 < data[number][0].limit) {
            TimesUsed memory T;
            T.times=T.times+1;
            TU[number].push(T);
            transfer(data[number][0].by, data[number][0].cost);
        }
    }
    
    // To check how many times a talent has been used
    function numberOfTimesUsed(uint number) view public returns (uint used) {
        used = TU[number].length;
    } 
    
    // To check the data of a Talent
    //function getData(uint number) view public returns (Talent[] memory c){
    //    c = data[number];
    //}

    function getData(uint number) view public returns (uint256, string memory, string memory, uint, uint){
      //string storage k = abi.encodePacked(data[number][0].by);
        return (data[number][0].cost, data[number][0].name, data[number][0].description, data[number][0].cost, data[number][0].limit);
    }
    
    // To get all the names of the talents created
    function getNames() view public returns (string[] memory){
        return TPNames;
    }
    
    // To unregister a user
    function unregisterTalentPieceOwner(address Towner) public onlyAdmin {
        TalentPieceUsers[Towner] = 0;
        if(TalentPieceOwner[Towner] == 1) {
            TalentPieceUsers[Towner] = 0;
        }
    }
}