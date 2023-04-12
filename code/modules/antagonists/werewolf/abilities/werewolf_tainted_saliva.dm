/datum/targetable/werewolf/werewolf_tainted_saliva
	name = "Tainted Saliva"
	desc = "Use your werewolf powers to add reagents from your body to your next attacks!."
	icon_state = "tainted-bite"  // No custom sprites yet.
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 2000
	pointCost = 0
	incapacitation_restriction = 2
	can_cast_while_cuffed = TRUE
	werewolf_only = 1

	cast(mob/target)
		. = ..()
		M.changeStatus("werewolf_saliva", 30 SECONDS)

	castcheck()
		. = ..()
		var/mob/living/M = holder.owner
		if (!M.reagents.total_volume)
			boutput(M, "<span class='notice'><B>You don't have any reagents in your bloodstream!</B></span>")
			return FALSE

/datum/statusEffect/tainted_saliva
	id = "werewolf_saliva"
	name = "Tainted Saliva"
	desc = "Your bite wounds will inflict reagents that are in your own body."
	icon_state = "person"
	maxDuration = 30 SECONDS
	unique = TRUE

	onAdd()
		. = ..()
		var/mob/living/M = owner
		if (!istype(M)) return

		var/datum/abilityHolder/werewolf/AH
		if (M.abilityHolder)
			AH = M.get_ability_holder(/datum/abilityHolder/werewolf)
		if (!AH) return

		M.visible_message("<span class='alert'><B>[M] starts salivating a disgusting amount!</B></span>")
		AH.tainted_saliva_reservoir.clear_reagents()
		M.reagents.copy_to(AH.tainted_saliva_reservoir, do_not_react=TRUE)
		M.reagents.clear_reagents()

	onRemove()
		. = ..()
		var/mob/living/M = owner
		if (!istype(M)) return

		var/datum/abilityHolder/werewolf/AH
		if (M.abilityHolder)
			AH = M.get_ability_holder(/datum/abilityHolder/werewolf)
		if (!AH) return

		AH.tainted_saliva_reservoir.clear_reagents()
		boutput(M, "<span class='notice'><B>You no longer will spread saliva when you attack!</B></span>")
		M.visible_message("<span class='notice'><B>[M] stops dripping its disgusting saliva!</B></span>")
