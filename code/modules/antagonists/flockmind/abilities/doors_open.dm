/datum/targetable/flockmindAbility/doorsOpen
	name = "Gatecrash"
	desc = "Force open every door in radio range (if it can be opened by radio transmissions)."
	icon_state = "open_door"
	cooldown = 10 SECONDS
	targeted = 0

/datum/targetable/flockmindAbility/doorsOpen/cast(atom/target)
	if(..())
		return 1
	var/list/targets = list()
	for(var/obj/machinery/door/airlock/A in range(10, get_turf(holder.owner)))
		if(A.canAIControl())
			targets += A
	if(length(targets))
		src.tutorial_check(FLOCK_ACTION_GATECRASH, targets, TRUE)
		playsound(holder.get_controlling_mob(), 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
		boutput(holder.get_controlling_mob(), SPAN_NOTICE("You force open all the doors around you."))
		logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts gatecrash at [log_loc(src.holder.owner)].")
		sleep(1.5 SECONDS)
		for(var/obj/machinery/door/airlock/A in targets)
			A.open()
	else
		boutput(holder.get_controlling_mob(), SPAN_ALERT("No targets in range that can be opened via radio."))
		return TRUE

/datum/targetable/flockmindAbility/doorsOpen/logCast(atom/target)
	return
