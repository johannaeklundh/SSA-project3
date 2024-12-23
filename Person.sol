pragma solidity ^0.8.22;
// SPDX-License-Identifier: UNLICENSED

contract Person {

 uint age; 

 bool isMarried; 

 /* Reference to spouse if person is married, address(0) otherwise */
 address spouse; 


address  mother; 
address  father; 

 uint constant  DEFAULT_SUBSIDY = 500;

 /* welfare subsidy */
 uint state_subsidy;


 constructor(address ma, address fa) {
   age = 0;
   isMarried = false;
   mother = ma;
   father = fa;
   spouse = address(0);
   state_subsidy = DEFAULT_SUBSIDY;
 } 


 //We require new_spouse != address(0);
 function marry(address new_spouse) public {
  spouse = new_spouse;
  isMarried = true;
 }
 
 function divorce() public {
  Person sp = Person(address(spouse));
  sp.setSpouse(address(0));
  spouse = address(0);
  isMarried = false;
 }

 function haveBirthday() public {
  age++;
 }

function setSpouse(address sp) public {
    spouse = sp;
}
function getSpouse() public returns (address) {
    return spouse;
}
}
