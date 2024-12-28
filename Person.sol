pragma solidity ^0.8.22;
// SPDX-License-Identifier: UNLICENSED

contract Person {
  uint age; 
  bool isMarried; 
  /* Reference to spouse if person is married, address(0) otherwise */
  address spouse; 
  address mother; 
  address father; 
  uint constant DEFAULT_SUBSIDY = 500; // Decreasing for testing
  /* welfare subsidy */
  uint state_subsidy;

  // constructor(address ma, address fa) payable { // added payable since it is meant to recieve ether?
  constructor() payable {
    age = 0;
    isMarried = false;
    // mother = ma; // was here from the beginning
    // father = fa;
    mother = address(1); // Explicitly set to avoid issues 
    spouse = address(0);
    state_subsidy = DEFAULT_SUBSIDY;
  } 

  //We require new_spouse != address(0);
  function marry(address new_spouse) public {
    require(new_spouse != address(0), "Spouse address cannot be zero");
    require(new_spouse != address(this), "Cannot marry yourself"); // added
    require(spouse == address(0), "Already married"); 
    require(age >= 18, "Cannot marry before age 18");
    
    Person sp = Person(new_spouse);     
    require(sp.getSpouse() == address(0), " New spouse is already married"); 
    
    // Update mutual relationship
    setSpouse(new_spouse);
    setMarriageStatus(true);
    sp.setSpouse(address(this));
    sp.setMarriageStatus(true);
  }
  
  function divorce() public {
    require(spouse != address(0), "No spouse to divorce");
    Person sp = Person(address(spouse));
    
    // Nullify mutual relationship
    spouse = address(0);
    isMarried = false;
    sp.setSpouse(address(0));
    sp.setMarriageStatus(false);
  }

  function haveBirthday() public {
    age++;
  }

  function getSpouse() public view returns (address) {
    return spouse;
  }

  function setSpouse(address sp) public {
    Person new_sp = Person(address(sp));
    require(sp != address(0), "Spouse address cannot be zero");
    require(sp != address(this), "Cannot marry yourself");
    require(new_sp.getSpouse() == address(this), "Unauthorized caller"); // the spouse's spouse matches this person
    spouse = sp;
  } 

  function setMarriageStatus(bool marriage) public{
    if (marriage) {
      require(getSpouse() != address(0), "Already have a spouse");
    } else {
      require(getSpouse() == address(0), "Does not have a spouse");
    }
    isMarried = marriage;
  }


// Echidna invariants

  // Check mutual marriage relationship
  function echidna_test_mutual_marriage() public view returns (bool) {
    if (spouse != address(0)) {
      Person sp = Person(spouse);
      return sp.getSpouse() == address(this);
    }
    return true; // No spouse, invariant holds
  }

  // Test that the person is not marrying it self
  function echidna_test_no_self_marriage() public view returns (bool) {
    return spouse != address(this);
  }

  // Checks that there is a spouse if the person is married
  function echidna_test_is_married_consistent() public view returns (bool) {
    return !isMarried || spouse != address(0);
  }

  // checks that divorce is mutual
  function echidna_test_mutual_divorce() public view returns (bool) {
    if (spouse != address(0)) {
        // Check that if a person has a spouse, the spouse's spouse matches this person
        Person spouseContract = Person(spouse);
        return spouseContract.getSpouse() == address(this);
    }
    return true; // If not married, condition holds
  }

  // Check the age is in a valid range
  function echidna_test_valid_age() public view returns (bool) {
    return age >= 0 && age < 150;
  }

  // Ensure marriage only occurs if age >= 18
  function echidna_test_marriage_age() public view returns (bool) {
    if (isMarried) {
        return age >= 18;
    }
    return true; // If not married, condition holds
    }

}
