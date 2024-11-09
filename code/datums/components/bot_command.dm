ABSTRACT_TYPE(/datum/component/bot_command)
/datum/component/bot_command
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	/// A list of bots listening to this command
	var/list/obj/machinery/bot/bots = null
	// What kind of bot we command
	var/botpath = /obj/machinery/bot

/datum/component/bot_command/Initialize(list/obj/machinery/bot/bots, duration = -1)
	. = ..()
	src.bots = bots
	for(var/bot in src.bots)
		if(!istype(bot, botpath))
			src.RemoveComponent()
	if (duration >= 0)
		SPAWN(duration)
			if (src.parent)
				src.RemoveComponent()

/datum/component/bot_command/RegisterWithParent()
	. = ..()
	RegisterSignal(src.parent, COMSIG_MOB_POINT, PROC_REF(on_point))

/datum/component/bot_command/UnregisterFromParent()
	. = ..()
	UnregisterSignal(src.parent, COMSIG_MOB_POINT)
	src.bots = null

/datum/component/bot_command/proc/on_point(mob/pointer, atom/target)

/datum/component/bot_command/security
	botpath = /obj/machinery/bot/secbot

	on_point(mob/pointer, atom/target)
		for (var/obj/machinery/bot/secbot/secbot as anything in src.bots)
			if (QDELETED(secbot))
				continue
			if (iscarbon(target) && target != secbot.target)
				secbot.EngageTarget(target, FALSE, FALSE, TRUE)

/datum/component/bot_command/janitor
	botpath = /obj/machinery/bot/cleanbot

	on_point(mob/pointer, atom/pointtarget)
		for (var/obj/machinery/bot/cleanbot/cleanbot as anything in src.bots)
			if(QDELETED(cleanbot))
				continue
			if(cleanbot == pointtarget)
				cleanbot.toggle_power()
				src.bots -= cleanbot
			else
				var/turf/simulated/floor/T = get_turf(pointtarget)
				var/coord = cleanbot.turf2coordinates(T)
				if ((coord in cleanbot.cleanbottargets) || (coord in cleanbot.targets_invalid))
					continue
				if (cleanbot.is_it_invalid(T))
					continue
				if (!T.messy && !T.active_liquid)
					continue
				if (cleanbot.target)
					cleanbot.cleanbottargets -= coord
					cleanbot.target = null
				cleanbot.speak("Target dirt confirmed.")
				cleanbot.cleanbottargets += coord
				cleanbot.target = T
				return
