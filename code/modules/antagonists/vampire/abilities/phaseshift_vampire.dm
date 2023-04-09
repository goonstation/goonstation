/datum/targetable/vampire/phaseshift_vampire
	name = "Bat Form"
	desc = "While active : Hold Sprint key to maintain Bat Form. You can squeeze through doors while this form is active, and steal blood from humans you fly over. This ability will depend on stamina just like normal sprint."
	icon_state = "batform"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	incapacitation_restriction = 1
	can_cast_while_cuffed = TRUE

	unlock_message = "You have gained Bat Form. When toggled on, you will be able to enter Bat Form by sprinting."

	var/level = 1

	cast(mob/target)
		if (!isliving(holder.owner))
			return

		var/mob/living/M = holder.owner

		if (level == 1)
			M.special_sprint &= ~SPRINT_BAT_CLOAKED

			if (M.special_sprint & SPRINT_BAT)
				M.special_sprint &= ~SPRINT_BAT
				icon_state = "batform"
			else
				M.special_sprint |= SPRINT_BAT
				icon_state = "batform-on"
		else
			M.special_sprint &= ~SPRINT_BAT

			if (M.special_sprint & SPRINT_BAT_CLOAKED)
				M.special_sprint &= ~SPRINT_BAT_CLOAKED
				icon_state = "batform"
			else
				M.special_sprint |= SPRINT_BAT_CLOAKED
				icon_state = "batform-on"

		boutput(M, "<span class='notice'>Bat Form toggled [(M.special_sprint & SPRINT_BAT || M.special_sprint & SPRINT_BAT_CLOAKED ) ? "on (Hold Sprint to activate - consumes stamina)" : "off"]. </span>")

		return FALSE

/datum/targetable/vampire/phaseshift_vampire/mk2
	name = "Bat Form Mk2"
	desc = "While active : Hold Sprint key to maintain Bat Form. You can squeeze through doors while this form is active, and steal blood from humans you fly over. Your Bat Form is cloaked while standing in darkness."
	icon_state = "batform"
	level = 2

	unlock_message = "You have gained Bat Form Mk2. In addition to the previous effect, your bat form now cloaks in dark areas."
