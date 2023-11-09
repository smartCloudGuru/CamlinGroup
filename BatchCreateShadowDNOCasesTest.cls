@isTest
private class BatchCreateShadowDNOCasesTest {
    private static testmethod void validateBatchShadowsCreated() {

        Account acc = TestDataGenerator.createAccount('Acc', true);//AG
        Case cs = TestDataGenerator.createCase('Fault Assistance', acc.Id, true);//AG

        //Case cs = new Case( Type = 'Fault Assistance', Description = 'BATCH TEST');//AG
        //insert cs;//AG
        
        System.debug('New case created: ' + cs.CaseNumber);
        
        BatchCreateShadowDNOCases batch = new BatchCreateShadowDNOCases();
        Integer numRecords = batch.runBatch();
        
        System.debug('batch run and returned ' + numRecords + ' records');
        
        List<DNO_Case__c> newDNOCaseName = [Select Id, Name from DNO_Case__c WHERE Name = :cs.CaseNumber];
        System.assertNotEquals(newDNOCaseName, null);
    }
}