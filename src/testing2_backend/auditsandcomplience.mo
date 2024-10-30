import Time "mo:base/Time";

actor AuditCanister {

    public type AuditLog = {
        user_id: Text;
        action: Text;                     // Description of the action performed
        timestamp: Time.Time;
        details: Text;                    // Additional details (e.g., transaction ID, previous state)
    };

    // Storage for audit logs
    stable var auditLogs: [AuditLog] = [];

    // Function to log an action
    public func logAction(userId: Text, action: Text, details: Text): async Bool {
        let logEntry: AuditLog = {
            user_id = userId;
            action = action;
            timestamp = Time.now();
            details = details;
        };
        auditLogs := Array.append(auditLogs, [logEntry]);
        return true;
    };

    // Function to retrieve audit logs for a specific user
    public query func getUserLogs(userId: Text): async [AuditLog] {
        return Array.filter<AuditLog>(auditLogs, func (log) { log.user_id == userId });
    };

    // Function to retrieve all logs (for admin use)
    public query func getAllLogs(): async [AuditLog] {
        return auditLogs;
    };
}
