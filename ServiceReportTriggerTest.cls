@IsTest
private class ServiceReportTriggerTest {
	@isTest
	public static void serviceReportTest() {
		Account acc = TestDataGenerator.createAccount('Acc_test', true);

		Contact cont = new Contact(LastName = 'testContact', AccountId = acc.Id, Email = 'someDemoemail@email.co');
		insert cont;

		WorkType wt = new WorkType(Name = 'wtTest', EstimatedDuration = 1000);
		insert wt;

		//OperatingHours
		OperatingHours oh = new OperatingHours(Name = 'testOH');
		insert oh;

		//ServiceTerritory
		ServiceTerritory st = new ServiceTerritory(Account__c = acc.Id, Name = 'testSvcTerr', OperatingHoursId = oh.Id, IsActive = true,
				FS_Administrator__c = UserInfo.getUserId(), FS_Support_Technician__c = UserInfo.getUserId(), FS_Team_Leader__c = UserInfo.getUserId(),
				FS_Technical_Coordinator__c = UserInfo.getUserId(), Regional_Manager__c = UserInfo.getUserId());
		insert st;

		//Asset
		Asset a = new Asset(AccountId = acc.Id, Name ='test asset');
		insert a;

		//Site_Survey__c
		Site_Survey__c ss = new Site_Survey__c(Name ='sstest', ICAPS_Number__c = '112345', Account__c = acc.Id);
		insert ss;

		//WorkOrder
		Id rtId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation').getRecordTypeId();

		WorkOrder wo = new WorkOrder(AccountId = acc.Id, RecordTypeId = rtId, WorkTypeId = wt.Id, ServiceTerritoryId = st.Id, AssetId = a.Id,
				Site_Survey__c = ss.Id, ContactId = cont.Id);
		insert wo;

		ServiceAppointment sa = new ServiceAppointment(ParentRecordId = wo.Id, Subject = 'testSA', ServiceTerritoryid = st.Id,
			EarliestStartTime = Date.today(), DueDate = Date.Today() + 10);
		insert sa;

		Test.startTest();
			ContentVersion contentVersion = new ContentVersion(
				Title = 'Penguins',
				PathOnClient = 'Penguins.jpg',
				VersionData = Blob.valueOf('Test Content'),
				IsMajorVersion = true
			);
			insert contentVersion;
			List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

			//create ContentDocumentLink  record
			ContentDocumentLink cdl = New ContentDocumentLink();
			cdl.LinkedEntityId = WO.id;
			cdl.ContentDocumentId = documents[0].Id;
			cdl.shareType = 'V';
			insert cdl;

			List<ServiceReportLayout> template = [SELECT DeveloperName,Id FROM ServiceReportLayout LIMIT 1];

			ServiceReport sr = new ServiceReport();
			//sr.ContentVersionDocumentId = documents[0].Id;
			sr.DocumentBody = Blob.valueOf('Test Content') ;
			sr.DocumentContentType ='application/pdf';
			sr.DocumentName='Test';
			sr.Template = template[0].Id;
			sr.ParentId = sa.Id ;
			insert sr ;
		Test.stopTest();
	}
}