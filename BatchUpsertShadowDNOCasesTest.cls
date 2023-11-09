@isTest
private class BatchUpsertShadowDNOCasesTest {
    private static testmethod void validateBatchShadowsUpserted() {

        Account acc = TestDataGenerator.createAccount('Acc', true);//AG
        Case cs = TestDataGenerator.createCase('Fault Assistance', acc.Id, true);//AG
        //Case cs = new Case( Type = 'Fault Assistance', Description = 'BATCH TEST');
        //insert cs;
        
        System.debug('New case created: ' + cs.CaseNumber);
        
        BatchUpsertShadowDNOCases batch = new BatchUpsertShadowDNOCases();
        Integer numRecords = batch.runBatch();
        
        System.debug('batch run and returned ' + numRecords + ' records');
        
        List<DNO_Case__c> newDNOCaseName = [Select Id, Name from DNO_Case__c WHERE Name = :cs.CaseNumber];
        System.assertNotEquals(newDNOCaseName, null);
    }
}