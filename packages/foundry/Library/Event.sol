// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library Event {
    event staffsRegistered(uint noOfStaffs);
    event adminsRegistered(uint noOfAdmins);
    event UserRegistered(uint no_of_users);

    event Handover(address oldMentor, address newMentor);
    event staffRemoved(uint no_of_staffs);
    event mentorsRemoved(uint no_of_staffs);
    event adminRemoved(uint no_of_admins);
}
