// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PetPark.sol";


contract PetParkTest is Test, PetPark {
    PetPark petPark;
    
    address testOwnerAccount;

    address testPrimaryAccount;
    address testSecondaryAccount;

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = address(0xABCD);
        testSecondaryAccount = address(0xABDC);
    }

    function testOwnerCanAddAnimal() public {
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotAddAnimalWhenNonOwner() public {
        uint fishCount = petPark._totalPetsOfType(AnimalType.Fish);
        petPark.add(AnimalType.Fish, 1);
        uint fishCountAdded = petPark._totalPetsOfType(AnimalType.Fish);
        assertEq(fishCount+1 , fishCountAdded);
        vm.expectRevert("Transaction Signer Is Not The Owner");
        vm.prank(testPrimaryAccount);
        petPark.add(AnimalType.Fish, 1);
    }

    function testCannotAddInvalidAnimal() public {
        vm.expectRevert("Animal Type Is None");
        petPark.add(AnimalType.None, 5);
    }

    function testExpectEmitAddEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Added(AnimalType.Fish, 5);
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotBorrowWhenAgeZero() public {
        petPark.add(AnimalType.Dog, 1);
        vm.expectRevert("Invalid Age");
        petPark.borrow(0, Gender.Female, AnimalType.Dog);
    }

    function testCannotBorrowUnavailableAnimal() public {
        vm.expectRevert("Selected Animal Not Available");

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testCannotBorrowInvalidAnimal() public {
        vm.expectRevert("Invalid Animal type");

        petPark.borrow(24, Gender.Male, AnimalType.None);
    }

    function testCannotBorrowCatForMen() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Gender Type Not Eligible To Borrow Pet Type");
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.add(AnimalType.Rabbit, 5);

        vm.expectRevert("Gender Type Not Eligible To Borrow Pet Type");
        petPark.borrow(24, Gender.Male, AnimalType.Rabbit);
    }

    function testCannotBorrowParrotForMen() public {
        petPark.add(AnimalType.Parrot, 5);

        vm.expectRevert("Gender Type Not Eligible To Borrow Pet Type");
        petPark.borrow(24, Gender.Male, AnimalType.Parrot);
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Gender Age Ineligible To Borrow Pet Type");
        petPark.borrow(24, Gender.Female, AnimalType.Cat);
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.add(AnimalType.Fish, 5);
        petPark.add(AnimalType.Cat, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Pet Already Borrowed");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Gender Type Not Eligible To Borrow Pet Type");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        petPark.add(AnimalType.Fish, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Invalid Age");
        vm.prank(testPrimaryAccount);
        petPark.borrow(23, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Invalid Gender");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Female, AnimalType.Fish);
    }

    function testExpectEmitOnBorrow() public {
        petPark.add(AnimalType.Fish, 5);
        vm.expectEmit(false, false, false, true);

        emit Borrowed(AnimalType.Fish);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testBorrowCountDecrement() public {
        petPark.add(AnimalType.Dog, 1);
        uint dogCountBeforeBorrowed = petPark._totalPetsOfType(AnimalType.Dog);
        petPark.borrow(24, Gender.Male, AnimalType.Dog);
        uint dogCountAfterBorrowed = petPark._totalPetsOfType(AnimalType.Dog);
        assertEq(dogCountAfterBorrowed,dogCountBeforeBorrowed-1);
    }

    function testCannotGiveBack() public {
        vm.expectRevert("No borrowed pets");
        petPark.giveBackAnimal();
    }

    function testPetCountIncrement() public {
        petPark.add(AnimalType.Fish, 5);

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
        uint reducedPetCount = petPark._totalPetsOfType(AnimalType.Fish);

        petPark.giveBackAnimal();
        uint currentPetCount = petPark._totalPetsOfType(AnimalType.Fish);

		assertEq(reducedPetCount, currentPetCount - 1);
    }
}
