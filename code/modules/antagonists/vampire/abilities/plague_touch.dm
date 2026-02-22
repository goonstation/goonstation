/datum/targetable/vampire/plague_touch
	name = "Diseased touch"
	desc = "Infects the target with a deadly, non-contagious disease."
	icon_state = "badtouch" //brought to you by the bloodhound gang
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 600
	pointCost = 30
	when_stunned = 0
	not_when_handcuffed = 1
	unlock_message = "You have gained diseased touch, which inflicts someone with a deadly, non-contagious disease."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, SPAN_ALERT("Why would you want to infect yourself?"))
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return 1

		if (isdead(target))
			boutput(M, SPAN_ALERT("It would be a waste of time to infect the dead."))
			return 1

		if (!iscarbon(target))
			boutput(M, SPAN_ALERT("[target] is immune to the disease."))
			return 1

		. = ..()
		var/mob/living/L = target

		//playsound(M.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
		//M.visible_message(SPAN_NOTICE("[M] shakes [L], trying to wake them up!"))
		M.shake_awake(target)
		L.add_fingerprint(M) // Why not leave some forensic evidence?
		if (!(L.bioHolder && L.traitHolder.hasTrait("training_chaplain")))
			L.contract_disease(/datum/ailment/disease/vamplague, null, null, 1) // path, name, strain, bypass resist

		logTheThing(LOG_COMBAT, M, "uses diseased touch on [constructTarget(L,"combat")] at [log_loc(M)].")
		return 0
