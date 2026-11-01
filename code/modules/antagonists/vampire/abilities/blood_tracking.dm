/datum/targetable/vampire/blood_tracking
	name = "Toggle blood tracking"
	desc = "Toggles tracking the blood of the last victim you drank from."
	icon_state = "bloodtrack"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	not_when_in_an_object = FALSE
	when_stunned = 2
	not_when_handcuffed = 0
	lock_holder = FALSE
	ignore_holder_lock = 1
	do_logs = FALSE
	interrupt_action_bars = FALSE
	var/active = FALSE

	cast(mob/target)
		if (!src.holder?.owner)
			return 1

		. = ..()
		var/datum/abilityHolder/vampire/vamp_holder = src.holder
		if (vamp_holder.last_victim && QDELETED(vamp_holder.last_victim))
			boutput(src.holder.owner, SPAN_ALERT("Your victim has left this plane."))
			vamp_holder.last_victim = null
			src.active = FALSE
			return
		if (!src.active)
			if (!vamp_holder.last_victim)
				boutput(src.holder.owner, SPAN_ALERT("You have yet to drink the blood of an innocent."))
				return
			src.holder.owner.AddComponent(/datum/component/tracker_hud/vampire, vamp_holder.last_victim)
			boutput(src.holder.owner, SPAN_ALERT("You start tracking the blood of your latest victim."))
			src.active = TRUE
		else
			src.holder.owner.RemoveComponentsOfType(/datum/component/tracker_hud/vampire)
			boutput(src.holder.owner, SPAN_ALERT("You suppress your bloodlust. For now."))
			src.active = FALSE

	proc/update_target(mob/target)
		if (!active)
			return
		var/datum/component/tracker_hud/vampire/tracker = src.holder.owner.GetComponent(/datum/component/tracker_hud/vampire)
		tracker.target = target
