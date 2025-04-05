/mob/living/critter/space_phoenix
	name = "space phoenix"
	real_name = "space phoenix"
	desc = "A majestic bird from outer space, sailing the solar winds. Until Space Station 13 came along, that is."
	icon = 'icons/mob/critter/nonhuman/spacephoenix.dmi'
	icon_state = "spacephoenix"
	icon_state_dead = "spacephoenix"

	hand_count = 2

	custom_hud_type = /datum/hud/critter/space_phoenix

	speechverb_say = "screeches"
	speechverb_gasp = "screeches"
	speechverb_stammer = "screeches"
	speechverb_exclaim = "screeches"
	speechverb_ask = "screeches"

	blood_id = "water"

	butcherable = BUTCHER_ALLOWED
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget

	can_interface_with_pods = FALSE

	/// if traveling off z level will return you to the station z level
	var/travel_back_to_station = FALSE

	/// extra life regen granted by dead mobs in its nest
	var/extra_life_regen = 0
	var/has_revived = FALSE

	/// all humans that have ever been collected in nest
	var/list/collected_humans = list()
	/// all critters that have ever been collected in nest
	var/list/collected_critters = list()
	/// all areas that have ever been permafrosted
	var/list/permafrosted_areas = list()

	var/obj/minimap/space_phoenix/map_obj
	var/atom/movable/minimap_ui_handler/station_map
	var/turf/nest_location

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_COLDPROT, src, 100)
		remove_lifeprocess(/datum/lifeprocess/radiation)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)

		QDEL_NULL(src.organHolder)

			Life()
		. = ..()
		if (istype(get_turf(src), /turf/space))
			src.delStatus("burning")

			if (!src.hasStatus("phoenix_vulnerable"))
				var/mult = max(src.tick_spacing, TIME - src.last_life_tick) / src.tick_spacing
				src.HealDamage("All", (2 + src.extra_life_regen) * mult, (2 + src.extra_life_regen) * mult)
				src.HealBleeding(0.1)

		if (src.in_dangerous_place())
			src.changeStatus("phoenix_vulnerable", 5 SECONDS)

			if (!src.hasStatus("phoenix_warmth_counter"))
				src.setStatus("phoenix_warmth_counter", INFINITE_STATUS)

		if (src.hasStatus("phoenix_vulnerable"))
			src.radiate_cold(get_turf(src))

		if (src.bodytemperature >= initial(src.bodytemperature))
			src.bodytemperature = max(initial(src.bodytemperature), src.bodytemperature - 10)

	death(gibbed)
		if (src.hasStatus("phoenix_revive_ready") && !gibbed)
			src.full_heal()
			src.has_revived = TRUE
			src.delStatus("phoenix_revive_ready")
			var/turf/T = get_turf(src)
			T.visible_message(SPAN_ALERT("[src] resurrects with a mighty grace!"))
			playsound(get_turf(src), 'sound/misc/phoenix/phoenix_revive.ogg', 100, TRUE)
			src.Scale(1.5, 1.5)
			SPAWN(3 SECONDS)
				src.Scale(2 / 3, 2 / 3)
			return

		REMOVE_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)

		var/area/phoenix_nest/A = get_area(src.nest_location)
		A.owning_phoenix = null
		get_image_group(CLIENT_IMAGE_GROUP_TEMPERATURE_OVERLAYS).remove_mob(src)
		animate_180_rest(src)
		..()

	full_heal()
		if (isdead(src))
			animate_180_rest(src, TRUE)
		..()

	setup_healths()
		add_hh_flesh(100, 1)
		add_hh_flesh_burn(100, 1)
		add_health_holder(/datum/healthHolder/brain)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/space_phoenix
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "talons"
		HH.limb_name = "talons"

		HH = hands[2]
		HH.name = "ice feather"
		HH.limb = new /datum/limb/gun/kinetic/space_phoenix
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
		else if (act == "scream" && voluntary && src.emote_check(voluntary, 5 SECONDS))
			if (src.emote_check(voluntary, 5 SECONDS))
				playsound(src.loc, 'sound/voice/screams/phoenix_scream.ogg', 80, TRUE)
				return SPAN_ALERT("[src] makes a mysterious sound!")

		return ..()

	attack_hand(mob/living/M)
		..()
		if (istype(M, /mob/living/critter/space_phoenix))
			return
		if (M.a_intent != INTENT_HELP)
			return
		M.TakeDamage("All", burn = 5)
		M.changeStatus("shivering", 1 SECOND, TRUE)
		M.bodytemperature -= 5
		boutput(M, SPAN_ALERT("[src] is freezing cold!!!"))

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		if (brute <= 0 && burn <= 0 && tox <= 0)
			return ..()
		if (src.hasStatus("phoenix_ice_barrier") && (brute + burn + tox) > 10)
			var/dmg_mod = (brute + burn + tox) / 10
			brute /= dmg_mod
			burn /= dmg_mod
			tox /= dmg_mod
		src.setStatus("phoenix_vulnerable", 30 SECONDS)
		src.radiate_cold(get_turf(src))
		..()

	do_disorient(stamina_damage, knockdown, stunned, unconscious, disorient, remove_stamina_below_zero, target_type, stack_stuns)
		if (src.hasStatus("phoenix_ice_barrier"))
			stamina_damage = min(stamina_damage, 20)
		..()
		if (stamina_damage > 0)
			src.setStatus("phoenix_vulnerable", 30 SECONDS)
			src.radiate_cold(get_turf(src))

	apply_flash(animation_duration, knockdown, stun, misstep, eyes_blurry, eyes_damage, eye_tempblind, burn, uncloak_prob, stamina_damage, disorient_time)
		if (src.hasStatus("phoenix_ice_barrier"))
			stamina_damage = min(stamina_damage, 20)
		..()
		src.setStatus("phoenix_vulnerable", 30 SECONDS)
		src.radiate_cold(get_turf(src))

	Move(turf/NewLoc, direct)
		if (istype(get_turf(src), /turf/space))
			var/obj/effects/ion_trails/I = new(get_turf(src))
			if (src.hasStatus("phoenix_revive_ready"))
				I.color = "#ea00ff"
			I.set_dir(src.dir)
			FLICK("ion_fade", I)
			I.icon_state = "blank"
			I.pixel_x = src.pixel_x
			I.pixel_y = src.pixel_y
			SPAWN(2 SECONDS)
				qdel(I)
		..()
		if (istype(NewLoc, /turf/space))
			EndSpacePush(src)

		if (src.in_dangerous_place())
			src.changeStatus("phoenix_vulnerable", 5 SECONDS)

			if (!src.hasStatus("phoenix_warmth_counter"))
				src.setStatus("phoenix_warmth_counter", INFINITE_STATUS)

		if (src.hasStatus("phoenix_vulnerable"))
			src.radiate_cold(get_turf(src))

		if (src.hasStatus("phoenix_vulnerable"))
			src.radiate_cold(NewLoc)

	movement_delay()
		. = ..()
		if (src.hasStatus("space_phoenix_sail") && istype(get_turf(src), /turf/space))
			return . / 2

	is_cold_resistant()
		return TRUE

	is_spacefaring()
		return TRUE

	understands_language(langname)
		if (langname == src.say_language || langname == "feather" || langname == "english") // understands but can't speak flock
			return TRUE
		return FALSE

	proc/create_ice_tunnel(atom/A)
		playsound(get_turf(A), 'sound/impact_sounds/Crystal_Shatter_1.ogg', 50, TRUE)
		if (istype(A, /turf) || istype(A, /obj/window))
			var/turf/T = get_turf(A)
			T.ReplaceWith(/turf/simulated/space_phoenix_ice_tunnel, FALSE)
			T.set_dir(get_dir(src, T))
			if (istype(A, /obj/window))
				for (var/obj/mesh/grille/grille in get_turf(A))
					qdel(grille)
				qdel(A)
		else if (istype(A, /obj/structure/girder))
			for (var/obj/structure/girder/girder in get_turf(A))
				qdel(girder)
		var/datum/targetable/critter/space_phoenix/thermal_shock/abil = src.abilityHolder.getAbility(/datum/targetable/critter/space_phoenix/thermal_shock)
		abil.afterAction()
		logTheThing(LOG_STATION, src, "[src] creates an ice tunnel at [log_loc(A)]")

	proc/show_map()
		if (!src.map_obj)
			src.map_obj = new

		if (!src.station_map)
			src.station_map = new(src, "space_phoenix_map", src.map_obj, "Space Map", "ntos")
			src.map_obj.map.create_minimap_marker(src, 'icons/obj/minimap/minimap_markers.dmi', "pin")
			src.map_obj.map.create_minimap_marker(src.nest_location, 'icons/obj/minimap/minimap_markers.dmi', "cryo")

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

	///Check our current location to see if we're in a dangerous(ly warm) place
	proc/in_dangerous_place()
		. = TRUE
		var/area/A = get_area(src)
		if (A.permafrosted || !istype(A, /area/station))
			return FALSE
		var/turf/T = get_turf(src)
		if (istype(T, /turf/space) || istype(T, /turf/simulated/floor/airless) || istype(T, /turf/simulated/space_phoenix_ice_tunnel))
			return FALSE

