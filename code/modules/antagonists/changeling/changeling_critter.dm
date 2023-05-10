ABSTRACT_TYPE(/datum/antagonist/changeling_critter)
/datum/antagonist/subordinate/changeling_critter
	remove_on_death = TRUE
	remove_on_clone = TRUE
	var/critter_type = null
	var/datum/abilityHolder/changeling/master_ability_holder

	give_equipment()
		src.master_ability_holder = src.master?.current?.get_ability_holder(/datum/abilityHolder/changeling)
		if (!src.master_ability_holder)
			return

		var/obj/item/bodypart
		for (var/datum/targetable/changeling/critter/ability in src.master_ability_holder.abilities)
			if (ability.antag_role == src.id)
				bodypart = ability.get_bodypart()
				break

		var/mob/old_mob = src.owner.current
		var/mob/living/critter/changeling/critter = new src.critter_type(get_turf(old_mob), bodypart)

		src.master_ability_holder.hivemind -= old_mob
		src.master_ability_holder.hivemind += critter
		critter.hivemind_owner = src.master_ability_holder
		if (src.master?.current && critter.client)
			var/I = image(antag_changeling, loc = src.master.current)
			critter.client.images += I
		src.owner.transfer_to(critter)
		qdel(old_mob)

	remove_equipment()
		src.master_ability_holder.hivemind -= src.owner.current

	announce()
		var/mob/living/critter/changeling/critter = src.owner.current
		if (!istype(critter))
			return ..()
		boutput(src.owner.current, "<h3><font color=red>You have reawakened to serve your host changeling, [src.master.current.real_name]! You must follow their commands!</font></h3>")

	announce_removal()
		return

	announce_objectives()
		return
/datum/antagonist/subordinate/changeling_critter/handspider
	id = ROLE_HANDSPIDER
	display_name = "handspider"
	critter_type = /mob/living/critter/changeling/handspider

	announce()
		..()
		boutput(src.owner.current, "<font color=red>You are a very small and weak creature that can fit into tight spaces. You are still connected to the hivemind.</font>")

/datum/antagonist/subordinate/changeling_critter/eyespider
	id = ROLE_EYESPIDER
	display_name = "eyespider"
	critter_type = /mob/living/critter/changeling/eyespider

	announce()
		..()
		boutput(src.owner.current, "<font color=red>You are a very small and weak creature that can fit into tight spaces, and see through walls. You are still connected to the hivemind.</font>")

/datum/antagonist/subordinate/changeling_critter/legworm
	id = ROLE_LEGWORM
	display_name = "legworm"
	critter_type = /mob/living/critter/changeling/legworm

	announce()
		..()
		boutput(src.owner.current, "<font color=red>You are a small creature that can deliver powerful kicks and fit into tight spaces. You are still connected to the hivemind.</font>")

/datum/antagonist/subordinate/changeling_critter/buttcrab
	id = ROLE_BUTTCRAB
	display_name = "buttcrab"
	critter_type = /mob/living/critter/changeling/buttcrab

	announce()
		..()
		boutput(src.owner.current, "<font color=red>You are a very small, very smelly, and weak creature. You are still connected to the hivemind.</font>")
