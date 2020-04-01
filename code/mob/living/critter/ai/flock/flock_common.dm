/datum/aiHolder/flock
	// if there's ever specific flock values here they go

/datum/aiHolder/flock/proc/rally(atom/movable/target)
	// IMMEDIATE INTERRUPT	
	src.current_task = src.get_instance(/datum/aiTask/sequence/goalbased/rally, list(src, src.default_task))
	src.current_task.reset()
	src.target = get_turf(target)

/datum/aiTask/prioritizer/flock
	// if there's ever specific flock values here they go
