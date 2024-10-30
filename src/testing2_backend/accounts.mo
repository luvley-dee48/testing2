actor BankManagement {

    // Reusing Role and AccountStatus from the User table as needed.

    public type AccountStatus = {
        #Active;
        #Inactive;
        #Suspended;
        #Closed;
    };

    // Define Account Type
    public type Account = {
        account_id: Text;
        user_id: Text;             // Foreign key to link with User
        account_number: Text;
        account_type: Text;         // E.g., Savings, Checking, Business
        balance: Nat;
        interest_rate: Float;
        account_status: AccountStatus;
        icp_balance: Nat;           // ICP token balance if applicable
        icp_staking_status: Bool;    // Whether ICP tokens are staked
        icp_transaction_history: [Text]; // Transaction IDs on ICP, if needed

        // Timestamps
        created_at: Time.Time;
        updated_at: Time.Time;
    };

    // Accounts data storage
    stable var accounts: [Account] = [];

    // Function to add a new account
    public func addAccount(newAccount: Account): async Bool {
        accounts := Array.append(accounts, [newAccount]);
        return true;
    };

    // Function to retrieve accounts by user ID
    public query func getAccountsByUserId(userId: Text): async [Account] {
        return Array.filter<Account>(accounts, func (account) { account.user_id == userId });
    };

    // Function to update an account by ID
    public func updateAccount(accountId: Text, updatedAccount: Account): async Bool {
        let accountIndex = Array.indexOf<Account>(accounts, func (account) { account.account_id == accountId });
        switch (accountIndex) {
            case (?index) {
                accounts[index] := updatedAccount;
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to delete an account by ID
    public func deleteAccount(accountId: Text): async Bool {
        accounts := Array.filter<Account>(accounts, func (account) { account.account_id != accountId });
        return true;
    };
}
