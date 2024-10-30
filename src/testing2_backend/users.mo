import Nat "mo:base/Nat";
import Time "mo:base/Time";

actor BankManagement {

    // Define User Role Types
    public type Role = {
        #Customer;
        #Teller;
        #Manager;
        #Admin;
    };

    // Define Account Status Types
    public type AccountStatus = {
        #Active;
        #Inactive;
        #Suspended;
        #Closed;
    };

    // Define User Record
    public type User = {
        user_id: Text;
        username: Text;
        password_hash: Text;
        email: Text;
        phone_number: Text;
        date_of_birth: Time.Time;
        address: Text;

        // Bank-specific Information
        account_number: Text;
        account_type: Text;
        balance: Nat;
        interest_rate: Float;
        account_status: AccountStatus;

        // ICP-specific Information
        icp_wallet_address: Text;
        icp_balance: Nat;
        icp_staking_status: Bool;
        icp_node_id: Text;
        icp_transaction_history: [Text]; // Array of transaction IDs
        is_icp_verified: Bool;

        // Role and Permissions
        role: Role;
        permissions: [Text];

        // Security and Verification
        is_verified: Bool;
        verification_code: ?Text;  // Optional
        two_factor_enabled: Bool;
        two_factor_secret: ?Text;  // Optional

        // Timestamps
        created_at: Time.Time;
        updated_at: Time.Time;
        last_login: ?Time.Time;  // Optional
        last_password_change: ?Time.Time;  // Optional

        // Optional Additional Info
        preferred_language: ?Text;
        notification_preferences: ?[Text];
        profile_picture: ?Text;
    };

    // Users data storage
    stable var users : [User] = [];

    // Function to add a new user with basic validation
    public func addUser(newUser: User): async Result<Bool, Text> {
        // Check for existing user
        if (Array.exists(users, func (user) { user.user_id == newUser.user_id })) {
            return #Err("User already exists");
        }

        // Basic validation
        if (newUser.email == "") {
            return #Err("Email cannot be empty");
        }

        users := Array.append(users, [newUser]);
        return #Ok(true);
    };

    // Function to retrieve a user by ID
    public query func getUserById(userId: Text): async ?User {
        return Array.find<User>(users, func (user) { user.user_id == userId });
    };

    // Function to update a user with better error handling
    public func updateUser(userId: Text, updatedUser: User): async Result<Bool, Text> {
        let userIndex = Array.indexOf<User>(users, func (user) { user.user_id == userId });
        switch (userIndex) {
            case (?index) {
                users[index] := updatedUser;
                return #Ok(true);
            };
            case null {
                return #Err("User not found");
            };
        };
    };

    // Function to delete a user by ID
    public func deleteUser(userId: Text): async Result<Bool, Text> {
        let originalLength = Array.size(users);
        users := Array.filter<User>(users, func (user) { user.user_id != userId });
        if (Array.size(users) < originalLength) {
            return #Ok(true);
        } else {
            return #Err("User not found");
        }
    };
}

actor Main {

    // Instantiate the canisters
    private let auditCanister = AuditCanister();
    private let userRolesCanister = UserRolesCanister();
    private let feedbackCanister = FeedbackCanister();

    // Function to log a user action
    public func logUserAction(userId: Text, action: Text, details: Text): async Bool {
        return await auditCanister.logAction(userId, action, details);
    }

    // Function to add a user profile
    public func addUserProfile(userProfile: UserRolesCanister.UserProfile): async Bool {
        return await userRolesCanister.addUserProfile(userProfile);
    }

    // Function to submit user feedback
    public func submitUserFeedback(userId: Text, message: Text): async Bool {
        return await feedbackCanister.submitFeedback(userId, message);
    }
}
