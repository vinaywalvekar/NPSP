*** Settings ***

Resource        robot/Cumulus/resources/NPSP.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Cumulus/resources/GiftEntryPageObject.py
...             robot/Cumulus/resources/OpportunityPageObject.py
...             robot/Cumulus/resources/PaymentPageObject.py
...             robot/Cumulus/resources/AccountPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
...             Enable Gift Entry
...             Setup Test Data
Suite Teardown  Capture Screenshot and Delete Records and Close Browser

*** Keywords ***
Setup Test Data
    &{account} =         API Create Organization Account    Name=${faker.company()}
    Set suite variable   &{ACCOUNT}
    ${fut_date} =            Get Current Date         result_format=%Y-%m-%d    increment=2 days
    Set suite variable   ${FUT_DATE}
    ${cur_date} =            Get Current Date         result_format=%Y-%m-%d    
    Set suite variable   ${CUR_DATE}
    &{opportunity} =     API Create Opportunity   ${ACCOUNT}[Id]              Donation  
    ...                  StageName=Prospecting    
    ...                  Amount=500    
    ...                  CloseDate=${FUT_DATE}    
    ...                  npe01__Do_Not_Automatically_Create_Payment__c=false    
    ...                  Name=${ACCOUNT}[Name] Donation
    Set suite variable   &{OPPORTUNITY}
    ${ui_date} =         Get Current Date                   result_format=%b %-d, %Y
    Set suite variable   ${UI_DATE}
    &{payment} =         API Query Record         npe01__OppPayment__c      npe01__Opportunity__c=${OPPORTUNITY}[Id]
    Set suite variable   &{PAYMENT}
    ${ns} =              Get NPSP Namespace Prefix
    Set suite variable   ${NS}

*** Test Cases ***
Review Donation And Update Payment For Batch Gift
    [Documentation]                      Create an organization account with open opportunity (with payment record) via API. Go to SGE form
    ...                                  select the donor as account and the account created. Verify review donations modal and select to update payment.
    ...                                  Change date to today and payment amount to be less than opp amount. Verify that same payment record got updated
    ...                                  with new amount and date but opportunity is still prospecting and amount is not updated.
    [tags]                               unstable      feature:GE                    W-042803   
    #verify Review Donations link is available and update a payment                           
    Go To Page                           Landing                       GE_Gift_Entry         
    Click Gift Entry Button              New Batch
    Wait Until Modal Is Open
    Select Template                      Default Gift Entry Template
    Load Page Object                     Form                          Gift Entry
    Fill Gift Entry Form
    ...                                  Batch Name=${ACCOUNT}[Name]Automation Batch
    ...                                  Batch Description=This is a test batch created via automation script
    Click Gift Entry Button              Next
    Click Gift Entry Button              Save
    Current Page Should Be               Form                          Gift Entry
    ${batch_id} =                        Save Current Record ID For Deletion     ${NS}DataImportBatch__c
    Fill Gift Entry Form
    ...                                  Donor Type=Account1
    ...                                  Existing Donor Organization=${ACCOUNT}[Name]
    Click Button                         Review Donations
    Wait Until Modal Is Open
    Click Button                         Update this Payment
    Wait Until Modal Is Closed 
    Fill Gift Entry Form                 
    ...                                  Donation Amount=499.50
    ...                                  Donation Date=Today
    Click Button                         Save & Enter New Gift
    #verify donation date and amount values changed on table
    Verify Gift Count                    1
    Verify Table Field Values            Batch Gifts
    ...                                  Donor Name=${ACCOUNT}[Name]
    ...                                  Donation Amount=$499.50
    ...                                  Donation Name=${PAYMENT}[Name]
    ...                                  Donation Date=${UI_DATE}
    Click Gift Entry Button              Process Batch
    Click Data Import Button             NPSP Data Import                button       Begin Data Import Process
    Wait For Batch To Process            BDI_DataImport_BATCH            Completed
    Click Button With Value              Close
    #verify same payment record is updated and paid but opportunity values did not change
    Verify Expected Values               nonns                          Opportunity    ${OPPORTUNITY}[Id]
    ...                                  Amount=500.0
    # check if this date should be updated or not, noticing update when tested
    ...                                  CloseDate=${CUR_DATE}
    ...                                  StageName=Prospecting
    Verify Expected Values               nonns                          npe01__OppPayment__c    ${PAYMENT}[Id]
    ...                                  npe01__Payment_Amount__c=499.5
    ...                                  npe01__Payment_Date__c=${CUR_DATE}
    ...                                  npe01__Paid__c=True
    