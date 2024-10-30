import Time "mo:base/Time";

actor NotificationsCanister {

    // Define Notification Type
    public type NotificationType = {
        #TransactionAlert;
        #BillPaymentReminder;
        #LoanUpdate;
        #KYCRequest;
        #AMLAlert;
        #SystemAlert;
    };

    // Define Notification Urgency Levels
    public type UrgencyLevel = {
        #Low;
        #Medium;
        #High;
        #Critical;
    };

    // Define Notification Structure
    public type Notification = {
        notification_id: Text;
        user_id: Text;                      // ID of the user receiving the notification
        notification_type: NotificationType;
        urgency: UrgencyLevel;
        message: Text;
        timestamp: Time.Time;
        read: Bool;

        // Delivery-specific fields
        send_email: Bool;                   // Whether this notification should be sent via email
        send_sms: Bool;                     // Whether this notification should be sent via SMS
        in_app: Bool;                       // Whether this notification should be displayed in-app
    };

    // Storage for Notifications
    stable var notifications: [Notification] = [];

    // Function to add a new notification
    public func addNotification(newNotification: Notification): async Bool {
        notifications := Array.append(notifications, [newNotification]);
        return true;
    };

    // Function to retrieve notifications for a specific user
    public query func getUserNotifications(userId: Text): async [Notification] {
        return Array.filter<Notification>(notifications, func (notif) { notif.user_id == userId });
    };

    // Function to mark a notification as read
    public func markNotificationAsRead(notificationId: Text): async Bool {
        let notifIndex = Array.indexOf<Notification>(notifications, func (notif) { notif.notification_id == notificationId });
        switch (notifIndex) {
            case (?index) {
                notifications[index].read := true;
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to retrieve unread notifications for a user
    public query func getUnreadNotifications(userId: Text): async [Notification] {
        return Array.filter<Notification>(notifications, func (notif) { notif.user_id == userId and not notif.read });
    };

    // Function to send in-app notification
    public func sendInAppNotification(userId: Text, message: Text, notification_type: NotificationType, urgency: UrgencyLevel): async Bool {
        let notification = {
            notification_id = "notif-" # Nat.toText(Time.now());
            user_id = userId;
            notification_type = notification_type;
            urgency = urgency;
            message = message;
            timestamp = Time.now();
            read = false;
            send_email = false;
            send_sms = false;
            in_app = true;
        };
        return await addNotification(notification);
    };

    // Function to send email notification (example, assuming email integration)
    public func sendEmailNotification(userId: Text, message: Text, notification_type: NotificationType): async Bool {
        let notification = {
            notification_id = "notif-" # Nat.toText(Time.now());
            user_id = userId;
            notification_type = notification_type;
            urgency = #Medium;
            message = message;
            timestamp = Time.now();
            read = false;
            send_email = true;
            send_sms = false;
            in_app = false;
        };
        return await addNotification(notification);
    };

    // Function to send SMS notification (example, assuming SMS integration)
    public func sendSMSNotification(userId: Text, message: Text, notification_type: NotificationType): async Bool {
        let notification = {
            notification_id = "notif-" # Nat.toText(Time.now());
            user_id = userId;
            notification_type = notification_type;
            urgency = #High;
            message = message;
            timestamp = Time.now();
            read = false;
            send_email = false;
            send_sms = true;
            in_app = false;
        };
        return await addNotification(notification);
    };
}
