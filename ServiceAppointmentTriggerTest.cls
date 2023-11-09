@isTest
public class ServiceAppointmentTriggerTest {
    
    @isTest
    static void test1(){
        
        ServiceAppointment sa = makeData();
        
        ServiceAppointmentHelper.recalculateMultidayWork(new List<ServiceAppointment>{sa});
    }

    //@testSetup
    static ServiceAppointment makeData(){

        //Account
        Account acc = TestDataGenerator.createAccount('Acc_test', true);
        
        //WorkType
        WorkType wt = new WorkType(Name = 'wtTest', EstimatedDuration = 1000);
        insert wt;
        
        //OperatingHours
        OperatingHours oh = new OperatingHours(Name = 'testOH');
        insert oh;

        //ServiceTerritory
        ServiceTerritory st = new ServiceTerritory(Account__c = acc.Id, Name = 'testSvcTerr', OperatingHoursId = oh.Id, IsActive = true);
        insert st;

        //Asset
        Asset a = new Asset(AccountId = acc.Id, Name ='test asset');
        insert a;
        
        //WorkOrder
        Id rtId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation').getRecordTypeId();
        
        WorkOrder wo = new WorkOrder(AccountId = acc.Id, RecordTypeId = rtId, WorkTypeId = wt.Id, ServiceTerritoryId = st.Id, AssetId = a.Id);
        insert wo;

      	//ServiceAppointment
        ServiceAppointment sa = new ServiceAppointment( ParentRecordId = wo.Id);
        insert sa;
        
        return sa;
    }
}