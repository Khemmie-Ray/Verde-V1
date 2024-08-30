// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../../Interface/IFactory.sol";
import "../../Library/Error.sol";
import "../../Library/Event.sol";
import "../IERC20.sol";

contract organisation {
    /**
     * ============================================================ *
     * --------------------- ORGANIZATION RECORD------------------- *
     * ============================================================ *
     */
    string organization;
    string cohort;
    string public certiificateURI;
    address organisationFactory;
    address public NftContract;
    address public certificateContract;
    bool public certificateIssued;
    string public organisationImageUri;
    bool public isOngoing = true;
    IERC20 token;

    address public spokContract;
    string public spokURI;

    bool public spokMinted;
    mapping(address => bool) requestNameCorrection;

    // campaign
    string public campaign_name;
    string public campaign_uri;
    string public campaign_location;
    string public campaign_description;
    bool public isCampaignOn = true;

    struct Campaign {
        string campaign_name;
        string campaign_uri;
        string campaign_location;
        string campaign_description;
        address owner;
    }
    Campaign[] public campaigns;

    /**
     * ============================================================ *
     * --------------------- USER RECORD------------------- *
     * ============================================================ *
     */
    address[] users;
    mapping(address => individual) userData;
    mapping(address => uint) indexInUsersArray;
    mapping(address => uint) studentsTotalAttendance;
    mapping(address => bool) isUser;
    mapping(address => bytes[]) classesAttended;

    address reg_add;
    mapping(address => Reg) registered_users;
    struct Reg {
        string name;
        address user_address;
    }
    mapping(address => bool) isPresent;
    Reg[] public registered_users_data;
    mapping(address => bool) is_registered_user;
    event UserCampaignRegistered(string name, address user_address);

    /**
     * ============================================================ *
     * --------------------- STAFFS RECORD------------------------- *
     * ============================================================ *
     */
    address super_admin;
    address director;

    address[] staffs;
    mapping(address => uint) index_in_staffs_array;
    mapping(address => bool) is_valid_staff;
    mapping(address => individual) staffs_data;

    /**
     * ============================================================ *
     * --------------------- ADMIN RECORD------------------------- *
     * ============================================================ *
     */
    address[] admins;
    mapping(address => uint) index_in_admin_array;
    mapping(address => bool) is_valid_admin;
    mapping(address => bool) is_admin;
    mapping(address => individual) admin_data;

    /**
     * ============================================================ *
     * --------------------- MODIFIERS------------------------- *
     * ============================================================ *
     */ modifier onlySuperAdmin() {
        require(msg.sender == super_admin, "NOT MODERATOR");
        _;
    }

    modifier onlyStaffs() {
        require(isUser[msg.sender] == true, "NOT A VALID STAFF");
        _;
    }
    modifier onlySuperAdminOrAdmins() {
        require(
            is_valid_admin[msg.sender] == true ||
                msg.sender == super_admin ||
                is_valid_staff[msg.sender] == true,
            "NOT ALLOWED"
        );
        _;
    }
    modifier onlyStaff() {
        require(
            msg.sender == super_admin || is_valid_staff[msg.sender] == true,
            "NOT STAFF"
        );
        _;
    }

    constructor(
        address _token,
        string memory _organization_name,
        address _super_admin,
        string memory _admin_name,
        string memory _uri
    ) {
        IERC20 _token_instance = IERC20(_token);
        token = _token_instance;
        super_admin = _super_admin;
        organization = _organization_name;
        organisationFactory = msg.sender;
        director = _super_admin;
        index_in_staffs_array[_super_admin] = staffs.length;
        staffs.push(_super_admin);
        admins.push(_super_admin);
        is_valid_staff[_super_admin] = true;
        staffs_data[_super_admin]._address = _super_admin;
        staffs_data[_super_admin]._name = _admin_name;
        organisationImageUri = _uri;
    }

    function registerStaffs(
        individual[] calldata _staff
    ) external onlySuperAdmin {
        uint staffLength = _staff.length;
        for (uint i; i < staffLength; i++) {
            if (is_valid_staff[_staff[i]._address] == false) {
                staffs_data[_staff[i]._address] = _staff[i];
                index_in_staffs_array[_staff[i]._address] = staffs.length;
                staffs.push(_staff[i]._address);
                is_valid_staff[_staff[i]._address] = true;
            }
        }
        IFACTORY(organisationFactory).register(_staff);
        emit Event.staffsRegistered(_staff.length);
    }

    function makeAdmin(individual[] calldata _admin) external onlySuperAdmin {
        uint adminLength = _admin.length;
        for (uint i; i < adminLength; i++) {
            if (is_valid_staff[_admin[i]._address] == false)
                revert Error.not_valid_Staff();
            if (is_admin[_admin[i]._address] == false) {
                admin_data[_admin[i]._address] = _admin[i];
                is_admin[_admin[i]._address] = true;
                index_in_admin_array[_admin[i]._address] = admins.length;
                is_valid_admin[_admin[i]._address] = true;
                admins.push(_admin[i]._address);
            }
        }
        IFACTORY(organisationFactory).register(_admin);
        emit Event.adminsRegistered(_admin.length);
    }

    function TransferOwnership(address newModerator) external onlySuperAdmin {
        assert(newModerator != address(0));
        super_admin = newModerator;
    }

    function createCampaign(
        string memory _campaign_name,
        string memory _uri,
        address _super_admin,
        string memory _location,
        string memory _description
    ) external onlySuperAdmin {
        Campaign memory newCampaign = Campaign(
            _campaign_name,
            _uri,
            _location,
            _description,
            _super_admin
        );
        campaigns.push(newCampaign);
    }

    function registerUsers(
        individual[] calldata _users
    ) external onlySuperAdmin {
        uint studentLength = _users.length;
        for (uint i; i < studentLength; i++) {
            if (isUser[_users[i]._address] == false) {
                userData[_users[i]._address] = _users[i];
                indexInUsersArray[_users[i]._address] = users.length;
                users.push(_users[i]._address);
                isUser[_users[i]._address] = true;
            }
        }
        IFACTORY(organisationFactory).register(_users);
        emit Event.UserRegistered(_users.length);
    }

    function userCampaignReg(string memory _name) external {
        if (is_registered_user[msg.sender] == true)
            revert Error.user_already_registered();
        Reg memory new_user = Reg(_name, msg.sender);

        registered_users[msg.sender] = new_user;
        indexInUsersArray[msg.sender] = users.length;
        registered_users_data.push(new_user);

        is_registered_user[msg.sender] = true;
        isPresent[msg.sender] = true;
        registered_users[msg.sender].name = _name;
        registered_users[msg.sender].user_address = msg.sender;
        emit UserCampaignRegistered(_name, msg.sender);
    }

    function getUserCampaignReg() external view returns (Reg[] memory) {
        return registered_users_data;
    }

    function staffHandover(address newMentor) external {
        if (msg.sender != director && msg.sender != super_admin)
            revert Error.not_Autorized_Caller();
        director = newMentor;
        emit Event.Handover(msg.sender, newMentor);
    }

    function removeAdmin(
        address[] calldata rouge_admins
    ) external onlySuperAdmin {
        uint mentors_to_remove = rouge_admins.length;
        for (uint i; i < mentors_to_remove; i++) {
            delete staffs_data[rouge_admins[i]];
            admins[index_in_admin_array[rouge_admins[i]]] = admins[
                admins.length - 1
            ];
            admins.pop();
            is_admin[rouge_admins[i]] = false;
        }
        IFACTORY(organisationFactory).revoke(rouge_admins);
        emit Event.adminRemoved(rouge_admins.length);
    }

    function removeStaff(
        address[] calldata _rouge_staffs
    ) external onlySuperAdmin {
        uint mentors_to_remove = _rouge_staffs.length;
        for (uint i; i < mentors_to_remove; i++) {
            delete staffs_data[_rouge_staffs[i]];
            staffs[index_in_staffs_array[_rouge_staffs[i]]] = staffs[
                staffs.length - 1
            ];
            staffs.pop();
            is_valid_staff[_rouge_staffs[i]] = false;
        }
        IFACTORY(organisationFactory).revoke(_rouge_staffs);
        emit Event.staffRemoved(_rouge_staffs.length);
    }

    function getNameArray(
        address[] calldata _users
    ) external view returns (string[] memory) {
        string[] memory Names = new string[](_users.length);
        string memory emptyName;
        for (uint i = 0; i < _users.length; i++) {
            if (
                keccak256(abi.encodePacked(userData[_users[i]]._name)) ==
                keccak256(abi.encodePacked(emptyName))
            ) {
                Names[i] = "UNREGISTERED";
            } else {
                Names[i] = userData[_users[i]]._name;
            }
        }
        return Names;
    }

    function liststaffs() external view returns (address[] memory) {
        return staffs;
    }

    function VerifyAdmin(address _staff) external view returns (bool) {
        return is_valid_admin[_staff];
    }

    function VerifyUser(address _user) external view returns (bool) {
        return isUser[_user];
    }

    function getUserName(
        address _user
    ) external view returns (string memory name) {
        if (isUser[_user] == false) revert Error.not_valid_user();
        return userData[_user]._name;
    }

    function listStaffs() external view returns (address[] memory) {
        return staffs;
    }

    function listUsers() external view returns (address[] memory) {
        return users;
    }

    function VerifyStaff(address _staff) external view returns (bool) {
        return is_valid_staff[_staff];
    }

    function getStaffsName(
        address _staff
    ) external view returns (string memory name) {
        if (is_valid_staff[_staff] == false) revert Error.not_valid_Staff();
        return staffs_data[_staff]._name;
    }

    function getModerator() external view returns (address) {
        return super_admin;
    }

    function getOrganizationName() external view returns (string memory) {
        return organization;
    }

    function getCohortName() external view returns (string memory) {
        return cohort;
    }

    function getOrganisationImageUri() external view returns (string memory) {
        return organisationImageUri;
    }

    function toggleOrganizationStatus() external {
        isCampaignOn = !isCampaignOn;
    }

    function toggleCampaignStatus() external {
        isCampaignOn = !isCampaignOn;
    }

    function getOrganizationStatus() external view returns (bool) {
        return isCampaignOn;
    }
}
