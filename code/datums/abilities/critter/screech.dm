//ability for Fermids to potentially stun enemies when in combat
/datum/targetable/critter/screech
	name = "Primal Screech"
	desc = "Disorient your foes!"
	icon_state = "screech_fermid"
	targeted = FALSE
	cooldown = 60 SECONDS

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1
		. = ..()

		var/obj/itemspecialeffect/screech/screech_effect = new /obj/itemspecialeffect/screech
		screech_effect.color = "#ce0c0c"
		screech_effect.setup(holder.owner.loc)
		playsound(M.loc, 'sound/effects/screech_tone.ogg', 90, 1, pitch = 1)
		for (var/mob/living/HH in hearers(M, null))
			if (HH == M)
				continue

			if (!faction_check(M, HH, TRUE))
				continue

			if (issilicon(HH))
				HH.do_disorient(0, 30)
				continue
			HH.apply_sonic_stun(0, 0, 10, 0, 50, 0, 0)
		logTheThing(LOG_COMBAT, M, "uses primal screech at [log_loc(M)].")
		return 0
