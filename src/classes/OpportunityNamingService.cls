/**
 * @description Queueable service to recalculate Opportunity names
 */
public class OpportunityNamingService extends DPQ_QueueableBase {
    List<Opportunity> updatedOpps;

    /**
    * @description Constructor
    * @param updatedOpps Updated opportunities
    */
    public OpportunityNamingService(List<Opportunity> updatedOpps) {
        this.updatedOpps = updatedOpps;
    }

    /**
     * @description Update opportunity names
     * @param context queueableContext
     */
    public void execute(QueueableContext context) {
        refreshOppNames();
    }

    /**
     * @description Update opportunity names
     */
    public void refreshOppNames() {
        if (updatedOpps == null || updatedOpps.isEmpty()) {
            return;
        }

        Map<Id, String> oppNameById = new Map<Id, String>();
        for (Opportunity opp: updatedOpps) {
            oppNameById.put(opp.Id, opp.Name);
        }

        OPP_OpportunityNaming.refreshOppNames(updatedOpps);

        List<Opportunity> renamedOpps = new List<Opportunity>();
        for (Opportunity opp: updatedOpps) {
            if (!opp.Name.equalsIgnoreCase(oppNameById.get(opp.Id))) {
                renamedOpps.add(opp);
            }
        }

        TDTM_ProcessControl.toggleTriggerState('Opportunity', 'RD2_RecurringDonationsOpp_TDTM', false);
        update renamedOpps;
    }
}
