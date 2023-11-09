global class StockReplenishmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public Map<String,FSE_Spares_Kit_Settings__c> sparesKitSettingsMap {get; set;}
    
    public StockReplenishmentBatch() {
        sparesKitSettingsMap = new Map<String,FSE_Spares_Kit_Settings__c>();
        for(FSE_Spares_Kit_Settings__c setting : [SELECT Name, Product_Name__c, Min_Level__c, Quantity__c FROM FSE_Spares_Kit_Settings__c]){
            sparesKitSettingsMap.put(setting.Name, setting);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator('SELECT Id, LocationId FROM ServiceResource WHERE ' + 
            'IsActive = true AND LocationId != null AND Location.IsMobile = true AND Location.IsInventoryLocation = true');
    }
    
    global void execute(Database.BatchableContext bc, List<ServiceResource> serviceResources) {
        
        if (serviceResources.size() == 1) {
            System.debug('execute StockReplenishmentBatch');

            List<ProductItem> productItem = [
                SELECT 
                    QuantityOnHand, Product2.ProductCode 
                FROM 
                    ProductItem 
                WHERE 
                    LocationId = :serviceResources[0].LocationId];

            List<ProductRequestLineItem> itemsToRequest = new List<ProductRequestLineItem>();

            for (ProductItem item : productItem) {
                if (sparesKitSettingsMap.get(item.Product2.ProductCode) != null) {
                    if (item.QuantityOnHand <= sparesKitSettingsMap.get(item.Product2.ProductCode).Min_Level__c) {
                        itemsToRequest.add(new ProductRequestLineItem(
                            QuantityRequested = sparesKitSettingsMap.get(item.Product2.ProductCode).Quantity__c - item.QuantityOnHand,
                            Product2Id = item.Product2Id,
                            QuantityUnitOfMeasure = 'Each',
                            NeedByDate = Datetime.now().addDays(7),
                            ShipmentType = 'Pick Up',
                            DestinationLocationId = serviceResources[0].LocationId
                        ));
                    }
                } else {
                    System.debug('No such product code in FSE_Spares_Kit_Settings__c: ' + item.Product2.ProductCode);
                }
            }

            if (!itemsToRequest.isEmpty()) {
                ProductRequest productRequest = new ProductRequest(
                    NeedByDate = Datetime.now().addDays(7),
                    DestinationLocationId = serviceResources[0].LocationId,
                    ShipmentType = 'Pick Up'
                );

                insert productRequest;
                System.debug('productRequest inserted ' + productRequest);

                for(ProductRequestLineItem requestLineItem : itemsToRequest) {
                    requestLineItem.ParentId = productRequest.Id;
                }

                insert itemsToRequest;
                System.debug('itemsToRequest inserted ' + itemsToRequest);

            }
        }
    }    
    
    global void finish(Database.BatchableContext bc) {
        
    }    

}