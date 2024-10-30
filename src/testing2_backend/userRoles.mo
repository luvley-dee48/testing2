import Nat "mo:base/Nat";

actor UserRolesCanister {

    public type UserRole = {
        #Admin;
        #Employee;
        #HR;
        #Customer;
    };

    public type UserProfile = {
        user_id: Text;
        full_name: Text;
        role: UserRole;
        permissions: [Text]; // List of specific permissions
    };

    // Storage for user profiles
    stable var userProfiles: [UserProfile] = [];

    // Function to add a new user profile
    public func addUserProfile(newProfile: UserProfile): async Result<Bool, Text> {
        // Check for existing profile
        if (Array.exists(userProfiles, func (profile) { profile.user_id == newProfile.user_id })) {
            return #Err("User profile already exists");
        }
        
        userProfiles := Array.append(userProfiles, [newProfile]);
        return #Ok(true);
    };

    // Function to get a user profile by user ID
    public query func getUserProfile(userId: Text): async Result<UserProfile, Text> {
        switch (Array.find<UserProfile>(userProfiles, func (profile) { profile.user_id == userId })) {
            case (?profile) {
                return #Ok(profile);
            };
            case null {
                return #Err("User profile not found");
            };
        }
    };

    // Function to update user role
    public func updateUserRole(userId: Text, newRole: UserRole): async Result<Bool, Text> {
        let userIndex = Array.indexOf<UserProfile>(userProfiles, func (profile) { profile.user_id == userId });
        switch (userIndex) {
            case (?index) {
                userProfiles[index].role := newRole;
                return #Ok(true);
            };
            case null {
                return #Err("User profile not found");
            };
        };
    };

    // Function to check if a user has a specific permission
    public query func hasPermission(userId: Text, permission: Text): async Result<Bool, Text> {
        switch (await getUserProfile(userId)) {
            case (#Ok(profile)) {
                return #Ok(Array.contains<Text>(profile.permissions, permission));
            };
            case (#Err(err)) {
                return #Err(err);
            };
        }
    };
}
