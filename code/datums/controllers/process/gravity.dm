proc/SubscribeGravity(atom/AM)
	var/datum/controller/process/gravity/controller = global.processScheduler?.getProcess("Gravity Process")
	controller?.subscriber_list |= AM

proc/UnsubscribeGravity(atom/AM)
	var/datum/controller/process/gravity/controller = global.processScheduler?.getProcess("Gravity Process")
	controller?.subscriber_list -= AM

/// Controller to store gravity variables and update atom gravity
///
/// Subscribe **non-lifeprocess** atoms to get regular gravity updates.
/datum/controller/process/gravity
	var/list/subscriber_list = list()

	setup()
		name = "Gravity Process"
		schedule_interval = 3 SECONDS

	doWork()
		for (var/atom/movable/AM as anything in src.subscriber_list)
			if (QDELETED(AM))
				continue
			AM.set_gravity(AM.loc)
