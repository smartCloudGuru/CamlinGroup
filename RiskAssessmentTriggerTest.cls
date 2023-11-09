@IsTest
public class RiskAssessmentTriggerTest {

    @IsTest
    static void testSendEmail() {
        
        Contact con = new Contact(LastName = 'Test', Email = 'test@mail.com');
        insert con;
        Risk_Assessment__c ra = new Risk_Assessment__c(Acknowledged_By__c = con.id);
        insert ra;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test', 
            PathOnClient = 'Test.jpg', 
            VersionData = Blob.valueOf('Test Content'), 
            IsMajorVersion = true); 
        insert cv;
        
        List<ContentDocument> cdlist = [SELECT Id FROM ContentDocument];
        ContentDocumentLink cdLink = new ContentDocumentLink(LinkedEntityId = ra.Id, ContentDocumentId = cdList[0].Id);
        insert cdLink;
        
        ra.Completed__c = true;
        update ra;
        
        List<ContentDocumentLink> cdLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ra.Id];
        
        Integer emailInvocations = Limits.getEmailInvocations();
        System.assertEquals(cdLinks.size(), emailInvocations);
    }   
}