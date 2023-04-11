/datum/targetable/vampire/plague_touch
	name = "Diseased touch"
	desc = "Infects the target with a deadly, non-contagious disease."
	icon_state = "badtouch" //brought to you by the bloodhound gang
	targeted = TRUE
	target_nodamage_check = TRUE
	target_self = FALSE
	max_range = 1
	cooldown = 60 SECONDS
	pointCost = 30
	can_cast_while_cuffed = FALSE
	unlock_message = "You have gained diseased touch, which inflicts someone with a deadly, non-contagious disease."

	// safe to assume target type, as non-carbon mobs are filtered in castcheck()
	cast(mob/living/target)
		var/mob/living/user = holder.owner

		user.shake_awake(target)
		target.add_fingerprint(user) // Why not leave some forensic evidence?
		if (!(target.bioHolder && target.traitHolder.hasTrait("training_chaplain")))
			target.contract_disease(/datum/ailment/disease/vamplague, null, null, 1) // path, name, strain, bypass resist

		logTheThing(LOG_COMBAT, user, "uses diseased touch on [constructTarget(target, "combat")] at [log_loc(user)].")
		return FALSE

	castcheck(mob/target)
		. = ..()
		var/mob/living/user = src.holder.owner
		if (isdead(target))
			boutput(src, "<span class='alert'>It would be a waste of time to infect the dead.</span>")
			return FALSE

		if (!iscarbon(target))
			boutput(user, "<span class='alert'>[target] is immune to the disease.</span>")
			return FALSE
