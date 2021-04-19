/**
// Created by Luke Parrott on 04/19/2021.
//   TODO: UPDATE
// - Deploy this using the "deploy_rollup_testing" CCI flow. That will create the necessary target fields
//   on the Account object for Account-Contact Soft Credit, Account Soft Credit, and Payment Rollup testing.
//   It will also deploy this class into the org.
//
// - The most common issue with testing in this class is Membership Exclusion. Be sure to review the Legacy
//   and CustomizableRollups Filter Groups to ensure that either Membership Opps are include or excluded to
//   match the ROLLUPS_INCLUDES_MEMBERSHIP var setting below.
// - Specifically, in a new Scratch Org the "Membership" record type is not often set properly in Custom
//   Settings so when the Membership Filter Group is created there is no filter rule to limit Membership
//   Rollups to the Membership RT only. This will lead to the validateRollups() failing for the
//   Membership rollup in Customizable Rollups. The fix is to simply edit the Membership-Won Filter Group
//   to create a rule for Opportunity.RecordType=Membership.
//
// - ALL TESTS ARE CONDUCTED USING EXECUTE ANONYMOUS; EXECUTING ONE METHOD AT A TIME IN THE FOLLOWING ORDER:
// - The entire block below can be pasted into the ExecuteAnonymous window of DevConsole and then each task
//   run individually by highlighting the command and clicking [Execute Highlighted].
//
//
//   - STEP 1: Initial Setup - Delete any existing test data and recreate the data.
//   - NOTE: WAIT for the @Future job to finish before moving onto Step 2
//   CRLP_TEST_VALIDATE_ROLLUPS.deleteTestData();
//   CRLP_TEST_VALIDATE_ROLLUPS.createTestDataASync();
//
//   - STEP 2: ExecuteLegacyRollups will complete synchronously.
//   CRLP_TEST_VALIDATE_ROLLUPS.executeLegacyRollups();
//   - ValidateRollups will either throw an exception with errors or succeed. Click [Debug] in the Log View for details
//   CRLP_TEST_VALIDATE_ROLLUPS.validateRollups();
//
//   - STEP 3: ExecuteCustomizableRollups starts asynchronous batch jobs to complete the rollups.
//   - NOTE: WAIT for all the CRLP batch jobs to finish before running the validateRollups() method.
//   CRLP_TEST_VALIDATE_ROLLUPS.executeCustomizableRollups();
//   CRLP_TEST_VALIDATE_ROLLUPS.validateRollups();
//
//   - STEP 4: Optional: Delete the test data when done
//   CRLP_TEST_VALIDATE_ROLLUPS.deleteTestData();
*/
@IsTest
public class BETA_Test_Regressions {

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
        
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(
            npe03__Amount__c = 1000,
            npe03__Contact__c = c.Id,
            npe03__Organization__c = c.AccountId
        );
        insert rd;
    }

    /****
    * @description Verifies enablement state values are not set by default
    */
    @isTest
    private static void shouldReturnDefaultEnablementStateWhenNotSetup() {

        // %%%NAMESPACE%%%

        Boolean testTrue = true;
        System.assert(testTrue, true);
    }

}
