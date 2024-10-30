import Time "mo:base/Time";

actor AuditAndCompliance {

    // Define Audit Event Type
    public type EventType = {
        #UserLogin;
        #Transaction;
        #LoanModification;
        #AccountUpdate;
        #BillPayment;
        #SystemAlert;
    };

    public type ComplianceStatus = {
        #Compliant;
        #NonCompliant;
        #UnderReview;
    };

    // Define Audit Log Entry Type
    public type LogEntry = {
        log_id: Text;
        event_type: EventType;
        user_id: ?Text;                   // Optional, user who triggered the event
        associated_id: Text;              // Could be transaction ID, loan ID, or bill ID
        timestamp: Time.Time;
        details: Text;                    // Description of the action or event
        compliance_status: ComplianceStatus;

        // ICP-Specific Fields
        icp_block_height: ?Nat;           // Block height if related to an ICP transaction
    };

    // Log Entries storage
    stable var auditLogs: [LogEntry] = [];

    // Function to add a new log entry
    public func addLogEntry(newLog: LogEntry): async Bool {
        auditLogs := Array.append(auditLogs, [newLog]);
        return true;
    };

    // Function to retrieve logs by user ID
    public query func getLogsByUserId(userId: Text): async [LogEntry] {
        return Array.filter<LogEntry>(auditLogs, func (log) { log.user_id == ?userId });
    };

    // Function to retrieve logs by event type
    public query func getLogsByEventType(eventType: EventType): async [LogEntry] {
        return Array.filter<LogEntry>(auditLogs, func (log) { log.event_type == eventType });
    };

    // Function to check compliance for specific log entry
    public func checkCompliance(logId: Text): async ComplianceStatus {
        let logIndex = Array.indexOf<LogEntry>(auditLogs, func (log) { log.log_id == logId });
        switch (logIndex) {
            case (?index) {
                // Example compliance check
                let log = auditLogs[index];
                if (log.event_type == #Transaction and log.details.contains("suspicious")) {
                    auditLogs[index].compliance_status := #NonCompliant;
                    return #NonCompliant;
                };
                auditLogs[index].compliance_status := #Compliant;
                return #Compliant;
            };
            case null {
                return #UnderReview;
            };
        };
    };

    // Function to generate compliance report
    public query func generateComplianceReport(): async [LogEntry] {
        return Array.filter<LogEntry>(auditLogs, func (log) { log.compliance_status != #Compliant });
    };

    // Function to mark a log as reviewed and compliant
    public func markLogAsCompliant(logId: Text): async Bool {
        let logIndex = Array.indexOf<LogEntry>(auditLogs, func (log) { log.log_id == logId });
        switch (logIndex) {
            case (?index) {
                auditLogs[index].compliance_status := #Compliant;
                return true;
            };
            case null {
                return false;
            };
        };
    };
}
