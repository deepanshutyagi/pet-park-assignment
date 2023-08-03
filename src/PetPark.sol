// SPDX-License-Identifier: GPL-3.0

// Solidity version
pragma solidity 0.8.19;

// Contract definition
contract PetPark {

    address private _owner;

    // Enum Gender
    enum Gender {
        Male,
        Female
    }

    // Struct type to store information about Borrowers
    struct Borrowers {
        Gender gender;
        uint8 age;
    }

    // Animal Types
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    // Maps
    mapping(AnimalType => uint256) public _totalPetsOfType;
    mapping(address => AnimalType) _borrowedAnimals;
    mapping(address => Borrowers) _borrowers;

    // Events
    event Added(AnimalType indexed _animalType, uint256 _count);
    event Borrowed(AnimalType indexed _animalType);
    event Returned(AnimalType indexed _animalType);


    modifier onlyOwner() {
        require(msg.sender == _owner, "Transaction Signer Is Not The Owner");
        _;
    }

    modifier onlyEligibleBorrower(uint8 age, Gender gender, AnimalType animalType) {
        require(animalType != AnimalType.None, "Invalid Animal type");
        require(_totalPetsOfType[animalType] > 0, "Selected Animal Not Available");
        require(age > 0, "Invalid Age");
       
        if (_borrowers[msg.sender].age == 0) {
            _borrowers[msg.sender].age = age;
            _borrowers[msg.sender].gender = gender;
        } else {
            require(_borrowers[msg.sender].age == age, "Invalid Age");
            require(_borrowers[msg.sender].gender ==gender, "Invalid Gender");
        }

        if (gender == Gender.Male) {
            require((animalType == AnimalType.Dog || animalType == AnimalType.Fish), "Gender Type Not Eligible To Borrow Pet Type");
        } else {
            require((age > 40 && animalType == AnimalType.Cat), "Gender Age Ineligible To Borrow Pet Type");
        }
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    // To add pets to pet park
    function add(AnimalType animalType, uint256 count) public onlyOwner {
        require(animalType != AnimalType.None, "Animal Type Is None");
        _totalPetsOfType[animalType] += count;
        emit Added(animalType, count);
    }

    // To borrow pets from pet park
    function borrow(uint8 age, Gender gender, AnimalType animalType) public onlyEligibleBorrower(age, gender, animalType) {
        require(_borrowedAnimals[msg.sender] == AnimalType.None, "Pet Already Borrowed");
        _borrowedAnimals[msg.sender] = animalType;
        _totalPetsOfType[animalType] -= 1;
        emit Borrowed(animalType);
    }

    // To return borrowed pet
    function giveBackAnimal() public {
        require(_borrowedAnimals[msg.sender] != AnimalType.None, "No borrowed pets");
        AnimalType _borrowedAnimalType = _borrowedAnimals[msg.sender];
        _borrowedAnimals[msg.sender] = AnimalType.None;
        _totalPetsOfType[_borrowedAnimalType] += 1;
        emit Returned(_borrowedAnimalType);
    }
    
}
