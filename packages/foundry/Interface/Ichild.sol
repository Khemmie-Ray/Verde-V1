// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../Interface/IFactory.sol";

interface ICHILD {
    function userCampaignReg(string memory _name) external;

    function createCampaign(
        string memory _campaign_name,
        string memory _uri,
        address _super_admin,
        string memory _location,
        string memory _description
    ) external;

    function toggleOrganizationStatus() external;

    function getOrganizationStatus() external view returns (bool);

    function toggleCampaignStatus() external;

    function revoke(address[] calldata _individual) external;

    function VerifyStaff(address _staff) external view returns (bool);

    function VerifyUser(address _user) external view returns (bool);

    function VerifyAdmin(address _staff) external view returns (bool);

    function getUserName(
        address _user
    ) external view returns (string memory name);

    function registerStaffs(individual[] calldata _staff) external;

    function registerUsers(individual[] calldata _users) external;

    function listStaffs() external view returns (address[] memory);

    function listUsers() external view returns (address[] memory);

    function getStaffsName(
        address _staff
    ) external view returns (string memory name);

    function makeAdmin(individual[] calldata _admin) external;

    function getNameArray(
        address[] calldata _students
    ) external view returns (string[] memory);

    function removeAdmin(address[] calldata rouge_admins) external;

    function removeStaff(address[] calldata rouge_admins) external;

    function MintCertificate(string memory Uri) external;
}
