pragma solidity ^0.8.22;
// SPDX-License-Identifier: UNLICENSED

contract Person {
  uint public age; 
  bool public isMarried; 
  /* Reference to spouse if person is married, address(0) otherwise */
  address public spouse; 
  address public mother; 
  address public father; 
  uint constant DEFAULT_SUBSIDY = 1; // Decreasing for testing
  /* welfare subsidy */
  uint public state_subsidy;

  // uint constant  DEFAULT_SUBSIDY = 500;

  // constructor(address ma, address fa) payable { // added payable since it is meant to recieve ether?
  constructor() payable {
    age = 0;
    isMarried = false;
    // mother = ma; // was here from the beginning
    // father = fa;
    mother = address(1); // Explicitly set to avoid issues  //Commented out for simplicity in testing
    father = address(2);
    spouse = address(0);
    state_subsidy = DEFAULT_SUBSIDY;
  } 


  //We require new_spouse != address(0);
  function marry(address new_spouse) public {
    require(new_spouse != address(0), "Spouse address cannot be zero");
    require(new_spouse != address(this), "Cannot marry yourself"); // added
    require(spouse == address(0), "Already married"); 
    
    Person sp = Person(new_spouse);     
    require(sp.spouse() == address(0), " New spouse is already married"); 
    // Update mutual relationship
    setSpouseAndMarriageStatus(new_spouse, true);
    setSpouseAndMarriageStatus(address(this), true);
  }
  
  function divorce() public {
    require(spouse != address(0), "No spouse to divorce");
    // Person sp = Person(address(spouse));
    
    // Nullify mutual relationship
    setSpouseAndMarriageStatus(address(0), false);
    spouse = address(0);
    isMarried = false;
  }

  function haveBirthday() public {
    age++;
  }

  // function setSpouse(address sp) public {
  //   require(sp != address(0), "Spouse address cannot be zero");
  //   require(sp != address(this), "Cannot marry yourself");
  //   // Ensure mutual marriage
  //   Person newSpouseContract = Person(sp);
  //   require(newSpouseContract.spouse() == address(0), "New spouse is already married");
  //   // Set spouse references for both parties
  //   spouse = sp;
  //   newSpouseContract.setSpouse(address(this));
  // }
  
  // function getSpouse() public view returns (address) {
  //   return spouse;
  // }

// missing function from the beginning
  function setSpouseAndMarriageStatus(address _spouse, bool _status) internal {
    spouse = _spouse;
    isMarried = _status;
}
  // Echidna invariant to check mutual marriage relationship
  function echidna_test_mutual_marriage() public view returns (bool) {
    if (spouse != address(0)) {
      Person sp = Person(spouse);
      return sp.spouse() == address(this);
    }
    return true; // No spouse, invariant holds
  }

  function echidna_test_valid_age() public view returns (bool) {
    return age >= 0 && age < 150; // Replace 150 with your desired upper limit
  }

  function echidna_test_no_self_marriage() public view returns (bool) {
    return spouse != address(this);
  }

  function echidna_test_is_married_consistent() public view returns (bool) {
    return !isMarried || spouse != address(0);
  }


}
