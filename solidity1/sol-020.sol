// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract StructExamples {
    struct Car {
        string model;
        uint256 year;
        address owner;
    }

    Car[] public cars;

    function examples() external {
        // 3 ways to initialize a struct
        Car memory toyota = Car("Toyota", 1980, msg.sender);
        Car memory lambo =
            Car({model: "Lamborghini", year: 1999, owner: msg.sender});
        Car memory tesla;
        tesla.model = "Tesla";
        tesla.year = 2020;
        tesla.owner = msg.sender;

        // Push to array
        cars.push(toyota);
        cars.push(lambo);
        cars.push(tesla);
        // Initialize and push in single line of code
        cars.push(Car("Ferrari", 2000, msg.sender));

        // Get reference to Car struct stored in the array cars at index 0
        Car storage car = cars[0];
        // Update
        car.year = 1988;
    }

    function register(string memory model, uint256 year) external {
        cars.push(Car({model: model, year: year, owner: msg.sender}));
    }

    function get(uint256 _index)
        external
        view
        returns (string memory model, uint256 year, address owner)
    {
        // Write your code here
        Car memory car = cars[_index];
        return (car.model, car.year, car.owner);
    }

    function transfer(uint256 index, address owner) external {
        // Write your code here
        Car storage car = cars[index];
        car.owner = owner;
    }
    
}