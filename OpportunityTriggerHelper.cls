public class OpportunityTriggerHelper {
    public static final String oemVar = 'OEM';
    public static final String endUserVar = 'End User';
    public static final String distrVar = 'Distributor';
    public static final Id OPP_CHARGEABLE_CASE = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Chargeable_case').getRecordTypeId();
    
	public static void updateOpportunity(List<Opportunity> newOpportunity) {
            Map<String, String> currenciesPricebook = new Map<String, String>();
            Map<Id, Opportunity> existingOpportunities = new Map<Id, Opportunity>([SELECT id,
                                                                (SELECT Id FROM OpportunityLineItems limit 1)
                                                            FROM Opportunity
                                                            WHERE Id IN :newOpportunity]);
            List<Upload_Process_Settings__c> uploadProcessSettings = CamlinHelper.defaultUploadProcessSettings;
            for(Upload_Process_Settings__c columnName : uploadProcessSettings) {
                if(columnName.Column_Currency__c != null && columnName.isActive__c && columnName.is_Region_Price__c) {
                    if (!currenciesPricebook.containsKey(columnName.Name + ' ' + oemVar)) {
                        currenciesPricebook.put(columnName.Name + ' ' + oemVar, columnName.Column_Currency__c);
                    }

                    if (!currenciesPricebook.containsKey(columnName.Name + ' ' + endUserVar)) {
                        currenciesPricebook.put(columnName.Name + ' ' + endUserVar, columnName.Column_Currency__c);
                    }

                    if (!currenciesPricebook.containsKey(columnName.Name + ' ' + distrVar)) {
                        currenciesPricebook.put(columnName.Name + ' ' + distrVar, columnName.Column_Currency__c);
                    }
                }
            }

            if(currenciesPricebook.isEmpty()) {
                currenciesPricebook = CamlinHelperVars.CURENCIESPRICEBOOK;
            }

            Map<String, List<Opportunity>> regionToPricebook = new Map<String, List<Opportunity>>();
            
        	for(Opportunity newRecord: newOpportunity) {
                if (newRecord.RecordTypeId != OPP_CHARGEABLE_CASE) {
                    if(newRecord.Id != null && existingOpportunities.containsKey(newRecord.Id) && !existingOpportunities.get(newRecord.id).OpportunityLineItems.isEmpty()) {
                        continue;
                    }
                
                    if(!regionToPricebook.containsKey(newRecord.Type_and_Region__c)) {
                        regionToPricebook.put(newRecord.Type_and_Region__c, new List<Opportunity>());
                    }
                    regionToPricebook.get(newRecord.Type_and_Region__c).add(newRecord);
                }
            }
        
            System.debug(regionToPricebook);
        
            List<Pricebook2> priceBooks = [SELECT Name FROM Pricebook2 WHERE Name IN :regionToPricebook.keySet() AND IsStandard = FALSE];
        
            for(Pricebook2 pb : priceBooks) {
                for(Opportunity oppRec : regionToPricebook.get(pb.Name)) {
                    if (oppRec.RecordTypeId != OPP_CHARGEABLE_CASE) {
                        oppRec.Pricebook2Id = pb.id;
                        if(currenciesPricebook.containsKey(oppRec.Type_and_Region__c)) {
                            oppRec.CurrencyIsoCode = currenciesPricebook.get(oppRec.Type_and_Region__c);
                        }
                    }
                }
            }
        }
    
    public static void createTechSupportRecords(Map<ID, Opportunity> triggerOld, Map<ID, Opportunity> triggerNew) {
        if(triggerNew != null) {
            Map<Id, Tech_Support__c> relatedTechSupportMap = new Map<Id, Tech_Support__c>();
            List<Tech_Support__c> relatedTechSupport = [SELECT id, Opportunity__c
                    FROM Tech_Support__c
                    WHERE Opportunity__c IN :triggerNew.keySet()
            ];

            for(Tech_Support__c techSupport : relatedTechSupport) {
                relatedTechSupportMap.put(techSupport.Opportunity__c, techSupport);
            }

            List<Tech_Support__c> techSupportToInsert = new List<Tech_Support__c>();
            
            for(Opportunity newOpp: triggerNew.values()) {
                
                if(!relatedTechSupportMap.containsKey(newOpp.id)) {
                    if ((newOpp.Seasonal_extreme_condition__c != null && newOpp.Seasonal_extreme_condition__c.equals('Yes')) ||
                        (newOpp.Max_distance_between_bushing__c != null && newOpp.Max_distance_between_bushing__c.equals('Yes')) ||
                        (newOpp.Who_Provides_SIM__c != null && newOpp.Who_Provides_SIM__c.equals('Camlin')) ||
                        (newOpp.fiber_optic_or_copper_connections__c != null) ||
                        (newOpp.which_protocol_do_you_require__c != null && (newOpp.which_protocol_do_you_require__c.equals('DNP 3.0') || 
                                                                             newOpp.which_protocol_do_you_require__c.equals('IEC 61850') || 
                                                                             newOpp.which_protocol_do_you_require__c.equals('Others'))) ||
                        (newOpp.Max_distance_between_oil_valves__c != null && newOpp.Max_distance_between_oil_valves__c.equals('Yes'))) {
                        	techSupportToInsert.add(createNewTechSupportRecord(newOpp));
                    }
                }
            }

            insert techSupportToInsert;
        }
    }
    
    private static Tech_Support__c createNewTechSupportRecord(Opportunity opp) {
        Tech_Support__c newTechSupport = new Tech_Support__c();
        newTechSupport.Status__c = 'Open';
        newTechSupport.Opportunity__c = opp.id;
        newTechSupport.Assigned_to__c = UserInfo.getUserId();
        newTechSupport.Contact__c = opp.Contact__c;
        newTechSupport.Distributor__c = opp.Distributor__c;
        newTechSupport.OEM__c = opp.OEM__c;
        newTechSupport.Customer__c = opp.AccountId;
        newTechSupport.Opportunity_Owner__c = opp.OwnerId;
        newTechSupport.Specific_Instalation_Requirements__c = opp.Specific_Instalation_Requirements__c;
        //newTechSupport.OwnerId = '00520000005XfKi';
        return newTechSupport;
    }
}