/image/phoenix_temperature_indicator
	plane = PLANE_HUD
	var/mob/living/carbon/human/holding_mob

	New(icon, loc, icon_state, layer, dir, mob_to_add)
		..()
		get_image_group(CLIENT_IMAGE_GROUP_TEMPERATURE_OVERLAYS).add_image(src)
		src.holding_mob = mob_to_add
		src.holding_mob.vis_contents += src
		src.update_temperature(src.holding_mob.bodytemperature)

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_TEMPERATURE_OVERLAYS).remove_image(src)
		src.holding_mob.vis_contents -= src
		..()

	proc/update_temperature(temperature)
		var/temp_f = floor((temperature - 273.15) * 1.8 + 32)
		if (temp_f > 200)
			src.color = "#ff0f0f"
		else if (temp_f > 100)
			src.color = "#ff9925"
		else if (temp_f > 60) // near human body temperature
			src.color = "#ffffff"
		else if (temp_f > 0)
			src.color = "#1696ff"
		else
			src.color = "#1c3eff"

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
		SPAWN(12 SECONDS)
			qdel(src)

	Crossed(atom/movable/AM, atom)
		..()
		if (istype(AM, /mob/living))
			var/mob/living/L = AM
			APPLY_ATOM_PROPERTY(L, PROP_MOB_SPACE_DAMAGE_IMMUNE, "phoenix_snow_floor")

	Uncrossed(Obj, newloc)
		..()
		if (istype(Obj, /mob/living))
			var/mob/living/L = Obj
			REMOVE_ATOM_PROPERTY(L, PROP_MOB_SPACE_DAMAGE_IMMUNE, "phoenix_snow_floor")

