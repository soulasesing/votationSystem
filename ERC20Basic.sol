// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//juan gabriel 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//amilcar rosario 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//maria santos 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c


//INTERFACE OF OWN TOCKEN ERC20
interface IERC20{
    
    //devuela la cantidad de tockent existente  
    function totalSupply() external view returns(uint256);
    
    //return tha amount of tockent for a address throught given parameter
    function balanceOf(address account) external view returns (uint256);
    
    //return of the number of tockent that the spender can spend by name of the owner 
    function allowance(address owner, address spender) external view returns (uint256);
    
    //return a boolean values result of the operation 
    function transfer(address recipient, uint256 amount) external  returns(bool);
    
    //return the result boolean with the result of the operation spended
    function approve(address spender, uint256 amount) external returns (bool);
    
    //returna value boolean with the resolve of the operation althrought amount of toker using the method allowance()
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    
   
   
    // emit event when amount of tockent pass from origen to destine
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    //event that  have to emit when is stablished an assign with the allowance() method
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}


//implements of the function 
contract ERC20Basic is IERC20 {
    
    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "ARA";
    uint8 public constant decimals = 2;
    
    
     event Transfer(address indexed from, address indexed to, uint256 tokens);
     event Approval(address indexed owner, address indexed spender, uint256 tokens);
       
    using SafeMath for uint256;
      
      mapping (address => uint) balances;
      mapping (address => mapping (address => uint)) allowed;
      uint256 totalSupply_;
      
      constructor (uint256 initialSupply) public{
          totalSupply_ = initialSupply;
          balances[msg.sender] = totalSupply_;
      }
       
   
    function totalSupply() public override view returns(uint256){
        return totalSupply_;
    }
    
    function increaseTotalSupply(uint newTokensAmount) public {
        
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }
    
    function balanceOf(address tokenOwner) public  override view returns (uint256){
        return balances[tokenOwner];
    }
    
    
    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];

    }
    function transfer(address recipient, uint256 numTokens) public override  returns(bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }
    
    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        
        return true;
    }
    
}