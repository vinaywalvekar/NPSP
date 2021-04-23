/**
 * @description Queueable service to make callouts to Elevate payment services and cancel commitments
 */
public class CancelCommitmentService extends DPQ_QueueableBase {
    List<RD2_CancelCommitmentService.RecordWrapper> commitmentRDs;

    /**
    * @description Constructor
    * @param closedRDs Closed Recurring Donations containing Commitment Id
    */
    public CancelCommitmentService(List<RD2_CancelCommitmentService.RecordWrapper> closedRDs) {
        this.commitmentRDs = closedRDs;
    }

    /**
     * @description Cancel Commitments in Elevate payment services
     * @param context queueableContext
     */
    public void execute(QueueableContext context) {
        executeCancelCommitments();

        if (this.dpqJob != null) {
            markJobComplete();
            launchManager();
        }
    }

    /**
     * @description Cancel Commitments in Elevate payment services
     */
    public void executeCancelCommitments() {
        if (commitmentRDs == null || commitmentRDs.isEmpty()) {
            return;
        }

        new RD2_CancelCommitmentService()
            .cancelCommitments(commitmentRDs);
    }
}
