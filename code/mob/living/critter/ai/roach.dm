/datum/aiHolder/roach
	New()
		..()
		default_task = get_instance(/datum/aiTask/timed/wander, list(src))
