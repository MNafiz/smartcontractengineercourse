// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }
    
    Todo[] public todos;
    
    function create(string calldata text) external {
        todos.push(Todo({text: text, completed: false}));
    }
    
    function updateText(uint256 index, string calldata text) external {
        todos[index].text = text;
    }
    
    function toggleCompleted(uint256 index) external {
        todos[index].completed = !todos[index].completed;
    }
    
    function get(uint256 index) external view returns(string memory, bool) {
        Todo storage todo = todos[index];
        return (todo.text, todo.completed);
    }
}