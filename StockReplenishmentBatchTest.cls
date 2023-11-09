@isTest
public class StockReplenishmentBatchTest {

    @testSetup
    public static void setup() {
        TestDataGenerator.insertTestUsers();
        Map<Id, User> users = new Map<Id, User>([SELECT Id FROM User WHERE LastName LIKE '%camlindev%']);
        TestDataGenerator.setDataForStockReplenishmentBatchTest(new List<Id> (users.keySet()));
    }

    @isTest
    public static void testStockReplenishmentBatch() {

        Test.startTest();
        StockReplenishmentBatch stockReplenishmentBatch = new StockReplenishmentBatch();
        Database.executeBatch(stockReplenishmentBatch, 1);
        Test.stopTest();

        List<ProductRequest> productRequest = [
            SELECT
                NeedByDate, DestinationLocation.Name, ShipmentType,
                (SELECT
                    QuantityRequested, Product2.ProductCode, QuantityUnitOfMeasure, NeedByDate, ShipmentType, DestinationLocation.Name
                FROM
                    ProductRequestLineItems)
            FROM
                ProductRequest
            ];

        System.assert(productRequest.size() == 1);
        System.assert(productRequest[0].NeedByDate.date() == Date.today().addDays(7));
        System.assert(productRequest[0].ShipmentType == 'Pick Up');
        System.assertEquals([SELECT Id from Location where Name = 'Location1'].Id, productRequest[0].DestinationLocationId);
        System.assertEquals(3, productRequest[0].ProductRequestLineItems.size());

        for (ProductRequestLineItem requestItem : productRequest[0].ProductRequestLineItems) {
            System.assertEquals(requestItem.NeedByDate, productRequest[0].NeedByDate);
            System.assertEquals(requestItem.DestinationLocationId, productRequest[0].DestinationLocationId);
            System.assertEquals(requestItem.ShipmentType, productRequest[0].ShipmentType);
            System.assertEquals('Each', requestItem.QuantityUnitOfMeasure);

            if (requestItem.Product2.ProductCode == 'Code1') {
                System.assertEquals(2, requestItem.QuantityRequested);
            } else if (requestItem.Product2.ProductCode == 'Code3') {
                System.assertEquals(3, requestItem.QuantityRequested);
            } else if (requestItem.Product2.ProductCode == 'Code4') {
                System.assertEquals(9, requestItem.QuantityRequested);
            }
        }
    }

    @isTest
    public static void testStockReplenishmentSchedule() {

        Test.startTest();

        StockReplenishmentSchedule schd = new StockReplenishmentSchedule ();
        String chron = '0 0 23 * * ?';
        system.schedule('Test', chron, schd);

        Test.stopTest();
    }

}