/mob/living/critter/ice_phoenix
	name = "space phoenix"
	desc = "A majestic bird from outer space, sailing the solar winds. Until Space Station 13 came along, that is."
	icon = 'icons/mob/critter/nonhuman/icephoenix.dmi'
	icon_state = "icephoenix"

	hand_count = 2

	speechverb_say = "screeches"
	speechverb_gasp = "screeches"
	speechverb_stammer = "screeches"
	speechverb_exclaim = "screeches"
	speechverb_ask = "screeches"

	blood_id = "water" // maybe remove - this causes a lot of boiling if the phoenix is heated up

	/// if traveling off z level will return you to the station z level
	var/travel_back_to_station = FALSE

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_COLDPROT, src, 100)
		remove_lifeprocess(/datum/lifeprocess/radiation)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/sail)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/return_to_station)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/ice_barrier)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/glacier)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/map)
		//abilityHolder.addAbility(/datum/targetable/critter/fire_sprint)

	Life()
		. = ..()
		if (istype(get_turf(src), /turf/space))
			src.delStatus("burning")

	setup_healths()
		add_hh_flesh(100, 1)
		add_hh_flesh_burn(100, 1)
		add_health_holder(/datum/healthHolder/brain)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/ice_phoenix
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "talons"
		HH.limb_name = "talons"

		HH = hands[2]
		HH.name = "ice feather"
		HH.limb = new /datum/limb/gun/kinetic/ice_phoenix
		HH.icon_state = "fire_essence"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb_name = "ice feather"
		HH.can_hold_items = FALSE
		HH.can_range_attack = TRUE

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)

	specific_emotes(act, param = null, voluntary = FALSE)
		if (act == "flex" || act == "flexmuscles")
			if (src.emote_check(voluntary, 1 SECOND))
				return SPAN_ALERT("[src] proudly shows off its wings")

		return ..()

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		if (src.hasStatus("phoenix_ice_barrier"))
			brute /= 2
			burn /= 2
			tox /= 2
			src.delStatus("phoenix_ice_barrier")
		..()

	//specific_emote_type(var/act)
	//	switch (act)
	//		if ("scream")
	//			return 2
	//	return ..()

	Life()
		. = ..()

	//get_disorient_protection_eye()
	//	return(max(..(), 80))
	/*
	death(var/gibbed)
		playsound(src.loc, 'sound/impact_sounds/burn_sizzle.ogg', 100, 1)
		..(gibbed, 0)
		if (!gibbed)
			make_cleanable(/obj/decal/cleanable/ash,src.loc)
			ghostize()
			qdel(src)
	*/

	is_cold_resistant()
		return TRUE

	is_spacefaring()
		return TRUE

	proc/on_sail()
		src.setStatus("ice_phoenix_sail", 10 SECONDS)
		var/datum/targetable/critter/ice_phoenix/sail/abil = src.abilityHolder.getAbility(/datum/targetable/critter/ice_phoenix/sail)
		abil.afterAction()

