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
		var/datum/abilityHolder/vampire/H = holder

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to infect yourself?</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1

		if (isdead(target))
			boutput(M, "<span class='alert'>It would be a waste of time to infect the dead.</span>")
			return 1

		if (!iscarbon(target))
			boutput(M, "<span class='alert'>[target] is immune to the disease.</span>")
			return 1

		var/mob/living/L = target

		//playsound(M.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
		//M.visible_message("<span class='notice'>[M] shakes [L], trying to wake them up!</span>")
		M.shake_awake(target)
		L.add_fingerprint(M) // Why not leave some forensic evidence?
		if (!(L.bioHolder && L.traitHolder.hasTrait("training_chaplain")))
			L.contract_disease(/datum/ailment/disease/vamplague, null, null, 1) // path, name, strain, bypass resist

		if (istype(H)) H.blood_tracking_output(src.pointCost)
		logTheThing(LOG_COMBAT, M, "uses diseased touch on [constructTarget(L,"combat")] at [log_loc(M)].")
		return 0
