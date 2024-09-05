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
	interrupt_action_bars = FALSE
	do_logs = FALSE

	unlock_message = "You have gained Bat Form. When toggled on, you will be able to enter Bat Form by sprinting."

	var/datum/special_sprint/sprint_datum = new /datum/special_sprint/poof/bat

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/carbon/human/M = holder.owner

		if (!M)
			return 1

		. = ..()
		if (istype(M.special_sprint, /datum/special_sprint/poof/bat))
			M.special_sprint = null
			icon_state = "batform"
		else
			M.special_sprint = src.sprint_datum
			icon_state = "batform-on"

		boutput(M, SPAN_NOTICE("Bat Form toggled [M.special_sprint ? "on" : "off"]. (Hold Sprint to activate - consumes stamina)"))

		return 0

/datum/targetable/vampire/phaseshift_vampire/mk2
	name = "Bat Form Mk2"
	desc = "While active : Hold Sprint key to maintain Bat Form. You can squeeze through doors while this form is active, and steal blood from humans you fly over. Your Bat Form is cloaked while standing in darkness."
	icon_state = "batform"
	sprint_datum = new /datum/special_sprint/poof/bat/cloak

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
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z
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

		. = ..()
		spell_invisibility(M, src.duration, 1)
		H.locked = 1 // Can't use any powers during phaseshift.
		SPAWN(src.duration)
			if (H) H.locked = 0

		logTheThing(LOG_COMBAT, M, "uses mist form at [log_loc(M)].")
		return 0
