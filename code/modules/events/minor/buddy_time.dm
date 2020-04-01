/datum/random_event/minor/buddy_time
	name = "Buddy Time"

	event_effect()
		..()
		for (var/obj/machinery/bot/guardbot/buddy in machine_registry[MACHINES_BOTS])
			if (buddy.z != 1)
				continue

			if (buddy.charge_dock)
				buddy.charge_dock.eject_robot()
			else if (buddy.idle)
				buddy.wakeup()

			if (isnull(buddy.task)) // Don't erase active patrol tasks and the like.
				buddy.add_task(/datum/computer/file/guardbot_task/recharge/dock_sync, 1, 0)
			buddy.add_task(/datum/computer/file/guardbot_task/buddy_time, 1, 0)
