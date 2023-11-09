/*
 * Created by Oleg Bogdanovych on 9/23/2019.
 */
public without sharing class ServiceAppointmentTriggerActions {
	public static void checkForActiveAppointments(List<ServiceAppointment> newRecords) {
		Map<Id, List<ServiceAppointment>> appointmentsByParentId = new Map<Id, List<ServiceAppointment>>();
		for (ServiceAppointment sa : newRecords) {
			if(sa.ParentRecordId != NULL && (sa.Status != 'Cannot Complete' || sa.Status != 'Completed' || sa.Status != 'Canceled')) {
				if (appointmentsByParentId.get(sa.ParentRecordId) == null) {
					appointmentsByParentId.put(sa.ParentRecordId, new List<ServiceAppointment>());
				}

				appointmentsByParentId.get(sa.ParentRecordId).add(sa);
			}
		}

		for (Id parentId : appointmentsByParentId.keySet()) {
			if (appointmentsByParentId.get(parentId).size() > 1) {
				appointmentsByParentId.get(parentId).get(0).addError('You are try to insert more than 1 active Service Appointment to one parent');
			}
		}

		List<ServiceAppointment> existingAppointments = [SELECT
								Id, ParentRecordId
							FROM ServiceAppointment
							WHERE ParentRecordId IN :appointmentsByParentId.keySet()
								AND Status NOT IN ('Cannot Complete', 'Completed', 'Canceled')];

		Map<Id, List<ServiceAppointment>> existingAppsByParentId = new Map<Id, List<ServiceAppointment>>();
		for (ServiceAppointment sa : existingAppointments) {
			if (sa.ParentRecordId != NULL) {
				if (existingAppsByParentId.get(sa.ParentRecordId) == null) {
					existingAppsByParentId.put(sa.ParentRecordId, new List<ServiceAppointment>());
				}

				existingAppsByParentId.get(sa.ParentRecordId).add(sa);
			}
		}

		for (ServiceAppointment sa : newRecords) {
			if (existingAppsByParentId.get(sa.ParentRecordId) != NULL && existingAppsByParentId.get(sa.ParentRecordId).size() > 0) {
				sa.addError('You have already existing active Service Apointment. You can not add one more.');
			}
		}
	}
}