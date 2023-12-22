/datum/targetable/grinch/instakill
	name = "Murder"
	desc = "Induces instant cardiac arrest in a target."
	icon_state = "grinchmurder"
	targeted = TRUE
	target_self = FALSE
	target_nodamage_check = TRUE
	cooldown = 480 SECONDS

	cast(mob/target)
		. = ..()
		var/mob/M = src.holder.owner
		var/mob/living/L = target

		playsound(M.loc, 'sound/impact_sounds/Flesh_Tear_1.ogg', 75, 1, -1)
		M.visible_message(SPAN_ALERT("<b>[M] shrinks [L]'s heart down two sizes too small!</b>"))
		L.add_fingerprint(M) // Why not leave some forensic evidence?
		L.contract_disease(/datum/ailment/malady/flatline, null, null, TRUE) // path, name, strain, bypass resist

		logTheThing(LOG_COMBAT, M, "uses the murder ability to induce cardiac arrest on [constructTarget(L,"combat")] at [log_loc(M)].")

	castcheck(mob/target)
		. = ..()
		var/mob/M = src.holder.owner

		if (isdead(target))
			boutput(M, SPAN_ALERT("It would be a waste of time to murder the dead."))
			return FALSE

		if (!iscarbon(target))
			boutput(M, SPAN_ALERT("[target] is immune to the disease."))
			return FALSE
