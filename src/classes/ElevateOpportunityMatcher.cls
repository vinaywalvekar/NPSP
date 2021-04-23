/**
 * @description Queueable service to process inserted Recurring Donations that have a value
 * in the Elevate CommitmentId__c field.
 */
public class ElevateOpportunityMatcher extends DPQ_QueueableBase {
    Map<String, Id> rdIdByCommitmentId;

    /***
     * @description Constructor
     * @param rdIdByCommitmentId - Map of CommitmentId's to RecurringDonation.Id
     */
    public ElevateOpportunityMatcher(Map<String, Id> rdIdByCommitmentId) {
        this.rdIdByCommitmentId = rdIdByCommitmentId;
    }

    /**
     * @description Execute method called when the Queueable runs. Delegates to the
     * evaluation service
     * @param context queuableContext
     */
    public void execute(QueueableContext context) {
        if (rdIdByCommitmentId == null || rdIdByCommitmentId.isEmpty()) {
            return;
        }

        match();

        if (this.dpqJob != null) {
            markJobComplete();
            launchManager();
        }
    }

    /**
     * @description Delegate processing of the Recurring Donations to the Evaluation Service
     */
    public void match() {
        new RD2_ElevateIntegrationService()
            .matchRecurringDonationsToOpps(rdIdByCommitmentId);
    }
}
