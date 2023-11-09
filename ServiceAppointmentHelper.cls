/*
 * Created by Oleg Bogdanovych on 7/24/2019.
 */
global class ServiceAppointmentHelper implements Schedulable {
	@InvocableMethod(label='Recalculate Multiday Work')
	public static void recalculateMultidayWork(List<ServiceAppointment> appointments) {
		Set<Id> appointmentIds = new Set<Id>();
		for (ServiceAppointment app : appointments) {
			appointmentIds.add(app.Id);
		}

		if (!appointmentIds.isEmpty()) {
			Datetime dt = Datetime.now().addSeconds(15);

			String hour = String.valueOf(dt.hour());
			String min = String.valueOf(dt.minute());
			String ss = String.valueOf(dt.second());

			String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
			ServiceAppointmentHelper sa = new ServiceAppointmentHelper(appointmentIds);

			System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, sa);
		}
	}

	public Set<Id> appointmentIds;

	public ServiceAppointmentHelper(Set<Id> ids) {
		this.appointmentIds = ids;
	}

	global void execute(SchedulableContext sc) {
		List<ServiceAppointment> appointments = [
				SELECT
					Id, FSL__IsMultiDay__c, Duration
				FROM ServiceAppointment
				WHERE Id IN :appointmentIds
		];

		for (ServiceAppointment app : appointments) {
			if (app.FSL__IsMultiDay__c == true) {
				app.Duration -= 0.01;
			}
		}

		update appointments;

		System.abortJob(sc.getTriggerId());
	}
}