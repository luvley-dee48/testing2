import Nat "mo:base/Nat";
import Time "mo:base/Time";

actor BankManagement {

    // Define Transaction Type
    public type TransactionType = {
        #Deposit;
        #Withdrawal;
        #Transfer;
        #ICPTransfer;
    };

    public type TransactionStatus = {
        #Pending;
        #Completed;
        #Failed;
    };

    public type Transaction = {
        transaction_id: Text;
        source_account_id: ?Text;       // Optional, null if deposit
        destination_account_id: ?Text;  // Optional, null if withdrawal
        amount: Nat;
        transaction_type: TransactionType;
        transaction_status: TransactionStatus;
        timestamp: Time.Time;

        // ICP-Specific Fields
        icp_wallet_from: ?Text;         // Optional, sender ICP wallet if ICP transfer
        icp_wallet_to: ?Text;           // Optional, receiver ICP wallet if ICP transfer
        icp_block_height: ?Nat;         // Optional, block height for ICP transactions
        icp_fee: ?Nat;                  // Optional, transaction fee for ICP transactions
    };

    // Transactions data storage
    stable var transactions: [Transaction] = [];

    // Function to add a new transaction
    public func addTransaction(newTransaction: Transaction): async Bool {
        transactions := Array.append(transactions, [newTransaction]);
        return true;
    };

    // Function to retrieve transactions by account ID
    public query func getTransactionsByAccountId(accountId: Text): async [Transaction] {
        return Array.filter<Transaction>(transactions, func (transaction) {
            transaction.source_account_id == ?accountId or transaction.destination_account_id == ?accountId
        });
    };

    // Function to retrieve transactions by ICP wallet address
    public query func getTransactionsByICPWallet(walletAddress: Text): async [Transaction] {
        return Array.filter<Transaction>(transactions, func (transaction) {
            transaction.icp_wallet_from == ?walletAddress or transaction.icp_wallet_to == ?walletAddress
        });
    };
}
