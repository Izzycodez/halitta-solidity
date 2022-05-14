// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract enumsAndStructs{
    mapping(string => Subject) public nameToSubject;

    enum Subject{
        maths,
        english,
        physics,
        chemistry,
        history,
        geography
    }

    Subject public subject;

    struct Students{
        string studentName;
        Subject fav_subject;
    }
    Students students;
    Students[] public student;

    function set(string memory _studentName, Subject _fav_subject) public{
         nameToSubject[ _studentName] =  _fav_subject; // this is the mapping data structure
        Students memory studentInfo = Students(_studentName, _fav_subject);
        student.push(studentInfo);
    }

    
}
