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
    // TODO: see that it works with the original constructor
    // mother = ma; // was here from the beginning
    // father = fa;
    father = address(2);
    mother = address(1); // Explicitly set to avoid issues 
    spouse = address(0);
    state_subsidy = DEFAULT_SUBSIDY;
  } 

  function marry(address new_spouse) public {
    require(new_spouse != address(0), "Spouse address cannot be zero");
    require(new_spouse != address(this), "Cannot marry yourself");
    require(spouse == address(0), "Already married"); 
    require(age >= 18, "Cannot marry before age 18");
    
    Person sp = Person(new_spouse);     
    require(sp.getSpouse() == address(0), " New spouse is already married"); 

    // Ensure the new spouse is not a sibling
    require(mother != sp.getMother(), "Cannot marry a sibling (same mother)");
    require(father != sp.getFather(), "Cannot marry a sibling (same father)");
    
    // Update mutual relationship
    setSpouse(new_spouse);
    setMarriageStatus(true);
    sp.setSpouse(address(this));
    sp.setMarriageStatus(true);

    updateSubsidy();
    sp.updateSubsidy();
  }
  
  function divorce() public {
    require(spouse != address(0), "No spouse to divorce");
    Person sp = Person(address(spouse));
    
    // Remove mutual relationship
    setSpouse(address(0));
    setMarriageStatus(false);
    sp.setSpouse(address(0));
    sp.setMarriageStatus(false);

    updateSubsidy();
    sp.updateSubsidy();
  }

  function haveBirthday() public {
    age++;
    updateSubsidy(); // Recalculate subsidy based on new age
  }

  function getSpouse() public view returns (address) {
    return spouse;
  } 
  function getMother() public view returns (address){
    return mother;
  }
  function getFather() public view returns (address){
    return father;
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
      require(getSpouse() != address(0), "Does not have a spouse");
    } else {
      require(getSpouse() == address(0), "Already have a spouse");
    }
    isMarried = marriage;
  }

  function calculateSubsidy() public view returns (uint) {
    if(isMarried){
      return (DEFAULT_SUBSIDY * 70) / 100 + 53; // Have on purposed written the wring this, does not result in a failed test...
    } else if(age > 65){
      return DEFAULT_SUBSIDY + 100; // Increased subsidy for unmarried persons over 65
    } else {
      return DEFAULT_SUBSIDY; // Unmarried people under 65 get the default subsidy
    }
  }

  function updateSubsidy() public {
    state_subsidy = calculateSubsidy();
  }



// Echidna invariants

  // Check mutual marriage relationship
  function echidna_test_mutual_marriage() public view returns (bool) {
    if (spouse != address(0)) {
      Person sp = Person(spouse);
      return sp.getSpouse() == address(this);
    } else if (spouse == address(0)) {
      return true; // No spouse, invariant holds
    }
  }

  // Test that the person is not marrying it self
  function echidna_test_no_self_marriage() public view returns (bool) {
    return spouse != address(this);
  }

  // Checks that there is a spouse if the person is married
  function echidna_test_is_married_consistent() public view returns (bool) {
    return !isMarried || spouse != address(0);
  }

  // Check the age is in a valid range
  function echidna_test_valid_age() public view returns (bool) {
    return age >= 0 && age < 150;
  }

  // Ensure marriage only occurs if age >= 18
  function echidna_test_marriage_age() public view returns (bool) {
    if (isMarried) {
      return age >= 18;
    } else if (!isMarried){
      return true; // If not married, condition holds
    } 
  }

  function echidna_test_no_sibling_marriage() public view returns (bool) {
    if (spouse != address(0)) {
      Person spouseContract = Person(spouse);
      return (mother != spouseContract.getMother() && father != spouseContract.getFather());
    } else if( spouse == address(0)){
      return true; // Not married, condition holds
    }
  }

  function echidna_test_subsidy_consistency() public view returns (bool) {
    uint expectedSubsidy;
    if (isMarried) {
        expectedSubsidy =(DEFAULT_SUBSIDY * 70) / 100;
    } else {
        expectedSubsidy = (age < 65) ? DEFAULT_SUBSIDY : 600;
    }
    return state_subsidy == expectedSubsidy;
  }

  function echidna_test_subsidy_at_age_65() public view returns (bool) {
    if (age == 65) {
      if (!isMarried) {
        return state_subsidy == 600;
      } else {
        return state_subsidy == (DEFAULT_SUBSIDY * 70) / 100;
      }
    } else if (age != 65){
      return true; // Skip other ages
    }
  }

  function echidna_test_subsidy_never_exceeds_max() public view returns (bool) {
    return state_subsidy <= 600;
  }

  function echidna_test_subsidy_never_below_min() public view returns (bool) {
    return state_subsidy >= 350;
  }

  function echidna_test_subsidy_matches_calculation() public view returns (bool) {
    return state_subsidy == calculateSubsidy();
  }

}
