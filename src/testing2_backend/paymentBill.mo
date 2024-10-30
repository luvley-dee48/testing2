import Time "mo:base/Time";

actor PaymentsAndBillPay {

    // Define Payment Status Types
    public type PaymentStatus = {
        #Pending;
        #Completed;
        #Failed;
        #Cancelled;
    };

    // Define Payment Type
    public type Payment = {
        payment_id: Text;
        user_id: Text;                 // User making the payment
        amount: Nat;
        payment_date: Time.Time;
        recipient_id: Text;            // Account ID or vendor ID
        payment_status: PaymentStatus;

        // ICP-Specific Fields
        icp_sender_wallet: ?Text;      // Optional, sender's ICP wallet if ICP transaction
        icp_recipient_wallet: ?Text;   // Optional, recipient's ICP wallet if ICP transaction
        icp_block_height: ?Nat;        // Optional, block height for tracking on ICP
        icp_fee: ?Nat;                 // Optional, transaction fee if using ICP

        // Metadata
        notes: ?Text;
    };

    // Define Bill Type
    public type Bill = {
        bill_id: Text;
        user_id: Text;                 // User who owns the bill
        vendor_id: Text;               // ID of the vendor to whom the bill is paid
        amount_due: Nat;
        due_date: Time.Time;
        status: PaymentStatus;
        recurring: Bool;               // Indicates if it's a recurring bill
        payment_id: ?Text;             // ID of the payment made, if any

        // ICP-Specific Fields
        icp_vendor_wallet: ?Text;      // Optional, vendor’s ICP wallet address for ICP bill pay
        icp_block_height: ?Nat;        // Optional, block height for tracking
        icp_fee: ?Nat;                 // Optional, transaction fee if using ICP
    };

    // Payments and Bills data storage
    stable var payments: [Payment] = [];
    stable var bills: [Bill] = [];

    // Function to add a new payment
    public func addPayment(newPayment: Payment): async Bool {
        payments := Array.append(payments, [newPayment]);
        return true;
    };

    // Function to retrieve payments by user ID
    public query func getPaymentsByUserId(userId: Text): async [Payment] {
        return Array.filter<Payment>(payments, func (payment) { payment.user_id == userId });
    };

    // Function to add a new bill
    public func addBill(newBill: Bill): async Bool {
        bills := Array.append(bills, [newBill]);
        return true;
    };

    // Function to retrieve bills by user ID
    public query func getBillsByUserId(userId: Text): async [Bill] {
        return Array.filter<Bill>(bills, func (bill) { bill.user_id == userId });
    };

    // Function to pay a bill
    public func payBill(billId: Text, payment: Payment): async Bool {
        let billIndex = Array.indexOf<Bill>(bills, func (bill) { bill.bill_id == billId });
        switch (billIndex) {
            case (?index) {
                // Mark the bill as paid and add the payment
                bills[index].status := #Completed;
                bills[index].payment_id := ?payment.payment_id;
                payments := Array.append(payments, [payment]);
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to schedule recurring payments for bills
    public func scheduleRecurringPayments(billId: Text): async Bool {
        let bill = Array.find<Bill>(bills, func (b) { b.bill_id == billId and b.recurring });
        switch (bill) {
            case (?b) {
                // Logic to create and schedule recurring payments for this bill
                // Could interact with a separate scheduler canister if needed
                return true;
            };
            case null {
                return false;
            };
        };
    };
}
