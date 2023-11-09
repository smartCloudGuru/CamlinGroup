@isTest(SeeAllData = false)
public class SiteSurveyFormControllerTest {

    static Id surveyId;

    @isTest
    static void test1(){

        WorkOrder wo = makeData();
        PageReference vfp = Page.BespokeHWavailable;
        Test.setCurrentPage(vfp);

        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('workOrder', wo.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(wo);

        SiteSurveyFormController ctr = new SiteSurveyFormController();

        WorkOrder wo2 = SiteSurveyFormController.getWorkOrder(wo.Id);

        System.assertEquals(wo.Id, wo2.Id, 'WorkOrder ID');

        SiteSurveyFormController.createTaskToReviewSiteSurvey(wo2.Id);
		
        SiteSurveyFormController.createSalesSupportTask(wo.Site_Survey__c);

        SiteSurveyFormController.saveBespokeAvailabilityDate(wo2.Id, Date.today());
        
    }

    //@testSetup
    static WorkOrder makeData(){

        //OrgWideEmailAddress addr = new OrgWideEmailAddress(Address = 'someaddress@example.com');
        //insert addr;
        
        datetime dt = datetime.now();

        //User
        User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0];
        
        //Account
        Account acc = TestDataGenerator.createAccount('Acc_test', true);
        
        //Contact
        Contact con = new Contact(LastName = 'Test_Last', AccountId = acc.Id, Phone = '12345', Email = 'test@test.com', Title = 'Test');
        insert con;

        //WorkType
        WorkType wt = new WorkType(Name = 'wtTest', EstimatedDuration = 1000);
        insert wt;

        //OperatingHours
        OperatingHours oh = new OperatingHours(Name = 'testOH');
        insert oh;

        //ParentServiceTerritory
        ServiceTerritory stp = new ServiceTerritory(Account__c = acc.Id, Name = 'testParentSvcTerr'+String.ValueOf(dt), OperatingHoursId = oh.Id, IsActive = true,
        FS_Administrator__c = UserInfo.getUserId(), FS_Support_Technician__c = UserInfo.getUserId(), FS_Team_Leader__c = UserInfo.getUserId(),
        FS_Technical_Coordinator__c = UserInfo.getUserId(), Regional_Manager__c = UserInfo.getUserId());
        insert stp;

        //ChildServiceTerritory
        ServiceTerritory st = new ServiceTerritory(Account__c = acc.Id, Name = 'testChildSvcTerr'+String.ValueOf(dt), OperatingHoursId = oh.Id, IsActive = true,
        ParentTerritoryId = stp.Id);
        insert st;

        //Asset
        Asset a = new Asset(AccountId = acc.Id, Name ='test asset');
        insert a;
        
        //Price Book
        Pricebook2 pb = new Pricebook2(Name = 'Test_PB');
        insert pb;
        
        //Opportunity
        Id oppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
        
        Opportunity opp = new Opportunity(Name = 'test_opp', AccountId = acc.Id, Contact__c = con.Id,
                                          Sales_Support__c = usr.Id, Sales_Territory__c = st.Id,
                                          Delivery_Time__c = 'Standard lead time',
                                          Project_Delivery_Details__c = 'More Than 10 Units',
                                          End_User_Industry__c = 'Distribution', CurrencyIsoCode = 'GBP', 
                                          Pricebook2Id = pb.Id, StageName = 'Inactive', CloseDate = Date.today(),
                                          RecordTypeId = oppRtId, OwnerId = usr.Id);
        insert opp;

        //WorkOrder
        Id rtId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation').getRecordTypeId();

        WorkOrder wo = new WorkOrder(AccountId = acc.Id, RecordTypeId = rtId, WorkTypeId = wt.Id,
                                     ServiceTerritoryId = stp.Id, AssetId = a.Id, Opportunity__c = opp.Id,
                                     Technical_Information_Contact__c = con.id, 
                                     Responsible_Engineer_Contact__c = con.Id,
                                     Bespoke_HW_availability__c = con.Id);
        insert wo;
   
        //Site Survey with the same name as work order
        String surveyName = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :wo.Id][0].WorkOrderNumber;
        Site_Survey__c ss = new Site_Survey__c(Name = surveyName, ICAPS_Number__c = '112345', Account__c = acc.Id);
        insert ss;
        
