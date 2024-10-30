import Time "mo:base/Time";

actor FeedbackCanister {

    public type Feedback = {
        user_id: Text;
        message: Text;
        timestamp: Time.Time;
        resolved: Bool;                  // Whether the feedback has been resolved
        response: ?Text;                // Admin response, if any
        category: ?Text;                // Feedback category (e.g., bug report, feature request)
        rating: ?Nat;                   // Rating of the feedback response
    };

    // Storage for feedback entries
    stable var feedbacks: [Feedback] = [];

    // Function to submit feedback
    public func submitFeedback(userId: Text, message: Text, category: ?Text): async Bool {
        let newFeedback: Feedback = {
            user_id = userId;
            message = message;
            timestamp = Time.now();
            resolved = false;
            response = null;
            category = category;
            rating = null;
        };
        feedbacks := Array.append(feedbacks, [newFeedback]);
        return true;
    };

    // Function to retrieve all feedback entries (for admins)
    public query func getAllFeedback(): async [Feedback] {
        return feedbacks;
    };

    // Function to retrieve feedback submitted by a user
    public query func getUserFeedback(userId: Text): async [Feedback] {
        return Array.filter<Feedback>(feedbacks, func (feedback) { feedback.user_id == userId });
    };

    // Function to resolve feedback and provide a response
    public func resolveFeedback(feedbackIndex: Nat, response: Text): async Bool {
        switch (Array.get<Feedback>(feedbacks, feedbackIndex)) {
            case (?feedback) {
                feedbacks[feedbackIndex].resolved := true;
                feedbacks[feedbackIndex].response := ?response;
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to categorize feedback
    public func categorizeFeedback(feedbackIndex: Nat, category: Text): async Bool {
        switch (Array.get<Feedback>(feedbacks, feedbackIndex)) {
            case (?feedback) {
                feedbacks[feedbackIndex].category := ?category;
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to respond to feedback
    public func respondToFeedback(feedbackIndex: Nat, response: Text): async Bool {
        switch (Array.get<Feedback>(feedbacks, feedbackIndex)) {
            case (?feedback) {
                feedbacks[feedbackIndex].resolved := true;
                feedbacks[feedbackIndex].response := ?response;
                return true;
            };
            case null {
                return false;
            };
        };
    };

    // Function to rate feedback response
    public func rateFeedbackResponse(feedbackIndex: Nat, rating: Nat): async Bool {
        switch (Array.get<Feedback>(feedbacks, feedbackIndex)) {
            case (?feedback) {
                feedbacks[feedbackIndex].rating := ?rating;
                return true;
            };
            case null {
                return false;
            };
        };
    };
}
