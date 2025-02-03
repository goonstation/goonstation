/mob/living/critter/ice_phoenix
	name = "space phoenix"
	desc = "A majestic bird from outer space, sailing the solar winds. Until Space Station 13 came along, that is."
	icon = 'icons/mob/critter/nonhuman/icephoenix.dmi'
	icon_state = "icephoenix"
	icon_state_dead = "icephoenix"

	hand_count = 2

	custom_hud_type = /datum/hud/critter/ice_phoenix

	speechverb_say = "screeches"
	speechverb_gasp = "screeches"
	speechverb_stammer = "screeches"
	speechverb_exclaim = "screeches"
	speechverb_ask = "screeches"

	blood_id = "water" // maybe remove - this causes a lot of boiling if the phoenix is heated up

	/// if traveling off z level will return you to the station z level
	var/travel_back_to_station = FALSE

	var/obj/minimap/ice_phoenix/map_obj
	var/atom/movable/minimap_ui_handler/station_map

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_COLDPROT, src, 100)
		remove_lifeprocess(/datum/lifeprocess/radiation)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)

		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/sail)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/thermal_shock)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/ice_barrier)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/glacier)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/wind_chill)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/touch_of_death)
		src.abilityHolder.addAbility(/datum/targetable/critter/ice_phoenix/permafrost)

		src.setStatus("phoenix_empowered_feather", INFINITE_STATUS)

	Life()
		. = ..()
		if (istype(get_turf(src), /turf/space))
			src.delStatus("burning")

			if (!src.hasStatus("phoenix_vulnerable") && !istype(get_area(src), /area/station))
				var/mult = max(src.tick_spacing, TIME - src.last_life_tick) / src.tick_spacing
				src.HealDamage("All", 2 * mult, 2 * mult)
				src.HealBleeding(0.1)

		var/area/A = get_area(src)
		if (istype(A, /area/station) && !A.permafrosted)
			src.setStatus("phoenix_vulnerable", 30 SECONDS)

			if (!src.hasStatus("phoenix_warmth_counter"))
				src.setStatus("phoenix_warmth_counter", INFINITE_STATUS)

		if (src.hasStatus("phoenix_vulnerable"))
			src.radiate_cold(get_turf(src))

	death()
		..()
		qdel(src)

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
		HH.icon_state = "feather"
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
		if (brute <= 0 && burn <= 0 && tox <= 0)
			return ..()
		if (src.hasStatus("phoenix_ice_barrier"))
			brute /= 2
			burn /= 2
			tox /= 2
			src.delStatus("phoenix_ice_barrier")
		src.setStatus("phoenix_vulnerable", 30 SECONDS)
		src.radiate_cold(get_turf(src))
		..()

	Move(turf/NewLoc, direct)
		if (istype(get_turf(src), /turf/space))
			var/obj/effects/ion_trails/I = new(get_turf(src))
			I.set_dir(src.dir)
			flick("ion_fade", I)
			I.icon_state = "blank"
			I.pixel_x = src.pixel_x
			I.pixel_y = src.pixel_y
			SPAWN(2 SECONDS)
				qdel(I)
		..()
		if (istype(NewLoc, /turf/space))
			EndSpacePush(src)
		var/area/A = get_area(src)
		if (istype(A, /area/station) && !A.permafrosted)
			src.setStatus("phoenix_vulnerable", 30 SECONDS)

			if (!src.hasStatus("phoenix_warmth_counter"))
				src.setStatus("phoenix_warmth_counter", INFINITE_STATUS)

		if (src.hasStatus("phoenix_vulnerable"))
			src.radiate_cold(get_turf(src))

		if (src.hasStatus("phoenix_vulnerable"))
			src.radiate_cold(NewLoc)

	movement_delay()
		. = ..()
		if (src.hasStatus("ice_phoenix_sail") && istype(get_turf(src), /turf/space))
			return . / 2

	//specific_emote_type(var/act)
	//	switch (act)
	//		if ("scream")
	//			return 2
	//	return ..()

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

	understands_language(langname)
		if (langname == src.say_language || langname == "feather" || langname == "english") // understands but can't speak flock
			return TRUE
		return FALSE

	proc/on_sail()
		src.setStatus("ice_phoenix_sail", 10 SECONDS)
		var/datum/targetable/critter/ice_phoenix/sail/abil = src.abilityHolder.getAbility(/datum/targetable/critter/ice_phoenix/sail)
		abil.afterAction()

	proc/create_ice_tunnel(turf/T)
		T.ReplaceWith(/turf/simulated/ice_phoenix_ice_tunnel, FALSE)
		T.set_dir(get_dir(src, T))
		playsound(T, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 50, TRUE)
		var/datum/targetable/critter/ice_phoenix/thermal_shock/abil = src.abilityHolder.getAbility(/datum/targetable/critter/ice_phoenix/thermal_shock)
		abil.afterAction()

	proc/show_map()
		if (!src.map_obj)
			src.map_obj = new

		if (!src.station_map)
			src.station_map = new(src, "ice_phoenix_map", src.map_obj, "Space Map", "ntos")
			src.map_obj.map.create_minimap_marker(src, 'icons/obj/minimap/minimap_markers.dmi', "pin")

		src.station_map.ui_interact(src)

	proc/toggle_return_to_station()
		src.travel_back_to_station = !src.travel_back_to_station
		if (src.travel_back_to_station)
			boutput(src, SPAN_NOTICE("You will now travel back to station space when traveling off the Z level"))
		else
			boutput(src, SPAN_NOTICE("You will no longer travel back to station space when traveling off the Z level"))

	proc/radiate_cold(turf/center)
		var/obj/phoenix_snow_floor/floor
		var/icon_s
		var/direct
		for (var/turf/space/T in block(center.x - 1, center.y - 1, center.z, center.x + 1, center.y + 1, center.z))
			floor = locate() in T

			if (floor)
				icon_s = floor.icon_state
				direct = floor.dir
				qdel(floor)
			floor = new /obj/phoenix_snow_floor(T)
			if (icon_s)
				floor.icon_state = icon_s
				floor.set_dir(direct)

