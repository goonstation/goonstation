/datum/targetable/critter/fire_sprint
	name = "Fire Form"
	desc = "While active : Hold Sprint key to maintain Fire Form. You will leave a trail of flames while in use. This ability will depend on stamina just like normal sprint."
	icon_state = "fire_e_sprint"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/carbon/human/M = holder.owner
		//var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		if (M.special_sprint & SPRINT_FIRE)
			M.special_sprint &= ~SPRINT_FIRE
		else
			M.special_sprint |= SPRINT_FIRE

		boutput(M, "<span class='notice'>Fire Form toggled [(M.special_sprint & SPRINT_FIRE ) ? "on" : "off"]. (Hold Sprint to activate - consumes stamina)</span>")

		return 0
