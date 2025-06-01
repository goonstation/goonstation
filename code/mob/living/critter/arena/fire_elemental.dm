/mob/living/critter/fire_elemental
	name = "fire elemental"
	real_name = "fire elemental"
	desc = "You can't tell if this person is on fire, or made of it. Or both."
	icon = 'icons/mob/critter/humanoid/elemental/fire.dmi'
	icon_state = "fire_elemental"
	density = 1
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
					return SPAN_ALERT("<b>[src] wails!</b>")

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
		HH.limb = new /datum/limb/gun/kinetic/fire_elemental
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
		abilityHolder.addAbility(/datum/targetable/critter/self_immolate)
		abilityHolder.addAbility(/datum/targetable/critter/flamethrower/throwing)
		abilityHolder.addAbility(/datum/targetable/critter/fireball)
		abilityHolder.addAbility(/datum/targetable/critter/fire_sprint)
		var/datum/statusEffect/simplehot/S = src.setStatus("simplehot", INFINITE_STATUS)
		S.visible = 0
		S.heal_brute = 0.25
		S.heal_tox = 0.5

	Life()
		var/turf/T = src.loc
		if (istype(T, /turf))
			T.hotspot_expose(1500,200)

		var count = 0
		for (var/atom/movable/hotspot/chemfire/cf in range(4, T))
			if (count > 7) return
			if (cf.fire_color != CHEM_FIRE_DARKRED) continue
			if (prob(50)) continue
			var/obj/projectile/proj = initialize_projectile_pixel_spread(cf, new/datum/projectile/special/homing/fire_heal, src)
			proj.launch()
			count += 1
			if(prob(30))
				break

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

	is_heat_resistant()
		return TRUE


/datum/projectile/special/homing/fire_heal
	icon_state = "ember"
	start_speed = 3
	goes_through_walls = 0
	//goes_through_mobs = 1
	auto_find_targets = 0
	silentshot = 1
	pierces = 0
	max_range = 6
	shot_sound = null

	on_launch(var/obj/projectile/P)
		P.layer = EFFECTS_LAYER_BASE
		// FLICK("ember",P)
		P.special_data["returned"] = FALSE

		..()

	proc/place_fire(hit)
		var/turf/T = get_turf(hit)
		if (!T || istype(T, /turf/space))
			return
		var/atom/movable/hotspot/chemfire/cf = locate(/atom/movable/hotspot/chemfire) in T
		if (cf == null)
			fireflash(T, 0, 2500, 0, chemfire = CHEM_FIRE_DARKRED)

	on_hit(atom/hit, direction, var/obj/projectile/P)
		if(istype(hit, /mob/living/critter/fire_elemental))
			var/mob/living/critter/fire_elemental/fe = hit
			fe.HealDamage("All", 5, 5, 5)
			fe.add_stamina(10)
			// place_fire(hit)

		else if (istype(hit, /mob))
			place_fire(hit)
		else if (istype(hit, /obj))
			place_fire(hit)

		..()

