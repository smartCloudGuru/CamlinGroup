@isTest
public class TechSupportTriggerTest {

    @isTest
    static void test1(){
        Tech_Support__c ts  = makeData();

        ts.Status__c = 'Open';
        update ts;
    }

    //@testSetup
    static Tech_Support__c makeData(){

        //Account
        Account acc = TestDataGenerator.createAccount('Acc_test', true);
        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'TestOpp', StageName = 'Opportunity', CloseDate = Date.today() + 10);
        insert opp;

        //ServiceAppointment
        Tech_Support__c ts = new Tech_Support__c(Opportunity__c = opp.Id);
        insert ts;

        return ts;

    }
}