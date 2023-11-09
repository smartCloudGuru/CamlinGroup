@isTest
public class ExtendedWarrantyControllerTest {

    
    @isTest
    static void test1(){

        String warrantyId = [SELECT Id FROM Extended_Warranty__c LIMIT 1].Id;

        Test.startTest();

        List<ExtendedWarrantyController.AssetWrapper> awl = ExtendedWarrantyController.getAssets(warrantyId);

        awl[0].isSelected = true;
        awl[0].isMapped = false;

        awl[1].isSelected = false;
        awl[1].isMapped = true;
        
        String awlstr = JSON.serialize(awl);
        
        Date startDate = Date.today().addDays(-7);
        Date endDate = Date.today().addDays(1);
        
        String startDateString = String.valueOf(startDate);
        String endDateString = String.valueOf(endDate);

        ExtendedWarrantyController.getSelectedAssets(warrantyId);
        ExtendedWarrantyController.getAvailableAssets(warrantyId, startDateString, endDateString);
        ExtendedWarrantyController.saveWarrantyItems(warrantyId, awlstr, startDateString, endDateString);

        Test.stopTest();

    }

    @IsTest
    static void testGetSelectedAssets() {

    }

    @testSetup
    static void makeData(){

        Date startDate = Date.today();
        Date endDate = Date.today().addDays(7);

        //Account
        Account acc = TestDataGenerator.createAccount('Acc', true);

        //Extended_Warranty__c
        Extended_Warranty__c ew = new Extended_Warranty__c(Account__c = acc.Id);
        Extended_Warranty__c ew2 = new Extended_Warranty__c(Account__c = acc.Id);
        insert ew;
        insert ew2;

        //Asset
        Asset a1 = new Asset(AccountId = acc.Id, Name ='test asset2');
        Asset a2 = new Asset(AccountId = acc.Id, Name ='test asset2');
        Asset a3 = new Asset(AccountId = acc.Id, Name ='test asset2');
        Asset a4 = new Asset(AccountId = acc.Id, Name ='test asset2');
        List<Asset> assets = new List<Asset>{a1,a2, a3, a4};
        insert assets;

        //Extended_Warranty_Item__c
        Extended_Warranty_Item__c ewi1 = new Extended_Warranty_Item__c(Extended_Warranty__c = ew.Id, Asset__c = a1.Id, Start_Date__c = startDate, End_Date__c = endDate);
        Extended_Warranty_Item__c ewi2 = new Extended_Warranty_Item__c(Extended_Warranty__c = ew.Id, Asset__c = a2.Id, Start_Date__c = startDate, End_Date__c = endDate);
        Extended_Warranty_Item__c ewi3 = new Extended_Warranty_Item__c(Extended_Warranty__c = ew2.Id, Asset__c = a3.Id, Start_Date__c = startDate, End_Date__c = endDate);
        Extended_Warranty_Item__c ewi4 = new Extended_Warranty_Item__c(Extended_Warranty__c = ew2.Id, Asset__c = a4.Id, Start_Date__c = startDate, End_Date__c = endDate);
        List<Extended_Warranty_Item__c> ewilist = new List<Extended_Warranty_Item__c>{ewi1, ewi2, ewi3, ewi4};
        insert ewilist;
    }
}