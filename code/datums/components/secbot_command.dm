/datum/component/secbot_command
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	/// A list of bots listening to this command
	var/list/mob/living/critter/robotic/securitron/secbots = null

/datum/component/secbot_command/Initialize(list/mob/living/critter/robotic/securitron/secbots, duration = -1)
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
	for (var/mob/living/critter/robotic/securitron/secbot as anything in src.secbots)
		if (QDELETED(secbot))
			continue
		if (isliving(target) && secbot.ai.enabled && !istype(target, /mob/living/critter/robotic/securitron) && target != secbot.ai.target)
			var/datum/aiTask/sequence/goalbased/critter/attack/fixed_target/securitron/task = \
				secbot.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/attack/fixed_target/securitron, list(secbot.ai, secbot.ai.default_task, target))
			task.fixed_target = target
			task.transition_task = task
			secbot.ai.interrupt_to_task(task)
			secbot.accuse_perp(target, rand(5,8)) // id rather excess emotes than non-telegraphed securitrons, so this has no emote cooldown check
			if(!ON_COOLDOWN(secbot, "SECURITRON_EMOTE", secbot.emote_cooldown))
				secbot.siren()
			if (src.parent)
				src.RemoveComponent()

/datum/aiTask/sequence/goalbased/critter/attack/fixed_target/securitron
	name = "attacking whistle target"

/datum/aiTask/sequence/goalbased/critter/attack/fixed_target/securitron/on_tick()
	if(GET_COOLDOWN(src.holder.owner, "HALT_FOR_INTERACTION"))
		return
	. = ..()
	if(src.fixed_target && isliving(src.fixed_target))
		var/mob/living/L = src.fixed_target
		if(ishuman(L) && !L.hasStatus("handcuffed"))
			return
		else if (!is_incapacitated(L))
			return
		if(istype(src.holder.owner, /mob/living/critter/robotic/securitron))
		OVERRIDE_COOLDOWN(src.holder.owner, "HALT_FOR_INTERACTION", 0)
		src.transition_task = src.holder.default_task
		src.fixed_target = null
		src.holder.interrupt_to_task(src.holder.default_task)
