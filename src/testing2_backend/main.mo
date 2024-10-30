import Nat "mo:base/Nat";
import Time "mo:base/Time";

// Import your canisters
import AuditCanister "path/to/AuditCanister";
import UserRolesCanister "path/to/UserRolesCanister";
import FeedbackCanister "path/to/FeedbackCanister";
import PaymentsAndBillPay "path/to/PaymentsAndBillPay";
import NotificationsCanister "path/to/NotificationsCanister";
import BankManagement "path/to/BankManagement"; // Adjust the import path as necessary
import KYCandAML "path/to/KYCandAML"; // Integrated KYC and AML

actor Main {

    // Instantiate the canisters
    private let auditCanister = AuditCanister();
    private let userRolesCanister = UserRolesCanister();
    private let feedbackCanister = FeedbackCanister();
    private let bankManagement = BankManagement(); // Integrated BankManagement
    private let paymentsAndBillPay = PaymentsAndBillPay();
    private let notificationsCanister = NotificationsCanister();
    private let kycAndAML = KYCandAML(); // Integrated KYC and AML

    // Function to log a user action
    public func logUserAction(userId: Text, action: Text, details: Text): async Result<Bool, Text> {
        let result = await auditCanister.logAction(userId, action, details);
        return result ? #Ok(true) : #Err("Failed to log action");
    }

    // Function to add a user profile
    public func addUserProfile(userProfile: UserRolesCanister.UserProfile): async Result<Bool, Text> {
        return await userRolesCanister.addUserProfile(userProfile);
    }

    // Function to submit user feedback
    public func submitUserFeedback(userId: Text, message: Text): async Result<Bool, Text> {
        let result = await feedbackCanister.submitFeedback(userId, message);
        return result ? #Ok(true) : #Err("Failed to submit feedback");
    }

    // Function to add a new loan
    public func addLoan(newLoan: BankManagement.Loan): async Result<Bool, Text> {
        let result = await bankManagement.addLoan(newLoan);
        return result ? #Ok(true) : #Err("Failed to add loan");
    }

    // Function to add a new credit line
    public func addCredit(newCredit: BankManagement.Credit): async Result<Bool, Text> {
        let result = await bankManagement.addCredit(newCredit);
        return result ? #Ok(true) : #Err("Failed to add credit");
    }

    // Function to retrieve loans by user ID
    public query func getLoansByUserId(userId: Text): async Result<[BankManagement.Loan], Text> {
        let loans = await bankManagement.getLoansByUserId(userId);
        return #Ok(loans);
    }

    // Function to retrieve credits by user ID
    public query func getCreditsByUserId(userId: Text): async Result<[BankManagement.Credit], Text> {
        let credits = await bankManagement.getCreditsByUserId(userId);
        return #Ok(credits);
    }

    // Function to update loan status by loan ID
    public func updateLoanStatus(loanId: Text, newStatus: BankManagement.LoanStatus): async Result<Bool, Text> {
        let result = await bankManagement.updateLoanStatus(loanId, newStatus);
        return result ? #Ok(true) : #Err("Failed to update loan status");
    }

    // Function to update credit status by credit ID
    public func updateCreditStatus(creditId: Text, newStatus: BankManagement.CreditStatus): async Result<Bool, Text> {
        let result = await bankManagement.updateCreditStatus(creditId, newStatus);
        return result ? #Ok(true) : #Err("Failed to update credit status");
    }

    // Function to pay a bill
    public func addPayment(newPayment: PaymentsAndBillPay.Payment): async Result<Bool, Text> {
        let result = await paymentsAndBillPay.addPayment(newPayment);
        return result ? #Ok(true) : #Err("Failed to add payment");
    }

    // Function to retrieve payments by user ID
    public query func getPaymentsByUserId(userId: Text): async Result<[PaymentsAndBillPay.Payment], Text> {
        let payments = await paymentsAndBillPay.getPaymentsByUserId(userId);
        return #Ok(payments);
    }

    // Function to add a bill
    public func addBill(newBill: PaymentsAndBillPay.Bill): async Result<Bool, Text> {
        let result = await paymentsAndBillPay.addBill(newBill);
        return result ? #Ok(true) : #Err("Failed to add bill");
    }

    // Function to retrieve bills by user ID
    public query func getBillsByUserId(userId: Text): async Result<[PaymentsAndBillPay.Bill], Text> {
        let bills = await paymentsAndBillPay.getBillsByUserId(userId);
        return #Ok(bills);
    }

    // Function to pay a bill
    public func payBill(billId: Text, payment: PaymentsAndBillPay.Payment): async Result<Bool, Text> {
        let result = await paymentsAndBillPay.payBill(billId, payment);
        return result ? #Ok(true) : #Err("Failed to pay the bill");
    }

    // Function to schedule recurring payments for a bill
    public func scheduleRecurringPayments(billId: Text): async Result<Bool, Text> {
        let result = await paymentsAndBillPay.scheduleRecurringPayments(billId);
        return result ? #Ok(true) : #Err("Failed to schedule recurring payments");
    }

    // Function to send an in-app notification
    public func sendInAppNotification(userId: Text, message: Text, notificationType: NotificationsCanister.NotificationType, urgency: NotificationsCanister.UrgencyLevel): async Result<Bool, Text> {
        let result = await notificationsCanister.sendInAppNotification(userId, message, notificationType, urgency);
        return result ? #Ok(true) : #Err("Failed to send in-app notification");
    }

    // Function to send an email notification
    public func sendEmailNotification(userId: Text, message: Text, notificationType: NotificationsCanister.NotificationType): async Result<Bool, Text> {
        let result = await notificationsCanister.sendEmailNotification(userId, message, notificationType);
        return result ? #Ok(true) : #Err("Failed to send email notification");
    }

    // Function to send an SMS notification
    public func sendSMSNotification(userId: Text, message: Text, notificationType: NotificationsCanister.NotificationType): async Result<Bool, Text> {
        let result = await notificationsCanister.sendSMSNotification(userId, message, notificationType);
        return result ? #Ok(true) : #Err("Failed to send SMS notification");
    }

    // Function to get user notifications
    public query func getUserNotifications(userId: Text): async Result<[NotificationsCanister.Notification], Text> {
        let notifications = await notificationsCanister.getUserNotifications(userId);
        return #Ok(notifications);
    }

    // Function to get unread notifications for a user
    public query func getUnreadNotifications(userId: Text): async Result<[NotificationsCanister.Notification], Text> {
        let unreadNotifications = await notificationsCanister.getUnreadNotifications(userId);
        return #Ok(unreadNotifications);
    }

    // KYC and AML Functions

    // Function to add a new user profile for KYC processing
    public func addKYCUserProfile(newProfile: KYCandAML.UserProfile): async Result<Bool, Text> {
        let result = await kycAndAML.addUserProfile(newProfile);
        return result ? #Ok(true) : #Err("Failed to add KYC user profile");
    }

    // Function to add a KYC document for a user
    public func addKYCDocument(userId: Text, document: KYCandAML.KYCDocument): async Result<Bool, Text> {
        let result = await kycAndAML.addKYCDocument(userId, document);
        return result ? #Ok(true) : #Err("Failed to add KYC document");
    }

    // Function to verify user KYC status
    public func verifyUserKYC(userId: Text): async Result<Bool, Text> {
        let result = await kycAndAML.verifyUserKYC(userId);
        return result ? #Ok(true) : #Err("Failed to verify KYC status");
    }

    // Function to raise an AML flag for a user
    public func raiseAMLFlag(userId: Text, flag: KYCandAML.AMLFlag): async Result<Bool, Text> {
        let result = await kycAndAML.raiseAMLFlag(userId, flag);
        return result ? #Ok(true) : #Err("Failed to raise AML flag");
    }

    // Function to retrieve user profile by user ID
    public query func getKYCUserProfile(userId: Text): async Result<?KYCandAML.UserProfile, Text> {
        let profile = await kycAndAML.getUserProfile(userId);
        return #Ok(profile);
    }

    // Function to assess AML risk
    public query func assessAML(userId: Text): async Result<Text, Text> {
        let risk = await kycAndAML.assessAML(userId);
        return #Ok(risk);
    }

    // Function to clear AML flags for a user
    public func clearAMLFlags(userId: Text): async Result<Bool, Text> {
        let result = await kycAndAML.clearAMLFlags(userId);
        return result ? #Ok(true) : #Err("Failed to clear AML flags");
    }

    // Function to retrieve user feedback
    public query func getUserFeedback(userId: Text): async Result<[FeedbackCanister.Feedback], Text> {
        let feedbackList = await feedbackCanister.getUserFeedback(userId);
        return feedbackList;
    }

    // Function to retrieve all feedback (admin function)
    public query func getAllFeedback(): async Result<[FeedbackCanister.Feedback], Text> {
        let allFeedback = await feedbackCanister.getAllFeedback();
        return allFeedback;
    }

    // Function to categorize feedback
    public func categorizeFeedback(feedbackId: Text, category: Text): async Result<Bool, Text> {
        let result = await feedbackCanister.categorizeFeedback(feedbackId, category);
        return result ? #Ok(true) : #Err("Failed to categorize feedback");
    }

    // Function to respond to feedback
    public func respondToFeedback(feedbackId: Text, response: Text): async Result<Bool, Text> {
        let result = await feedbackCanister.respondToFeedback(feedbackId, response);
        return result ? #Ok(true) : #Err("Failed to respond to feedback");
    }

    // Function to rate feedback response
    public func rateFeedbackResponse(feedbackId: Text, rating: Nat): async Result<Bool, Text> {
        let result = await feedbackCanister.rateFeedbackResponse(feedbackId, rating);
        return result ? #Ok(true) : #Err("Failed to rate feedback response");
    }

}
