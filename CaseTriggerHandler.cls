/*
 * Created by Oleg Bogdanovych on 9/25/2019.
 */
public without sharing class CaseTriggerHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public static boolean IsFromBachJob ;
	public static boolean isFromUploadAPI = false;

	public CaseTriggerHandler(boolean isExecuting, integer size) {
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnBeforeInsert(List<Case> newRecords) {
		system.debug('Trigger On Before Insert');
		CaseTriggerActions.setSensitiveCustomer(newRecords);
	}
/*
	public void OnAfterInsert(List<Case> newRecords) {
		system.debug('Trigger On After Insert');
	}

	public void OnAfterUpdate(List<Case> newRecords, List<Case> oldRecords, Map<ID, Case> newRecordsMap , Map<ID, Case> oldRecordsMap) {
		system.debug('Trigger On After Update ');
	}

	public void OnBeforeUpdate( List<Case> newRecords, List<Case> oldRecords, Map<ID, Case> newRecordsMap , Map<ID, Case> oldRecordsMap) {
		system.debug('Trigger On Before Update ');
	}

	@future
	public static void OnAfterUpdateAsync(Set<ID> newRecordsIDs) {}

	public boolean IsTriggerContext {
		get {return m_isExecuting;}
	}

	public boolean IsVisualforcePageContext {
		get {return !IsTriggerContext;}
	}

	public boolean IsWebServiceContext {
		get {return !IsTriggerContext;}
	}

	public boolean IsExecuteAnonymousContext {
		get {return !IsTriggerContext;}
	}
*/
}