@isTest
public class QuoteLineItemTriggerTest 
{
    public static TestMethod void OrderLineItem_UnitTest()
    {
        Product2 prod = new Product2(Name = 'Laptop X200', 
        Family = 'Hardware');
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;

        PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = customPB.Id, Product2Id = prod.Id,
        UnitPrice = 12000, IsActive = true);
        insert customPrice;

        Account acc = TestDataGenerator.createAccount('Acc_test', true);

        //Opportunity
        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'testopp',  StageName= 'Opportunity', CloseDate = Date.today().addMonths(1));
        insert opp;


        Quote quote = new Quote(opportunityId = opp.Id, Name = 'Test Quote', pricebook2Id = pricebookId);

        insert quote;

        QuoteLineItem item = new QuoteLineItem(quoteId = quote.Id, PricebookEntryId = standardPrice.Id, UnitPrice = 100, Quantity = 1);
        insert item;

    }

}