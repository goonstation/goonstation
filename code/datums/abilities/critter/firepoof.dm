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
	var/datum/special_sprint/sprint_datum = new /datum/special_sprint/poof/fire

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/carbon/human/M = holder.owner
		//var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		. = ..()
		if (istype(M.special_sprint, /datum/special_sprint/poof/fire))
			M.special_sprint = null
		else
			M.special_sprint = src.sprint_datum

		boutput(M, SPAN_NOTICE("Fire Form toggled [M.special_sprint ? "on" : "off"]. (Hold Sprint to activate - consumes stamina)"))

		return 0
