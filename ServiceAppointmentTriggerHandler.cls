/*
 * Created by Oleg Bogdanovych on 9/23/2019.
 */
public without sharing class ServiceAppointmentTriggerHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public static boolean IsFromBachJob ;
	public static boolean isFromUploadAPI = false;

	public ServiceAppointmentTriggerHandler(boolean isExecuting, integer size) {
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnBeforeInsert(List<ServiceAppointment> newRecords) {
		system.debug('Trigger On Before Insert');
		ServiceAppointmentTriggerActions.checkForActiveAppointments(newRecords);
	}
/*
	public void OnAfterInsert(List<ServiceAppointment> newRecords) {
		system.debug('Trigger On After Insert');
	}

	public void OnAfterUpdate(List<ServiceAppointment> newRecords, List<ServiceAppointment> oldRecords, Map<ID, ServiceAppointment> newRecordsMap , Map<ID, ServiceAppointment> oldRecordsMap) {
		system.debug('Trigger On After Update ');
	}

	public void OnBeforeUpdate( List<ServiceAppointment> newRecords, List<ServiceAppointment> oldRecords, Map<ID, ServiceAppointment> newRecordsMap , Map<ID, ServiceAppointment> oldRecordsMap) {
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