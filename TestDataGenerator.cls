public class TestDataGenerator {

    public static Schema.Location createTestLocation(String name, Boolean isInventoryLocation, Boolean isMobile, Boolean isInsert) {
        Schema.Location location = new Schema.Location(
                                    Name = name,
                                    IsInventoryLocation = isInventoryLocation,
                                    IsMobile = isMobile);

        if (isInsert) {
            insert location;
        }
        return location;
    }

    public static User createTestUser(String lastName, Boolean isInsert) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user = new User(
                        ProfileId = p.Id,
                        Alias = 'stand',
                        Email ='standarduser@test.com',
                        LastName = lastName,
                        UserName = lastName + '@test.com',
                        TimeZoneSidKey='America/Los_Angeles',
                        LocaleSidKey='en_US',
                        EmailEncodingKey='UTF-8',
                        LanguageLocaleKey='en_US');

        if (isInsert) {
            insert user;
        }
        return user;
    }

    public static ServiceResource createTestServiceResource(Id relatedRecordId, String name, Boolean isActive, Id locationId, Boolean isInsert) {
        ServiceResource serviceResource = new ServiceResource(
                                            RelatedRecordId = relatedRecordId,
                                            Name = name,
                                            IsActive = isActive,
                                            LocationId = locationId);

        if (isInsert) {
            insert serviceResource;
        }
        return serviceResource;
    }

    public static Product2 createTestProduct(String name, String productCode, Boolean isInsert) {
        Product2 product = new Product2(
                            Name = name,
                            ProductCode = productCode,
                            IsActive = true);

        if (isInsert) {
            insert product;
        }
        return product;
    }

    public static ProductItem createTestProductItem(Id product2Id, Id locationId, Decimal quantityOnHand, Boolean isInsert) {
        ProductItem productItem = new ProductItem(
                                    Product2Id = product2Id,
                                    QuantityUnitOfMeasure = 'Each',
                                    LocationId = locationId,
                                    QuantityOnHand = quantityOnHand);

        if (isInsert) {
            insert productItem;
        }
        return productItem;
    }

    public static FSE_Spares_Kit_Settings__c createFSESparesKitSettings(String name, Decimal minLevel, Decimal quantity, Boolean isInsert) {
        FSE_Spares_Kit_Settings__c fseSparesKitSetting = new FSE_Spares_Kit_Settings__c(
                                                            Name = name,
                                                            Min_Level__c = minLevel,
                                                            Quantity__c = quantity,
                                                            Product_Name__c = name);

        if (isInsert) {
            insert fseSparesKitSetting;
        }
        return fseSparesKitSetting;
    }

    @future
    public static void setDataForStockReplenishmentBatchTest(List<Id> userIds) {
        List<Schema.Location> locations = new List<Schema.Location>();
        locations.add(TestDataGenerator.createTestLocation('Location1', true, true, false));
        locations.add(TestDataGenerator.createTestLocation('Location2', true, true, false));
        locations.add(TestDataGenerator.createTestLocation('Location3', true, true, false));
        insert locations;

        List<ServiceResource> serviceResources = new List<ServiceResource>();
        serviceResources.add(TestDataGenerator.createTestServiceResource(userIds[0], 'ServiceResource1', true, locations[0].Id, false));
        serviceResources.add(TestDataGenerator.createTestServiceResource(userIds[1], 'ServiceResource2', false, locations[1].Id, false));
        serviceResources.add(TestDataGenerator.createTestServiceResource(userIds[2], 'ServiceResource3', false, locations[2].Id, false));
        insert serviceResources;

        List<Product2> products = new List<Product2>();
        products.add(TestDataGenerator.createTestProduct('Product1', 'Code1', false));
        products.add(TestDataGenerator.createTestProduct('Product2', 'Code2', false));
        products.add(TestDataGenerator.createTestProduct('Product3', 'Code3', false));
        products.add(TestDataGenerator.createTestProduct('Product4', 'Code4', false));
        insert products;

        List<ProductItem> productItems = new List<ProductItem>();
        productItems.add(TestDataGenerator.createTestProductItem(products[0].Id, locations[0].Id, 2, false));
        productItems.add(TestDataGenerator.createTestProductItem(products[1].Id, locations[0].Id, 4, false));
        productItems.add(TestDataGenerator.createTestProductItem(products[2].Id, locations[0].Id, 0, false));
        productItems.add(TestDataGenerator.createTestProductItem(products[3].Id, locations[0].Id, 1, false));
        productItems.add(TestDataGenerator.createTestProductItem(products[0].Id, locations[1].Id, 4, false));
        productItems.add(TestDataGenerator.createTestProductItem(products[1].Id, locations[2].Id, 0, false));
        insert productItems;

        List<FSE_Spares_Kit_Settings__c> sparesSettings = new List<FSE_Spares_Kit_Settings__c>();
        sparesSettings.add(TestDataGenerator.createFSESparesKitSettings('Code1', 2, 4, false)); //+2
        sparesSettings.add(TestDataGenerator.createFSESparesKitSettings('Code2', 2, 4, false)); //-
        sparesSettings.add(TestDataGenerator.createFSESparesKitSettings('Code3', 1, 3, false)); // +3
        sparesSettings.add(TestDataGenerator.createFSESparesKitSettings('Code4', 4, 10, false)); //+9
        insert sparesSettings;
    }

    public static void insertTestUsers() {
        List<User> users = new List<User>();
        users.add(TestDataGenerator.createTestUser('User1.camlindev', false));
        users.add(TestDataGenerator.createTestUser('User2.camlindev', false));
        users.add(TestDataGenerator.createTestUser('User3.camlindev', false));
        insert users;
    }

    public static Account createAccount(String name, Boolean isInsert){

        Schema.DescribeFieldResult fieldResult = Account.Region__c.getDescribe();
		List<Schema.PicklistEntry> pl = fieldResult.getPicklistValues();

        Account account = new Account(
                                    Name = name, Region__c = pl[0].getValue(),BillingStreet='BillingStreet',BillingCity='BillingCity',BillingCountry='BillingCountry');

        if (isInsert) {
            insert account;
            system.debug('Created Account Id: '+account.Id);
        }
        return account;
    }

     public static Case createCase(String type, String accountId, Boolean isInsert){
        Case cs = new Case(Type = type, AccountId = accountId );

        if (isInsert) {
            insert cs;
        }
        return cs;
    }

    public static WorkOrder createDataWithWorkOrder(){

        datetime dt = datetime.now();

        //Account
        Account acc = TestDataGenerator.createAccount('Acc_test', true);

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

        //WorkOrder
        Id rtId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation').getRecordTypeId();

        WorkOrder wo = new WorkOrder(AccountId = acc.Id, RecordTypeId = rtId, WorkTypeId = wt.Id, ServiceTerritoryId = stp.Id);
        insert wo;

        return wo;

    }
}