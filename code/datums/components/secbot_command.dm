/datum/component/secbot_command
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	/// A list of bots listening to this command
	var/list/obj/machinery/bot/secbot/secbots = null

/datum/component/secbot_command/Initialize(list/obj/machinery/bot/secbot/secbots, duration = -1)
	. = ..()
	src.secbots = secbots
	if (duration >= 0)
		SPAWN(duration)
			if (src.parent)
				src.RemoveComponent()

/datum/component/secbot_command/RegisterWithParent()
	. = ..()
	RegisterSignal(src.parent, COMSIG_MOB_POINT, PROC_REF(on_point))

/datum/component/secbot_command/UnregisterFromParent()
	. = ..()
	UnregisterSignal(src.parent, COMSIG_MOB_POINT)
	src.secbots = null

/datum/component/secbot_command/proc/on_point(mob/pointer, atom/target)
	for (var/obj/machinery/bot/secbot/secbot as anything in src.secbots)
		if (QDELETED(secbot))
			continue
		if (iscarbon(target) && target != secbot.target)
			secbot.EngageTarget(target, FALSE, FALSE, TRUE)
