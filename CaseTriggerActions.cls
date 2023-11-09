/*
 * Created by Oleg Bogdanovych on 9/25/2019.
 */
public without sharing class CaseTriggerActions {
	public static final Id CAMLIN_POWER_CASE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Camlin_Power_Case').getRecordTypeId();

	public static void setSensitiveCustomer(List<Case> newRecords) {
		Map<Id, List<Case>> powerCasesByAccountId = new Map<Id, List<Case>>();
		Set<Id> idsToExclude = new Set<Id>();
		for (Case c : newRecords) {
			if (c.RecordTypeId == CAMLIN_POWER_CASE) {
				if (powerCasesByAccountId.get(c.AccountId) == NULL) {
					powerCasesByAccountId.put(c.AccountId, new List<Case>());
				}
				powerCasesByAccountId.get(c.AccountId).add(c);
				idsToExclude.add(c.Id);
			}
		}

		Map<Id, Account> accounts = new Map<Id, Account>([
			SELECT
				Id, Name,
				(SELECT Amount, CurrencyIsoCode FROM Opportunities WHERE StageName NOT IN ('Won', 'Lost') AND Amount != NULL),
				(SELECT Id FROM Cases WHERE CreatedDate >= LAST_N_DAYS:90 AND Id NOT IN :idsToExclude AND RecordTypeId = :CAMLIN_POWER_CASE)
			FROM Account
			WHERE Id IN :powerCasesByAccountId.keySet()
		]);

		List<DatedConversionRate> cts = [SELECT Id, ISOCode, Conversionrate, nextStartDate, startDate
											FROM DatedConversionRate
											WHERE StartDate <= TODAY AND NextStartDate > TODAY];
		Map<String, Decimal> conversionRate = new Map<String, Decimal>();
		for (DatedConversionRate ct : cts) {
			conversionRate.put(ct.ISOCode, ct.ConversionRate);
		}

		for (Case c : newRecords) {
			if (c.RecordTypeId == CAMLIN_POWER_CASE) {
				if (accounts.get(c.AccountId) != NULL) {
					Double amount = 0;
					for (Opportunity opp : accounts.get(c.AccountId).Opportunities) {
						Double oppAmount = opp.Amount;
						if (opp.CurrencyIsoCode != 'GBR') {
							oppAmount = opp.Amount * conversionRate.get(opp.CurrencyIsoCode);
						}
						amount += oppAmount;
					}

					Integer openedCases = 0;
					openedCases = accounts.get(c.AccountId).Cases.size();

					if (amount >= 250000 || openedCases >= 6) {
						c.Sensitive_Customer__c = true;
					}
				}
			}
		}
	}
}