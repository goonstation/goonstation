/datum/targetable/vampire/phaseshift_vampire
	name = "Bat Form"
	desc = "While active : Hold Sprint key to maintain Bat Form. You can squeeze through doors while this form is active, and steal blood from humans you fly over. This ability will depend on stamina just like normal sprint."
	icon_state = "batform"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	restricted_area_check = 0

	unlock_message = "You have gained Bat Form. When toggled on, you will be able to enter Bat Form by sprinting."

	var/level = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/carbon/human/M = holder.owner
		//var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		if (level == 1)
			M.special_sprint &= ~SPRINT_BAT_CLOAKED

			if (M.special_sprint & SPRINT_BAT)
				M.special_sprint &= ~SPRINT_BAT
				icon_state = "mist"
			else
				M.special_sprint |= SPRINT_BAT
				icon_state = "mist"
		else
			M.special_sprint &= ~SPRINT_BAT

			if (M.special_sprint & SPRINT_BAT_CLOAKED)
				M.special_sprint &= ~SPRINT_BAT_CLOAKED
				icon_state = "mist"
			else
				M.special_sprint |= SPRINT_BAT_CLOAKED
				icon_state = "mist"

		boutput(M, "<span class='notice'>Bat Form toggled [(M.special_sprint & SPRINT_BAT || M.special_sprint & SPRINT_BAT_CLOAKED ) ? "on" : "off"]. (Hold Sprint to activate - consumes stamina)</span>")

		return 0

/datum/targetable/vampire/phaseshift_vampire/mk2
	name = "Bat Form Mk2"
	desc = "While active : Hold Sprint key to maintain Bat Form. You can squeeze through doors while this form is active, and steal blood from humans you fly over. Your Bat Form is cloaked while standing in darkness."
	icon_state = "batform"
	level = 2

	unlock_message = "You have gained Bat Form Mk2. In addition to the previous effect, your bat form now cloaks in dark areas."

//ololdd
/datum/targetable/vampire/phaseshift_vampire_old
	name = "Mist form"
	desc = "Phase through walls. Only works when you can't be seen."
	icon_state = "mist"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 600
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 0
	restricted_area_check = 1
	var/duration = 50
	unlock_message = "You have gained mist form. It temporarily turns you incorporeal, allowing you to pass through solid objects."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		if (spell_invisibility(M, 1, 1, 0, 1) != 1) // Dry run. Can we phaseshift?
			return 1

		spell_invisibility(M, src.duration, 1)
		H.locked = 1 // Can't use any powers during phaseshift.
		SPAWN(src.duration)
			if (H) H.locked = 0

		logTheThing(LOG_COMBAT, M, "uses mist form at [log_loc(M)].")
		return 0
