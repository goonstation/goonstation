/datum/targetable/vampire/nightvision
	name = "Toggle nightvision"
	desc = "Toggles your vampire nightvision."
	icon_state = "blind"
	targeted = FALSE
	target_nodamage_check = FALSE
	max_range = 0
	cooldown = 0
	pointCost = 0
	not_when_in_an_object = FALSE
	when_stunned = 2
	not_when_handcuffed = FALSE
	lock_holder = FALSE
	ignore_holder_lock = TRUE
	interrupt_action_bars = FALSE
	var/active = FALSE

/datum/targetable/vampire/nightvision/cast(mob/target)
	if (!src.holder?.owner)
		return TRUE

	. = ..()

	src.active = !src.active
	if (src.active)
		APPLY_ATOM_PROPERTY(src.holder.owner, PROP_MOB_NIGHTVISION, src)
		boutput(src.holder.owner, SPAN_ALERT("You focus your eyes and the darkness recedes."))
	else
		REMOVE_ATOM_PROPERTY(src.holder.owner, PROP_MOB_NIGHTVISION, src)
		boutput(src.holder.owner, SPAN_ALERT("You relax your eyes and your vision returns to normal."))

