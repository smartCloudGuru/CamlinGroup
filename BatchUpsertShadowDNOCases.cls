public class BatchUpsertShadowDNOCases {
    
    public BatchUpsertShadowDNOCases() {
        
    }
    
    public Integer runBatch() {
        // returns the number of DNO Cases created
        Integer i = 0;
        // Get list of all DNO_Case "Names"
        List<DNO_Case__c> existingShadowCases = [SELECT Id, Name from DNO_Case__c];
        List<String> shadowCaseNames = new List<String>();
        for (DNO_Case__c sc : existingShadowCases) {
            shadowCaseNames.add(sc.Name);
        }
        
        List<Case> allFaultAssistanceCasesWithoutShadow = [SELECT Id, AccountName__c, CaseNumber, Description, OwnerId from Case WHERE Type = 'Fault Assistance' LIMIT 99];// AND CaseNumber NOT IN :shadowCaseNames LIMIT 99];
        i = allFaultAssistanceCasesWithoutShadow.size();
        
        // now we can create all shadow cases
        for (Case c : allFaultAssistanceCasesWithoutShadow) {
            DNO_Case__c shadow = new DNO_Case__c(
            	Customer_Name__c = c.AccountName__c,
                FAC_Case_Number__c = c.Id,
                Description__c = c.Description,
                Name = c.CaseNumber,
                OwnerId = c.OwnerId
            );
            upsert shadow;
            
        }
        
        return i;
    }

}