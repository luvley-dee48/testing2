import Time "mo:base/Time";
import Nat "mo:base/Nat";

actor BankManagement {

    // Define Loan and Credit Status Types
    public type LoanStatus = {
        #Pending;
        #Active;
        #Completed;
        #Defaulted;
    };

    public type CreditStatus = {
        #Active;
        #Suspended;
        #Closed;
    };

    // Define Loan Type
    public type Loan = {
        loan_id: Text;
        user_id: Text;                  // Foreign key to link with User
        principal_amount: Nat;
        outstanding_balance: Nat;
        interest_rate: Float;
        loan_term_months: Nat;
        monthly_payment: Nat;
        status: LoanStatus;
        start_date: Time.Time;
        due_date: Time.Time;

        // ICP-Specific Fields
        icp_loan_wallet_address: ?Text; // Optional ICP wallet for loan transactions
        icp_loan_block_height: ?Nat;    // Optional, block height for tracking
        icp_interest_payment: ?Nat;     // Interest payment if blockchain-based

        // Payment History (simple array or separate collection)
        payment_history: [Nat];         // Record of monthly payments made
    };

    // Define Credit Type
    public type Credit = {
        credit_id: Text;
        user_id: Text;                  // Foreign key to link with User
        credit_limit: Nat;
        outstanding_balance: Nat;
        interest_rate: Float;
        status: CreditStatus;

        // ICP-Specific Fields
        icp_credit_wallet_address: ?Text; // Optional ICP wallet for credit transactions
        icp_credit_block_height: ?Nat;    // Optional, block height for ICP tracking

        // Transactions
        transaction_history: [Text];       // Reference to transaction IDs
    };

    // Loans and Credit data storage
    stable var loans: [Loan] = [];
    stable var credits: [Credit] = [];

    // Function to add a new loan
    public func addLoan(newLoan: Loan): async Bool {
        loans := Array.append(loans, [newLoan]);
        return true;
    };

    // Function to add a new credit line
    public func addCredit(newCredit: Credit): async Bool {
        credits := Array.append(credits, [newCredit]);
        return true;
    };

    // Function to retrieve loans by user ID
    public query func getLoansByUserId(userId: Text): async [Loan] {
        return Array.filter<Loan>(loans, func (loan) { loan.user_id == userId });
    };

    // Function to retrieve credits by user ID
    public query func getCreditsByUserId(userId: Text): async [Credit] {
        return Array.filter<Credit>(credits, func (credit) { credit.user_id == userId });
    };

    // Function to update loan status by loan ID
    public func updateLoanStatus(loanId: Text, newStatus: LoanStatus): async Bool {
        let loanIndex = Array.indexOf<Loan>(loans, func (loan) { loan.loan_id == loanId });
        switch (loanIndex) {
            case (?index) {
                loans[index].status := newStatus;
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to update credit status by credit ID
    public func updateCreditStatus(creditId: Text, newStatus: CreditStatus): async Bool {
        let creditIndex = Array.indexOf<Credit>(credits, func (credit) { credit.credit_id == creditId });
        switch (creditIndex) {
            case (?index) {
                credits[index].status := newStatus;
                return true;
            };
            case null {
                return false;
            };
        };
    };
}