        //Add Site Survey with the same name as work order to the Work Order
        wo.Site_Survey__c = ss.Id;
        update wo;
        
  
        return wo;
    }
    
    @IsTest
    static void testSaveChunk() {
        
        Site_Survey__c siteSurvey = new Site_Survey__c(Name = 'test_survey', Site_Name__c = 'test_site.com');
        insert siteSurvey;
        
        //Word 'test' encoded into base64
        String base64Data = 'dGVzdA==';
        
        SiteSurveyFormController.saveChunk(siteSurvey.Id, 'Test_File', base64Data, 'text/plain', true, '12345');
        
        List<Attachment> atts = [SELECT Id, Body FROM Attachment];
        
        System.assert(atts.size() == 1);
        System.assertEquals('test', atts[0].Body.toString());
    }
    
    @IsTest
    static void testGetOpportunity() {
       
        WorkOrder wo = makeData();
        Opportunity opp = SiteSurveyFormController.getOpportunity(wo.Opportunity__c);
            
        System.assertEquals(wo.Opportunity__c, opp.Id);
    }
    
    @IsTest
    static void testSetSiteSurveyId(){
        
        Site_Survey__c ss = new Site_Survey__c(Name = 'Test', Site_Name__c = 'test_site.com');
        insert ss;
        
        //WorkOrder wo = makeData();
        WorkOrder wo = TestDataGenerator.createDataWithWorkOrder();
        
        Exception ex = null;
        
        //Code in 'try' block is called successfully
        try {
        	SiteSurveyFormController.setSiteSurveyId(wo.Id, ss.Id);
        } catch (AuraHandledException e) {
            ex = null; 
        }
        
        //Throw error
        try {
            SiteSurveyFormController.setSiteSurveyId(wo.Id, 'badId');
        } catch (AuraHandledException e) {
            ex = e;
        }
   		System.Debug('Site Survey ID Check: '+ss.Id);
        System.assertEquals(ss.Id, [SELECT Id, Site_Survey__c FROM WorkOrder WHERE Site_Survey__c = :ss.Id][0].Site_Survey__c);
        System.assert(ex != null);
        System.assert(ex instanceof AuraHandledException);
    }
    
    @IsTest
    static void testSendBespokeAvailableEmail() {
        
        WorkOrder wo = makeData();
        SiteSurveyFormController.sendBespokeAvailableEmail(wo.Id);
        
        System.assertEquals(1, Limits.getEmailInvocations());
        System.assertEquals(Date.today(), [SELECT Bespoke_HW_requested__c FROM WorkOrder][0].Bespoke_HW_requested__c);
    }
    
    @IsTest
    static void testSentSurveyEmail() {
        
        WorkOrder wo = makeData();
        SiteSurveyFormController.sentSurveyEmail(wo.Id);
        
        WorkOrder updatedWO = [SELECT Site_Survey_Send__c, Survey_Sent_Remind_Date__c FROM WorkOrder][0];
        
        System.assertEquals(1, Limits.getEmailInvocations());
        System.assertEquals(Date.today(), updatedWO.Site_Survey_Send__c);
        System.assertEquals(Date.today(), updatedWO.Survey_Sent_Remind_Date__c);
    }
    
    @IsTest
    static void testSendIcapsNumberEmail() {
        
        WorkOrder wo = makeData();
        
        Attachment att = new Attachment(Name = 'Test', Body = Blob.valueOf('test'), ParentId = wo.Site_Survey__c);
        insert att;
        
        SiteSurveyFormController.sendIcapsNumberEmail(wo.Id);
        
        System.assertEquals(1, Limits.getEmailInvocations());
        System.assertEquals(Date.today(), [SELECT Sent_to_Engineer_Date__c FROM WorkOrder][0].Sent_to_Engineer_Date__c);
    }
    
    @IsTest
    static void testGetFieldSetFields() {
        
        Map<String, Schema.FieldSet> fieldSetMap = Site_Survey__c.SObjectType.getDescribe().fieldSets.getMap();
        List<String> fieldSetNameList = new List<String>();
        
        for(String fieldSet : fieldSetMap.keySet()) {
            fieldSetNameList.add(fieldSet);
        }
  
        SiteSurveyFormController.getFieldSetFields(fieldSetNameList);
    }
}