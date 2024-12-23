/datum/targetable/werewolf/werewolf_tainted_saliva
	name = "Tainted Saliva"
	desc = "Use your werewolf powers to add reagents from your body to your next attacks!."
	icon_state = "tainted-bite"  // No custom sprites yet.
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 2000
	pointCost = 0
	when_stunned = 2
	not_when_handcuffed = 0
	werewolf_only = 1

	cast(mob/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner
		if (!M)
			return 1
		var/datum/abilityHolder/werewolf/W = holder
		if (!istype(W))
			return 1
		if (M.reagents.total_volume == 0)
			boutput(M, SPAN_NOTICE("<B>You don't have any reagents in your bloodstream!</B>"))
			return 1

		. = ..()
		M.changeStatus("werewolf_saliva", 30 SECONDS)
		return 0

/datum/statusEffect/tainted_saliva
	id = "werewolf_saliva"
	name = "Tainted Saliva"
	desc = "Your bite wounds will inflict reagents that are in your own body."
	icon_state = "person"
	maxDuration = 300
	unique = 1

	onAdd(var/optional=null)
		. = ..()
		var/mob/living/M = owner
		if (!istype(M)) return

		var/datum/abilityHolder/werewolf/W
		if (M.abilityHolder)
			W = M.get_ability_holder(/datum/abilityHolder/werewolf)
		if (!W) return

		M.visible_message(SPAN_ALERT("<B>[M] starts salivating a disgusting amount!</B>"))
		W.tainted_saliva_reservoir.clear_reagents()
		M.reagents.copy_to(W.tainted_saliva_reservoir, 1, 1)
		M.reagents.clear_reagents()
		return

	onRemove()
		. = ..()
		var/mob/living/M = owner
		if (!istype(M)) return

		var/datum/abilityHolder/werewolf/W
		if (M.abilityHolder)
			W = M.get_ability_holder(/datum/abilityHolder/werewolf)
		if (!W) return

		W.tainted_saliva_reservoir.clear_reagents()
		boutput(M, SPAN_NOTICE("<B>You no longer will spread saliva when you attack!</B>"))
		M.visible_message(SPAN_NOTICE("<B>[M] stops dripping its disgusting saliva!</B>"))
		return
