/obj/machinery/camera/motion
	name = "Motion Security Camera"
	var/list/motionTargets = list()
	var/detectTime = 0
	var/locked = 1

/obj/machinery/camera/motion/process()
	// motion camera event loop
	. = ..()
	if (detectTime > 0)
		var/elapsed = world.time - detectTime
		if (elapsed > 300)
			src.triggerAlarm()
	else if (detectTime == -1)
		for (var/mob/target in motionTargets)
			if (isdead(target))
				lostTarget(target)

/obj/machinery/camera/motion/disposing()
	for (var/dude as anything in src.motionTargets)
		LAZYLISTREMOVE(src.motionTargets, dude)
	..()

/obj/machinery/camera/motion/proc/newTarget(var/mob/target)
	if (isAI(target))
		return 0
	if (detectTime == 0)
		detectTime = world.time // start the clock
	if (!(target in motionTargets))
		motionTargets += target
	return 1

/obj/machinery/camera/motion/proc/lostTarget(var/mob/target)
	if (target in src.motionTargets)
		src.motionTargets -= target
	if (length(motionTargets) == 0)
		src.cancelAlarm()

/obj/machinery/camera/motion/proc/cancelAlarm()
	if (detectTime == -1)
		for (var/mob/living/silicon/aiPlayer in mobs)
			if (camera_status) aiPlayer.cancelAlarm("Motion", get_area(src))
	detectTime = 0
	return 1

/obj/machinery/camera/motion/proc/triggerAlarm()
	if (!detectTime) return 0
	for (var/mob/living/silicon/aiPlayer in mobs)
		if (camera_status) aiPlayer.triggerAlarm("Motion", get_area(src), list(src))
	detectTime = -1
	return 1

/obj/machinery/camera/motion/attackby(obj/item/W, mob/user)
	if (issnippingtool(W) && locked == 1) return
	if (isscrewingtool(W))
		var/turf/T = user.loc
		boutput(user, SPAN_NOTICE("[(locked) ? "Open" : "Clos"]ing the access hatch... (this is a long process)"))
		sleep(10 SECONDS)
		if ((user.loc == T && user.equipped() == W && !( user.stat )))
			src.locked ^= 1
			boutput(user, SPAN_NOTICE("The access hatch is now [(locked) ? "closed" : "open"]."))

	..() // call the parent to (de|re)activate

	if (issnippingtool(W)) // now handle alarm on/off...
		if (camera_status) // ok we've just been reconnected... send an alarm!
			detectTime = world.time - 301
			triggerAlarm()
		else
			for (var/mob/living/silicon/aiPlayer in mobs) // manually cancel, to not disturb internal state
				aiPlayer.cancelAlarm("Motion", src.loc.loc)
