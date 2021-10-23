// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;



contract vatation{

    // adress owner of the contract
    address  owner;
   
    //contructor to set adress of the owner
    constructor () public{
        
        owner = msg.sender;
    }
    
    //ralation between name of candidate and the hash of her datos
    mapping(string => bytes32) idCondidate;
    
    //relation between names candidate and her number of votes
    mapping(string => uint) votesCandidate;
    
    //list  to stored the name of the candidates
   string [] candidates;
   
   // list of hash of the addresses voters(we will calculate de hash and add into a dimamyc array)
   bytes32 [] voters;
   
   
   //Function to able  any person can postulate as a candidate
   function addNewCandidate(string memory _name, uint _age, string memory _idCondidate) public {
       
       //calculate the hash with the  datos of the candidate
       bytes32 hashCadidate = keccak256(abi.encodePacked(_name,_age,_idCondidate));
       
       //stored the hash with the hash ralte with her name 
       idCondidate[_name] = hashCadidate;
       
       //stored the hash into the list candidate
       candidates.push(_name);
     }
     
     //function to view the list of candidates
     function viewCanditates() public view returns(string[] memory){
         
         //return all the dinamyc array
         return candidates;
       }
    
     
    //function to able people  vote for any candidate
    function vote(string memory _candidateName) public{
        
        //calculate the hash of the address voters
        bytes32 hashVoters = keccak256(abi.encodePacked(msg.sender));
        
        //validate If these voters already did voter
        for(uint i=0; i<voters.length;i++){
            require(voters[i]!=hashVoters,"this voter have been vote");
        }
        //add hashVoters into arrays voters
        voters.push(hashVoters);
       //add new vote to the candidate
       votesCandidate[_candidateName]++;
        
    }
    
    //function  the amount of votes that have a candidate
    
    function viewVotes(string memory _candidateName) public view returns(uint){
        
        //return the amount of votes that have a candidate(we using the mapping)
        return votesCandidate[_candidateName];
        
      }
      
      
      //auxiliar function convert uint to string
      function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
      
      
      //function that  return the list of candidate and her votes
      function viewResult() public view returns(string memory){
          
          //save the candidate and her votes
          string memory result;
          
          //a run the long of the array  to update the string result
          for(uint i=0;i < candidates.length; i++){
              //update the string result with the condidate in the position "i" of the arrays
              //and her amount the votes 
              result = string(abi.encodePacked(result, "(", candidates[i], " , ", uint2str(viewVotes(candidates[i])), ")--------" ));
              
              
          }
          
          return result;
          
      }
      
      // function that return the winner of the election the candidates with most votes
      function viewWinner() public view returns(string memory){
          
          // variable stored the name of the winner 
          string memory winner = candidates[0];
          //this variable is used to see a tie
          bool flag;
          
          //compare votes of candidates
          for(uint i=1; i < candidates.length; i++){
              
              if(votesCandidate[winner] < votesCandidate[candidates[i]]){
                  winner = candidates[i];
                  flag=false;
          }else{
              //compare if  two candidates had the same amount of votes
              if (votesCandidate[winner] == votesCandidate[candidates[i]]){
                  flag=true;
                  
              }
          }
          
        }
        //Evaluate  the flag know if there is a tie
        if (flag==true){
            winner = "There is a tie among two candidates";
        }
        
        return winner;
      }
      
      
}