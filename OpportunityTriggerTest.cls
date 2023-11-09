@isTest(SeeAllData= false)
public class OpportunityTriggerTest {
    
    @isTest
    static void test1(){

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();

        opp.Max_distance_between_oil_valves__c = 'Yes';
        update opp;

       
        Test.stopTest();

    }

    @testSetup
    static void makeData(){

        //Account
        Account acc = TestDataGenerator.createAccount('Acc_test', true);

        //Opportunity
        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'testopp',  StageName= 'Opportunity', CloseDate = Date.today().addMonths(1));
        insert opp;

        //Tech_Support__c ts = new Tech_Support__c();
        //insert ts;
    }
}