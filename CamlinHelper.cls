global with sharing class CamlinHelper {
	public static List<Upload_Process_Settings__c> defaultUploadProcessSettings {
        get {
            List<Upload_Process_Settings__c> upsList = Upload_Process_Settings__c.getall().values();

            if(!upsList.isEmpty()) {
                return upsList;
            }

            return new List<Upload_Process_Settings__c>();
        }
        set;
    }

    public static Trigger_Settings__c enabledTriggersSettings() {
        Trigger_Settings__c enabledTriggers = Trigger_Settings__c.getInstance();
        return enabledTriggers;
    }
    
    /**
     * @Description: Method aggregates the total cost price on the parent quote object using the lineItems.
     * @Param quoteLineItemList: List of quoteLineItems Pass through trigger.
     * @return: void
	*/
    public static void updateProductsCostonQuoteObject(List<QuoteLineItem> quoteLineItemList)
    {
        Set<Id> lineItemIds = new Set<Id>();
        for(QuoteLineItem lineItem: quoteLineItemList)
        {
            lineItemIds.add(lineItem.Id);
        }
        
        //The below collection will be used to aggregate the quoteLineItems again through quote ids.
        Set<Id> quoteIds = new Set<Id>();
        for(QuoteLineItem lineItem: [Select id, QuoteId from QuoteLineItem where id in :lineItemIds])
        {
            quoteIds.add(lineItem.QuoteId);
        }
        
		List<Quote> quoteToUpdate = new List<Quote>();
        
		for (AggregateResult ag: [select QuoteId, SUM(Product_Cost__c)totalCost from QuoteLineItem where QuoteId IN :quoteIds group by QuoteId]) 
        {
            Id quoteId = (Id)ag.get('QuoteId');
			Quote quoteObj = new Quote(Id = quoteId);
            quoteObj.Total_Products_cost__c = (Decimal)ag.get('totalCost');
            quoteToUpdate.add(quoteObj);
        }
        update quoteToUpdate;
    }
}