/turf/simulated/space_phoenix_ice_tunnel
	icon = 'icons/mob/critter/nonhuman/spacephoenix.dmi'
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

/obj/space_phoenix_statue
	icon = 'icons/mob/critter/nonhuman/spacephoenix.dmi'
	icon_state = "spacephoenix"
	name = "ice statue"
	desc = "Some sort of ice statue resembling a phoenix. It's emanating an aura."
	density = TRUE
	anchored = ANCHORED_ALWAYS
	color = "#0400da"
	var/health = 200

	attack_hand(mob/user)
		attack_particle(user, src)
		user.lastattacked = get_weakref(src)
		boutput(user, SPAN_NOTICE("It's really cold!"))
		if (!ON_COOLDOWN(src, "hit_impact_sound", 2 SECONDS))
			playsound(get_turf(src), 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 75, TRUE)
		..()

	attackby(obj/item/I, mob/user)
		..()
		attack_particle(user, src)
		user.lastattacked = get_weakref(src)

		if (!I.force)
			return

		hit_twitch(src)
		src.health -= I.force

		if (I.firesource)
			if (!(locate(/obj/decal/cleanable/water) in get_turf(src)))
				make_cleanable(/obj/decal/cleanable/water, get_turf(src))

		if (src.health <= 0)
			qdel(src)
			return

		playsound(get_turf(src), 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 75, TRUE)

	bullet_act(obj/projectile/P)
		if (istype(P.proj_data, /datum/projectile/bullet/space_phoenix_icicle))
			return
		if (P.proj_data.ks_ratio >= 1)
			hit_twitch(src)
			src.health -= P.power

			if (P.proj_data.damage_type == D_BURNING)
				if (!(locate(/obj/decal/cleanable/water) in get_turf(src)))
					make_cleanable(/obj/decal/cleanable/water, get_turf(src))

			if (src.health <= 0)
				qdel(src)
				return
			if (!ON_COOLDOWN(src, "hit_impact_sound", 2 SECONDS))
				playsound(get_turf(src), 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 75, TRUE)
		..()

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			qdel(src)
			return
		playsound(get_turf(src), 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 75, TRUE)

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled)
		..()
		if (exposed_temperature > 273.15)
			if (exposed_temperature > 505.93)
				src.health -= 15
			else
				src.health -= 5

			if (src.health <= 0)
				qdel(src)

	ex_act()
		qdel(src)

	disposing()
		src.visible_message(SPAN_ALERT("[src] shatters!"))
		playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_[pick(1, 2, 3)].ogg", 75, TRUE)
		var/area/A = get_area(src)
		A.remove_permafrost()
		for (var/i = 1 to rand(4, 5))
			var/obj/item/raw_material/ice/ice_piece = new(get_turf(src))
			ice_piece.pixel_x += rand(-10, 10)
			ice_piece.pixel_x += rand(-7, 7)
		logTheThing(LOG_STATION, src, "[src] is destroyed at [log_loc(src)], removing permafrost from the area")
		..()

