/**
 * @description Queueable service to process Installment Opportunities for a Recurring Donation
 * that was inserted or modified.
 */
public class EvaluateInstallmentOpportunities extends DPQ_QueueableBase {
    Set<Id> rdIds;

    /**
    * @description Contains Recurring Donation Ids for which schedule has been changed
    */
    @TestVisible
    private Set<Id> rdIdsWhereScheduleChanged {
        get {
            if (rdIdsWhereScheduleChanged == null) {
                rdIdsWhereScheduleChanged = new Set<Id>();
            }
            return rdIdsWhereScheduleChanged;
        } set;
    }

    /***
     * @description Constructor
     * @param rdIds - the RD Ids to process in this Queueable action
     */
    public EvaluateInstallmentOpportunities(Set<Id> rdIds) {
        this.rdIds = rdIds;
    }

    /***
     * @description Constructor
     * @param rdIds - the RD Ids to process in this Queueable action
     * @param rdIdsWhereScheduleChanged - Ids of Recurring Donations that have a changed schedule
     */
    public EvaluateInstallmentOpportunities(Set<Id> rdIds, Set<Id> rdIdsWhereScheduleChanged) {
        this.rdIds = rdIds;
        this.rdIdsWhereScheduleChanged = rdIdsWhereScheduleChanged;
    }

    /**
     * @description Execute method called when the Queueable runs. Delegates to the
     * evaluation service
     * @param context queuableContext
     */
    public void execute(QueueableContext context) {
        if (rdIds == null || rdIds.isEmpty()) {
            return;
        }

        executeOppEvaluationService();

        if (this.dpqJob != null) {
            markJobComplete();
            launchManager();
        }
    }

    /**
     * @description Delegate processing of the Recurring Donations to the Evaluation Service
     */
    public void executeOppEvaluationService() {
        new RD2_OpportunityEvaluationService()
            .withRds(rdIds)
            .withScheduleChanged(rdIdsWhereScheduleChanged)
            .evaluateOpportunities();
    }
}
