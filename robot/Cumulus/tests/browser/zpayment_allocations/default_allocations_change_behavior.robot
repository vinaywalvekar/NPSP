*** Settings ***
Resource        robot/Cumulus/resources/NPSP.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Cumulus/resources/OpportunityPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Run keywords
...             API Modify Allocations Setting  ${NS}Default_Allocations_Enabled__c=false    ${NS}Payment_Allocations_Enabled__c=false   ${NS}Default__c=None
...  AND        Capture Screenshot and Delete Records and Close Browser

*** Variables ***
&{contact1_fields}         Email=test@example.com
&{contact2_fields}         Email=test@example.com
&{opportunity1_fields}     Type=Donation   Name=$0 opp with default allocations enabled     Amount=0    StageName=Prospecting   npe01__Do_Not_Automatically_Create_Payment__c=false
&{opportunity2_fields}     Type=Donation   Name=$0 opp with default allocations disabled    Amount=0    StageName=Prospecting   npe01__Do_Not_Automatically_Create_Payment__c=false

*** Test Cases ***
Allocations Behavior when $0 with Default Allocations Enabled
    [Documentation]             Enable payment allocation and make sure default allocations are enabled
    ...                         Create a $0 opportunity.Default GAU allocation should still be created for opportunity.
    [tags]                      unstable     W-035595    feature:payment_allocations
    API Modify Allocations Setting
    ...                         ${NS}Default_Allocations_Enabled__c=true
    ...                         ${NS}Default__c=${DEF_GAU}[Id]
    ...                         ${NS}Payment_Allocations_Enabled__c=true
    Setupdata                   contact1            ${contact1_fields}     ${opportunity1_fields}
    Go To Page                  Detail
    ...                         Opportunity
    ...                         object_id=${data}[contact1_opportunity][Id]
    Select Tab                  Related
    Verify Allocations          GAU Allocations
    ...                         ${DEF_GAU}[Name]=$0.00

Allocations Behavior when $0 with Default Allocations Disabled
    [Documentation]             Enable payment allocation and make sure default allocations are DISABLED. Create a $0 opportunity
    ...                         Add a GAU with 100% and verify that GAU allocation is still there on Opportunity after save
    [tags]                      unstable    W-035647    feature:Payment Allocations
    API Modify Allocations Setting
    ...                         ${NS}Default_Allocations_Enabled__c=false
    ...                         ${NS}Default__c=${DEF_GAU}[Id]
    ...                         ${NS}Payment_Allocations_Enabled__c=true
    Setupdata                   contact2                    ${contact2_fields}     ${opportunity2_fields}
    &{allocation} =             API Create GAU Allocation   ${GAU}[Id]             ${data}[contact2_opportunity][Id]
    ...                         ${NS}Percent__c=0.0
    Go To Page                  Detail
    ...                         Opportunity
    ...                         object_id=${data}[contact2_opportunity][Id]
    Select Tab                  Related
    Verify Allocations          GAU Allocations
    ...                         ${GAU}[Name]=0.000000%

Setup Test Data
    [Documentation]     Creates the GAUs needed for Test
    &{DEF_GAU} =  API Create GAU    Name=default gau
    Set suite variable              &{DEF_GAU}
    &{GAU} =      API Create GAU
    Set suite variable              &{GAU}
    ${NS} =       Get Npsp Namespace Prefix
    Set suite variable              ${NS}