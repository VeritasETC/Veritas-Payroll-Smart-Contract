// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// deployed address of this contract
//0xc7bfc197B24842ED1f34CA509f00f26e8d4CBbF0

contract Payroll {
    struct Employee {
        uint256 id;
        string name;
        uint256 salary;
        uint256 taxRate;
        uint256[] deductions;
        bool isActive;
        bool isFulltime;
        uint256 paymentFrequency;
        uint256 paymentAmount;
        uint256 halfDay;
        uint256 sickDays;
        mapping(uint256 => uint256) leaveDates;
    }

    mapping(address => Employee) public employees;

    event EmployeeAdded(
        address indexed employeeAddress,
        uint256 id,
        string name
    );

    function addEmployee(
        address employeeAdress,
        uint256 id,
        string memory name,
        uint256 salary,
        uint256 taxRate,
        uint256[] memory deductions,
        bool isActive,
        bool isFullTime,
        uint256 paymentFrequency,
        uint256 paymentAmount
    ) public {
        Employee storage e = employees[employeeAdress];

        e.id = id;
        e.name = name;
        e.salary = salary;
        e.taxRate = taxRate;
        e.deductions = deductions;
        e.isActive = isActive;
        e.isFulltime = isFullTime;
        e.paymentFrequency = paymentFrequency;
        e.paymentAmount = paymentAmount;
        e.leaveDates[0] = 0;
    }

    function calculateNetPay(
        address employeeAddress
    ) public view returns (uint256) {
        Employee storage employee = employees[employeeAddress];

        uint256 grossPay;

        if (employee.paymentFrequency == 1) {
            // monthly
            grossPay = employee.salary;
        } else if (employee.paymentFrequency == 2) {
            // weekly
            grossPay = employee.salary / 4;
        } else if (employee.paymentFrequency == 3) {
            // hourly
            grossPay = employee.paymentAmount * employee.halfDay;
        }

        for (uint256 i = 0; i < employee.deductions.length; i++) {
            grossPay -= employee.deductions[i];
        }

        uint256 taxAmount = (grossPay * employee.taxRate) / 100;
        uint256 netPay = grossPay - taxAmount;
        return netPay;
    }

    function sendPayment(address employeeAddress) public payable {
        Employee storage employee = employees[employeeAddress];
        require(employee.isActive, "Employee is not active");
        uint256 netPay = calculateNetPay(employeeAddress);
        require(msg.value >= netPay, "Insufficient funds for payment");
        (bool success, ) = employeeAddress.call{value: netPay}("");
        require(success, "Payment failed");
    }

    function updateLeaveDate(
        address employeeAddress,
        uint256 leaveDate
    ) public {
        Employee storage employee = employees[employeeAddress];
        require(employee.isActive, "Employee is not active");
        employee.leaveDates[leaveDate] += 1;
        if (employee.leaveDates[leaveDate] == 2) {
            employee.halfDay += 1;
        }
    }
}
