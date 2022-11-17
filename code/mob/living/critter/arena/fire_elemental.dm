/mob/living/critter/fire_elemental
	name = "fire elemental"
	real_name = "fire elemental"
	desc = "You can't tell if this person is on fire, or made of it. Or both."
	density = 1
	icon_state = "fire_elemental"
	custom_gib_handler = /proc/fire_elemental_gibs
	hand_count = 3
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	blood_id = "phlogiston"
	burning_suffix = "humanoid"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 1, pitch = 0.5, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] wails!</span></b>"

		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/suit(src)
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[3]
		HH.name = "control of fire"
		HH.limb = new /datum/limb/gun/fire_elemental
		HH.icon_state = "fire_essence"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb_name = "fire essence"
		HH.can_hold_items = 0
		HH.can_attack = 1
		HH.can_range_attack = 1

	setup_healths()
		add_hh_flesh(150, 1.15)
		add_health_holder(/datum/healthHolder/brain)

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/cauterize)
		abilityHolder.addAbility(/datum/targetable/critter/flamethrower/throwing)
		abilityHolder.addAbility(/datum/targetable/critter/fireball)
		abilityHolder.addAbility(/datum/targetable/critter/fire_sprint)
		var/datum/statusEffect/simplehot/S = src.setStatus("simplehot", INFINITE_STATUS)
		S.visible = 0
		S.heal_brute = 0.25

	Life()
		var/turf/T = src.loc
		if (istype(T, /turf))
			T.hotspot_expose(1500,200)
		.=..()

	get_disorient_protection_eye()
		return(max(..(), 80))

	death(var/gibbed)
		playsound(src.loc, 'sound/impact_sounds/burn_sizzle.ogg', 100, 1)
		..(gibbed, 0)
		if (!gibbed)
			make_cleanable(/obj/decal/cleanable/ash,src.loc)
			ghostize()
			qdel(src)
