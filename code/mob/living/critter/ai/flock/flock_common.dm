/datum/aiHolder/flock
	// if there's ever specific flock values here they go

/datum/aiHolder/flock/proc/rally(atom/movable/target)
	// IMMEDIATE INTERRUPT
	var/datum/aiTask/task = src.get_instance(/datum/aiTask/sequence/goalbased/flock/rally, list(src, src.default_task))
	task.target = target
	src.priority_tasks += task
	src.interrupt()

/datum/aiTask/prioritizer/flock
	// if there's ever specific flock values here they go