/obj/phoenix_snow_floor
	name = "compacted snow floor"
	desc = "A floating layer of compacted snow and ice in space. How is that even possible?"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow1"
	layer = PLATING_LAYER
	plane = PLANE_UNDERFLOOR
	anchored = ANCHORED_ALWAYS
	stops_space_move = TRUE
	alpha = 160

	New()
		..()
		src.icon_state = pick("snow1", "snow2", "snow_rough1")
		src.set_dir(pick(cardinal))
		SPAWN(6 SECONDS)
			animate(src, 6 SECONDS, alpha = 80)
		SPAWN(12 SECONDS) // 45 SECONDS
			qdel(src)

/turf/simulated/ice_phoenix_ice_tunnel
	icon = 'icons/mob/critter/nonhuman/icephoenix.dmi'
	icon_state = "ice_tunnel"
	density = FALSE
	opacity = FALSE
	name = "ice tunnel"
	desc = "A narrow ice tunnel that seems to prevent passage of air by a thick, icy mist. Interesting."
	gas_impermeable = TRUE

	New(newLoc, direct)
		src.dir = direct
		if (src.dir == NORTH)
			src.dir = SOUTH

		if (src.dir == NORTH || src.dir == SOUTH)
			src.blocked_dirs = EAST | WEST
		else
			src.blocked_dirs = NORTH | SOUTH
		..()

/obj/ice_phoenix_statue
	icon = 'icons/mob/critter/nonhuman/icephoenix.dmi'
	icon_state = "icephoenix"
	name = "ice statue"
	desc = "Some sort of ice statue resembling a phoenix. It's emanating an aura."
	density = TRUE
	anchored = ANCHORED_ALWAYS
	color = "#0400da"
	var/health = 200

	attack_hand(mob/user)
		attack_particle(user, src)
		user.lastattacked = src
		boutput(user, SPAN_NOTICE("It's really cold!"))
		if (!ON_COOLDOWN(src, "hit_impact_sound", 2 SECONDS))
			playsound(get_turf(src), 'Glass_Shards_Hit_1.ogg', 75, TRUE)
		..()

	attackby(obj/item/I, mob/user)
		..()
		attack_particle(user, src)
		user.lastattacked = src

		if (!I.force)
			return

		hit_twitch(src)
		src.health -= I.force
		if (src.health <= 0)
			qdel(src)
			return

		if (!ON_COOLDOWN(src, "hit_impact_sound", 2 SECONDS))
			playsound(get_turf(src), 'Glass_Shards_Hit_1.ogg', 75, TRUE)

	bullet_act(obj/projectile/P)
		if (istype(P.proj_data, /datum/projectile/bullet/ice_phoenix_icicle))
			return
		if (P.proj_data.ks_ratio >= 1)
			hit_twitch(src)
			src.health -= P.power
			if (src.health <= 0)
				qdel(src)
				return
			if (!ON_COOLDOWN(src, "hit_impact_sound", 2 SECONDS))
				playsound(get_turf(src), 'Glass_Shards_Hit_1.ogg', 75, TRUE)
		..()

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			qdel(src)
			return
		if (!ON_COOLDOWN(src, "hit_impact_sound", 2 SECONDS))
			playsound(get_turf(src), 'Glass_Shards_Hit_1.ogg', 75, TRUE)

	ex_act()
		qdel(src)

	disposing()
		src.visible_message(SPAN_ALERT("[src] shatters!"))
		playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_[pick(1, 2, 3)].ogg", 75, TRUE)
		var/area/A = get_area(src)
		A.remove_permafrost()
		..()
