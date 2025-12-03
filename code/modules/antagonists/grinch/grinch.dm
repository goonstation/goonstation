/datum/antagonist/grinch
	id = ROLE_GRINCH
	display_name = "grinch"
	antagonist_icon = "grinch"
	success_medal = "You're a mean one..."
	wiki_link = "https://wiki.ss13.co/Grinch"

	/// The ability holder of this grinch, containing their respective abilities.
	var/datum/abilityHolder/grinch/ability_holder

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		var/mob/living/carbon/human/H
		if (!ishuman(src.owner.current))
			return FALSE
		else
			H = src.owner.current
		var/datum/abilityHolder/grinch/A = H.get_ability_holder(/datum/abilityHolder/grinch)
		if (!A)
			src.ability_holder = H.add_ability_holder(/datum/abilityHolder/grinch)
		else
			src.ability_holder = A

		H.equip_if_possible(new /obj/item/clothing/under/shirt_pants_b(H), SLOT_W_UNIFORM)

		src.ability_holder.addAbility(/datum/targetable/grinch/vandalism)
		src.ability_holder.addAbility(/datum/targetable/grinch/poison)
		src.ability_holder.addAbility(/datum/targetable/grinch/instakill)
		src.ability_holder.addAbility(/datum/targetable/grinch/grinch_cloak)
		src.ability_holder.addAbility(/datum/targetable/grinch/slap)
		src.ability_holder.addAbility(/datum/targetable/grinch/evil_grin)
		src.ability_holder.addAbility(/datum/targetable/grinch/grinch_transform)

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/grinch/vandalism)
		src.ability_holder.removeAbility(/datum/targetable/grinch/poison)
		src.ability_holder.removeAbility(/datum/targetable/grinch/instakill)
		src.ability_holder.removeAbility(/datum/targetable/grinch/grinch_cloak)
		src.ability_holder.removeAbility(/datum/targetable/grinch/slap)
		src.ability_holder.removeAbility(/datum/targetable/grinch/evil_grin)
		src.ability_holder.removeAbility(/datum/targetable/grinch/grinch_transform)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/grinch)

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_GRINCH)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_GRINCH)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	assign_objectives()
		new /datum/objective_set/grinch(src.owner, src)

	on_death()
		. = ..()
		var/obj/respawn = locate(/obj/grinch_respawn_point) in world
		var/mob/player = src.owner.current
		var/job = pick("Clown", "Chef", "Botanist", "Rancher", "Janitor", "Engineer", "Miner", "Quartermaster", "Medical Doctor", "Geneticist", "Roboticist", "Scientist")
		player.add_filter("death fx", 1, displacement_map_filter(icon=icon('icons/effects/distort.dmi', "canister_pop"), size=0, y=8))
		animate(player.get_filter("death fx"), size=50, time=2 SECONDS, easing=SINE_EASING)
		var/mob/living/carbon/human/new_grinch = new /mob/living/carbon/human/normal (get_turf(respawn))
		new_grinch.JobEquipSpawned(job)
		SPAWN(2 SECONDS)
			player.gib()
		SPAWN(4 SECONDS)
			src.owner.current.mind.transfer_to(new_grinch)
			src.owner.current.changeStatus("unconscious", 60 SECONDS)

/obj/fakeobject/grinchrock
	name = "rock"
	anchored = ANCHORED
	density = 1
	icon = 'icons/misc/lunar.dmi'
	icon_state = "moonrock"

/obj/grinch_respawn_point
	name = "grinch respawn"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "strange-g"
