/*
 * Created by Oleg Bogdanovych on 21/11/2019.
 */
global without sharing class RAAcknowledgmentController {
    public Id riskAssessmentId {get; set;}
    
    public RAAcknowledgmentController() {
		riskAssessmentId  = ApexPages.CurrentPage().getparameters().get('ra');
	}
    
    @AuraEnabled
    public static Risk_Assessment__c getRiskAssessment (String raId) {
        return [SELECT Acknowledged_by_Customer__c FROM Risk_Assessment__c WHERE Id = :raId];
    }
    
	@AuraEnabled
    public static void acknowledgeRA (String raId) {
        Risk_Assessment__c ra = [
            SELECT
            	Id, Acknowledged_by_Customer__c, Acknowledged_By__c, Acknowledgment_Date__c
            FROM Risk_Assessment__c
            WHERE Id = :raId
        ];
        
        ra.Acknowledged_by_Customer__c = true;
        ra.Acknowledgment_Date__c = Date.today();
        
        update ra;
    }
}