/area/phoenix_nest
	name = "Space Phoenix Nest"
	skip_sims = TRUE
	var/mob/living/critter/space_phoenix/owning_phoenix = null
	var/list/humans_for_revive = list()
	var/list/entered_humans = list()
	var/list/entered_critters = list()

	Entered(atom/movable/AM, atom/oldloc)
		..()
		if (!src.owning_phoenix)
			if (istype(AM, /mob/living/critter/space_phoenix))
				src.owning_phoenix = AM
				src.owning_phoenix.nest_location = get_turf(AM)
		src.atom_entered(AM)

	Exited(atom/movable/AM)
		src.atom_exited(AM)
		..()

	proc/atom_entered(atom/movable/AM)
		if (!src.owning_phoenix)
			return
var/datum/abilityHolder/space_phoenix/ability_holder = src.owning_phoenix.get_ability_holder(/datum/abilityHolder/space_phoenix)
		if (istype(AM, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = AM
			if (!isdead(H))
				H.setStatus("in_phoenix_nest", INFINITE_STATUS)
			else if (H.last_ckey)
				if (!(H in src.humans_for_revive))
					src.humans_for_revive += H
					if (length(src.humans_for_revive) >= 5 && !src.owning_phoenix.hasStatus("phoenix_revive_ready") && !src.owning_phoenix.has_revived)
						src.owning_phoenix.setStatus("phoenix_revive_ready", INFINITE_STATUS)
				if (!(H in src.entered_humans))
					src.entered_humans += H
					ability_holder.stored_human_count++
					src.owning_phoenix.extra_life_regen += 0.3
				src.owning_phoenix.collected_humans |= "[H.real_name]-\ref[H]"
				H.setStatus("cold_snap", INFINITE_STATUS)
		else if (istype(AM, /mob/living/critter))
			var/mob/living/critter/C = AM
			if (!isdead(C))
				C.setStatus("in_phoenix_nest", INFINITE_STATUS)
			else if (!(C in src.entered_critters) && !C.last_ckey)
				src.entered_critters += C
				ability_holder.stored_critter_count++
				src.owning_phoenix.extra_life_regen += 0.3
				src.owning_phoenix.collected_critters |= "[C.real_name]-\ref[C]"
				C.setStatus("cold_snap", INFINITE_STATUS)
ability_holder.updateText(FALSE)

	proc/atom_exited(atom/movable/AM)
		if (!src.owning_phoenix)
			return
var/datum/abilityHolder/space_phoenix/ability_holder = src.owning_phoenix.get_ability_holder(/datum/abilityHolder/space_phoenix)
		if (istype(AM, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = AM
			if (!isdead(H))
				H.delStatus("in_phoenix_nest")
			if (H in src.entered_humans)
				src.owning_phoenix.extra_life_regen -= 0.3
				src.entered_humans -= H
				ability_holder.stored_human_count--
				H.delStatus("cold_snap")
		else if (istype(AM, /mob/living/critter))
			var/mob/living/critter/C = AM
			if (!isdead(C))
				C.delStatus("in_phoenix_nest")
			if (C in src.entered_critters)
				src.owning_phoenix.extra_life_regen -= 0.3
				src.entered_critters -= C
				ability_holder.stored_critter_count--
				C.delStatus("cold_snap")

		ability_holder.updateText(FALSE)
