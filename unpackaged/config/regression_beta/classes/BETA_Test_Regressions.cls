/**

    A Test class to be run against a manged Beta after it is created.

*/
@IsTest
public class BETA_Test_Regressions {

    private static Decimal rdAmount = 10;
    private static String closedStage = 'Closed Won';
    private static String pledgedStage = 'Pledged';
    private static Date today = System.today();

    /****
    * @description Creates data required for unit tests
    */
    @TestSetup
    private static void setUp() {
        Contact c = new Contact(
            FirstName = 'Tester', 
            Lastname = 'Beta'
        );
        insert c;

        npe03__Recurring_Donation__c rd = createRD(rdAmount, c.Id, c.AccountId, '15');
        insert rd;

        List<Opportunity> oppList = new List<Opportunity>();

        // Note: The RD will create an Open Opportunity for the 15th of next month
        oppList.add(createOpp('Open Today', rdAmount, today, rd.Id, 
            c.AccountId, c.Id, pledgedStage));
        oppList.add(createOpp('Open Past', rdAmount, today.addDays(-10), rd.Id, 
            c.AccountId, c.Id, pledgedStage));
        oppList.add(createOpp('Closed Past', rdAmount, today.addDays(-20), rd.Id, 
            c.AccountId, c.Id, closedStage));
        insert oppList;
    }

    /****
    * @description TODO
    */
    @isTest
    private static void rdAndOppShouldBeCreated() {

        List<npe03__Recurring_Donation__c> rdList = getRds();
        System.assert(rdList.size() > 0, true);

        npe03__Recurring_Donation__c rd = rdList[0];
        System.assertEquals(rd.npe03__Amount__c, rdAmount, 'RD Amount is wrong');

        // Ordered from earliest to latest CloseDate
        List<Opportunity> opps = getOpps(rd.Id);
        System.assertEquals(opps.size(), 4);

        Opportunity closedOpp = opps[0];
        System.assertEquals(closedOpp.Amount, rdAmount, 'Opp Amount is wrong');
        System.assertEquals(closedOpp.StageName, closedStage, 'Opp should be closed');

        Opportunity todayOpp = opps[2];
        System.assertEquals(todayOpp.CloseDate, today, 'This opp should be for today');
    }

    /****
    * Helper Methods
    */
    private static npe03__Recurring_Donation__c createRD(Decimal amount, Id contactId, 
        Id accountId, String dayOfMonth){

            return new npe03__Recurring_Donation__c(
                npe03__Amount__c = amount,
                npe03__Contact__c = contactId,
                npe03__Organization__c = accountId,
                Day_of_Month__c = dayOfMonth
            );
    }

    private static Opportunity createOpp(String name, Decimal amount, Date closeDate,
        Id rdId, Id accountId, Id contactId, String stage){

            return new Opportunity(
                Name = name,
                Amount = amount,
                AccountId = accountId,
                Primary_Contact__c = checkNullId(contactId),
                npe03__Recurring_Donation__c = rdId,
                StageName = stage,
                CloseDate = (closeDate != null) ? closeDate : today
            );
    }

    private static Id checkNullId(Id recordId){
        return (recordId != null) ? recordId : null;
    }

    private static List<npe03__Recurring_Donation__c> getRds(){
        // TODO: Add %%%NAMESPACE%%%
        return [SELECT Id, npe03__Amount__c, npe03__Contact__c, Day_of_Month__c
            FROM npe03__Recurring_Donation__c];
    }

    private static List<Opportunity> getOpps(Id rdId){
        return [SELECT Id, Amount, CloseDate, StageName
            FROM Opportunity
            WHERE npe03__Recurring_Donation__c =: rdId
            ORDER BY CloseDate asc];
    }

}
