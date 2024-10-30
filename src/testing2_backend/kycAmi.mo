import Time "mo:base/Time";

actor KYCandAML {

    // Define KYC Status Types
    public type KYCStatus = {
        #NotVerified;
        #InProgress;
        #Verified;
        #Rejected;
    };

    // Define AML Flag Types
    public type AMLFlag = {
        #SuspiciousTransaction;
        #HighRiskCountry;
        #FrequentLargeDeposits;
        #UnusualBehavior;
    };

    // Define KYC Documentation Type
    public type KYCDocument = {
        doc_type: Text;         // e.g., "Passport", "Driver's License"
        doc_id: Text;           // Document ID
        issue_date: Time.Time;
        expiry_date: Time.Time;
        status: KYCStatus;
        verified_by: ?Text;     // ID of verifier (e.g., compliance officer)
    };

    // Define User Profile with KYC and AML Information
    public type UserProfile = {
        user_id: Text;
        full_name: Text;
        date_of_birth: Time.Time;
        nationality: Text;
        address: Text;
        risk_score: Nat;        // Risk level, e.g., from 0 (low) to 100 (high)
        kyc_status: KYCStatus;
        aml_flags: [AMLFlag];
        documents: [KYCDocument];
        last_updated: Time.Time;

        // ICP-Specific Fields for Transaction Verification
        icp_wallet_address: ?Text;
    };

    // User Profiles storage
    stable var userProfiles: [UserProfile] = [];

    // Function to add a new user profile for KYC processing
    public func addUserProfile(newProfile: UserProfile): async Bool {
        userProfiles := Array.append(userProfiles, [newProfile]);
        return true;
    };

    // Function to add a KYC document for a user
    public func addKYCDocument(userId: Text, document: KYCDocument): async Bool {
        let userIndex = Array.indexOf<UserProfile>(userProfiles, func (profile) { profile.user_id == userId });
        switch (userIndex) {
            case (?index) {
                userProfiles[index].documents := Array.append(userProfiles[index].documents, [document]);
                userProfiles[index].last_updated := Time.now();
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to verify user KYC status
    public func verifyUserKYC(userId: Text): async ?Text {
        let userIndex = Array.indexOf<UserProfile>(userProfiles, func (profile) { profile.user_id == userId });
        switch (userIndex) {
            case (?index) {
                userProfiles[index].kyc_status := #Verified;
                userProfiles[index].last_updated := Time.now();
                return #Some("KYC verified successfully");
            };
            case null {
                return #Some("User not found");
            };
        };
    };

    // Function to raise an AML flag for a user
    public func raiseAMLFlag(userId: Text, flag: AMLFlag): async Bool {
        let userIndex = Array.indexOf<UserProfile>(userProfiles, func (profile) { profile.user_id == userId });
        switch (userIndex) {
            case (?index) {
                userProfiles[index].aml_flags := Array.append(userProfiles[index].aml_flags, [flag]);
                userProfiles[index].risk_score := userProfiles[index].risk_score + 20; // Increment risk score based on flag
                userProfiles[index].last_updated := Time.now();
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to retrieve user profile by user ID
    public query func getUserProfile(userId: Text): async ?UserProfile {
        return Array.find<UserProfile>(userProfiles, func (profile) { profile.user_id == userId });
    };

    // Function to assess AML risk
    public query func assessAML(userId: Text): async Text {
        let userIndex = Array.indexOf<UserProfile>(userProfiles, func (profile) { profile.user_id == userId });
        switch (userIndex) {
            case (?index) {
                let profile = userProfiles[index];
                if (profile.risk_score >= 80) {
                    return "High Risk";
                } else if (profile.risk_score >= 50) {
                    return "Medium Risk";
                } else {
                    return "Low Risk";
                };
            };
            case null {
                return "User not found";
            };
        };
    };

    // Function to clear AML flags for a user
    public func clearAMLFlags(userId: Text): async Bool {
        let userIndex = Array.indexOf<UserProfile>(userProfiles, func (profile) { profile.user_id == userId });
        switch (userIndex) {
            case (?index) {
                userProfiles[index].aml_flags := [];
                userProfiles[index].risk_score := 0; // Reset risk score
                userProfiles[index].last_updated := Time.now();
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to get all user profiles (Optional)
    public query func getAllUserProfiles(): async [UserProfile] {
        return userProfiles;
    };
}
