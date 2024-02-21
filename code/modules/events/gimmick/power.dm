/datum/random_event/special/power_down
	name = "Power Outage"
	centcom_headline = "Critical Power Failure"
	centcom_message = "Abnormal activity has been detected in the station power grid. As a precautionary measure, the station's power will be shut off for an indeterminate duration."
	centcom_origin = ALERT_STATION

	event_effect()
		..()
		for(var/obj/machinery/power/apc/C in machine_registry[MACHINES_POWER])
			if(C.cell && C.z == 1)
				C.cell.charge = 0
		for(var/obj/machinery/power/smes/S in machine_registry[MACHINES_POWER])
			if(istype(get_area(S), /area/station/turret_protected) || S.z != 1)
				continue
			S.charge = 0
			S.output = 0
			S.online = 0
			S.UpdateIcon()
			S.power_change()

/datum/random_event/special/power_up
	name = "Power Grid Recharge"
	centcom_headline = "Power Systems Nominal"
	centcom_message = "Power has been restored to the station's power grid. We apologize for the inconvenience."
	centcom_origin = ALERT_STATION

	event_effect()
		..()
		for(var/obj/machinery/power/apc/C in machine_registry[MACHINES_POWER])
			if(C.cell && C.z == 1)
				C.cell.charge = C.cell.maxcharge
		for(var/obj/machinery/power/smes/S in machine_registry[MACHINES_POWER])
			if(S.z != 1)
				continue
			S.charge = S.capacity
			S.output = 200000
			S.online = 1
			S.UpdateIcon()
			S.power_change()
