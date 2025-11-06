/*
 * Copyright (C) 2025 Mr. Moriarty
 * Copyright (C) 2025 DisturbHerb
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 5.2%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/turf/unsimulated/floor/auto/trench
	name = "trench"
	icon = 'icons/turf/trenches/trenches.dmi'
	icon_state = "trench-0"
	pass_unstable = TRUE
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_TRENCH
	can_replace_with_stuff = TRUE

	var/old_type

	New()
		. = ..()

		if (!src.buried_storage)
			src.buried_storage = new /atom/movable/buried_storage(src)

		src.buried_storage.move_storage_contents_to_turf()
		src.update_trench_overlay()

	Del()
		src.buried_storage.move_turf_contents_to_storage()

		SPAWN(0)
			for (var/turf/T in orange(src, 1))
				var/direction = get_dir(T, src)
				T.ClearSpecificOverlays("edge_[direction]")

			for (var/turf/unsimulated/floor/auto/T in orange(src, 1))
				T.edge_overlays()

				if (istype(T, /turf/unsimulated/floor/auto/trench))
					var/turf/unsimulated/floor/auto/trench/trench = T
					trench.update_trench_overlay(FALSE)

		. = ..()

	Cross(atom/movable/AM)
		var/turf/T = get_turf(AM)
		if (T && ismob(AM) && !HAS_ATOM_PROPERTY(AM, PROP_ATOM_FLOATING) && !istype(T, /turf/unsimulated/floor/auto/trench))
			return FALSE

		. = ..()

	Enter(atom/AM)
		var/mob/M = AM
		var/turf/T = get_turf(M)
		if (T && ismob(M) && !HAS_ATOM_PROPERTY(AM, PROP_ATOM_FLOATING) && !istype(T, /turf/unsimulated/floor/auto/trench))
			if (!M.throwing && isalive(M))
				if (M.client && !M.client.check_key(KEY_RUN) && !M.client.check_key(KEY_BOLT))
					return
				actions.start(new /datum/action/bar/climb_trench(M, src), M)

			else
				src.fall_down_trench(M)

			return

		. = ..()

	Exit(atom/AM, turf/T)
		var/mob/M = AM
		if (T && ismob(M) && !HAS_ATOM_PROPERTY(AM, PROP_ATOM_FLOATING) && !istype(T, /turf/unsimulated/floor/auto/trench))
			if (!M.throwing && isalive(M))
				if (M.client && !M.client.check_key(KEY_RUN) && !M.client.check_key(KEY_BOLT))
					return
				actions.start(new /datum/action/bar/climb_trench(M, T), M)

			return

		. = ..()

	attackby(obj/item/I, mob/user, params, is_special)
		if (isdiggingtool(I))
			actions.start(new/datum/action/bar/dig_trench(src), user)
			return

		. = ..()

	dig_trench()
		src.ReplaceWith(global.map_settings.space_turf_replacement || src.old_type)
		src.reset_terrainify_effects()

	edge_overlays()
		for (var/turf/T in orange(src, 1))
			if (istype(T, /turf/unsimulated/floor/auto))
				var/turf/unsimulated/floor/auto/TA = T
				if (TA.edge_priority_level >= src.edge_priority_level)
					continue
			var/direction = get_dir(T, src)
			var/image/edge_overlay = image('icons/turf/trenches/border_overlays.dmi', "overlay-[direction]")
			edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
			edge_overlay.layer = src.layer + (src.edge_priority_level / 1000)
			edge_overlay.plane = PLANE_FLOOR
			T.UpdateOverlays(edge_overlay, "edge_[direction]")

	proc/update_trench_overlay(update_neighbors = TRUE)
		var/connected_directions = 0
		// Cardinal
		for (var/dir in cardinal)
			var/turf/CT = get_step(src, dir)

			if (istype(CT, /turf/unsimulated/floor/auto/trench))
				connected_directions |= dir

				if (update_neighbors)
					var/turf/unsimulated/floor/auto/trench/neighbour = CT
					neighbour.update_trench_overlay(FALSE)

		// Ordinal
		for (var/i = 1 to 4)
			var/ordir = ordinal[i]
			var/turf/OT = get_step(src, ordir)

			if (istype(OT, /turf/unsimulated/floor/auto/trench) && ((ordir & connected_directions) == ordir))
				connected_directions |= 8 << i

				if (update_neighbors)
					var/turf/simulated/floor/auto/trench/neighbour = OT
					neighbour.update_trench_overlay(FALSE)

		src.icon_state = "trench-[connected_directions]"

	proc/fall_down_trench(mob/M)
		M.set_loc(src)
		M.visible_message(SPAN_ALERT("[M] falls into the trench!"))
		M.TakeDamage("All", 15, 0, 0, DAMAGE_BLUNT)
		M.changeStatus("stunned", 2 SECONDS)

		if (isliving(M) && !M.stat)
			var/mob/living/L = M
			playsound(L.loc, L.sound_scream, 100, 0, 0, L.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)

/turf/simulated/floor/auto/trench
	name = "trench"
	icon = 'icons/turf/trenches/trenches.dmi'
	icon_state = "trench-0"
	pass_unstable = TRUE
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_TRENCH

	var/old_type

	New()
		. = ..()

		if (!src.buried_storage)
			src.buried_storage = new /atom/movable/buried_storage(src)

		src.buried_storage.move_storage_contents_to_turf()
		src.update_trench_overlay()

	Del()
		src.buried_storage.move_turf_contents_to_storage()

		SPAWN(0)
			for (var/turf/T in orange(src, 1))
				var/direction = get_dir(T, src)
				T.ClearSpecificOverlays("edge_[direction]")

			for (var/turf/simulated/floor/auto/T in orange(src, 1))
				T.edge_overlays()

				if (istype(T, /turf/simulated/floor/auto/trench))
					var/turf/simulated/floor/auto/trench/trench = T
					trench.update_trench_overlay(FALSE)

		. = ..()

	Cross(atom/movable/AM)
		var/turf/T = get_turf(AM)
		if (T && ismob(AM) && !HAS_ATOM_PROPERTY(AM, PROP_ATOM_FLOATING) && !istype(T, /turf/simulated/floor/auto/trench))
			return FALSE

		. = ..()

	Enter(atom/AM)
		var/mob/M = AM
		var/turf/T = get_turf(M)
		if (T && ismob(M) && !HAS_ATOM_PROPERTY(AM, PROP_ATOM_FLOATING) && !istype(T, /turf/simulated/floor/auto/trench))
			if (!M.throwing && isalive(M))
				if (M.client && !M.client.check_key(KEY_RUN) && !M.client.check_key(KEY_BOLT))
					return
				actions.start(new /datum/action/bar/climb_trench(M, src), M)

			else
				src.fall_down_trench(M)

			return

		. = ..()

	Exit(atom/AM, turf/T)
		var/mob/M = AM
		if (T && ismob(M) && !HAS_ATOM_PROPERTY(AM, PROP_ATOM_FLOATING) && !istype(T, /turf/simulated/floor/auto/trench))
			if (!M.throwing && isalive(M))
				if (M.client && !M.client.check_key(KEY_RUN) && !M.client.check_key(KEY_BOLT))
					return
				actions.start(new /datum/action/bar/climb_trench(M, T), M)

			return

		. = ..()

	attackby(obj/item/I, mob/user, params, is_special)
		if (isdiggingtool(I))
			actions.start(new/datum/action/bar/dig_trench(src), user)
			return

		. = ..()

	dig_trench()
		src.ReplaceWith(global.map_settings.space_turf_replacement || src.old_type)
		src.reset_terrainify_effects()

	edge_overlays()
		for (var/turf/T in orange(src, 1))
			if (istype(T, /turf/simulated/floor/auto))
				var/turf/simulated/floor/auto/TA = T
				if (TA.edge_priority_level >= src.edge_priority_level)
					continue
			var/direction = get_dir(T, src)
			var/image/edge_overlay = image('icons/turf/trenches/border_overlays.dmi', "overlay-[direction]")
			edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
			edge_overlay.layer = src.layer + (src.edge_priority_level / 1000)
			edge_overlay.plane = PLANE_FLOOR
			T.UpdateOverlays(edge_overlay, "edge_[direction]")

	proc/update_trench_overlay(update_neighbors = TRUE)
		var/connected_directions = 0
		// Cardinal
		for (var/dir in cardinal)
			var/turf/CT = get_step(src, dir)

			if (istype(CT, /turf/simulated/floor/auto/trench))
				connected_directions |= dir

				if (update_neighbors)
					var/turf/simulated/floor/auto/trench/neighbour = CT
					neighbour.update_trench_overlay(FALSE)

		// Ordinal
		for (var/i = 1 to 4)
			var/ordir = ordinal[i]
			var/turf/OT = get_step(src, ordir)

			if (istype(OT, /turf/simulated/floor/auto/trench) && ((ordir & connected_directions) == ordir))
				connected_directions |= 8 << i

				if (update_neighbors)
					var/turf/simulated/floor/auto/trench/neighbour = OT
					neighbour.update_trench_overlay(FALSE)

		src.icon_state = "trench-[connected_directions]"

	proc/fall_down_trench(mob/M)
		M.set_loc(src)
		M.visible_message(SPAN_ALERT("[M] falls into the trench!"))
		M.TakeDamage("All", 15, 0, 0, DAMAGE_BLUNT)
		M.changeStatus("stunned", 2 SECONDS)

		if (isliving(M) && !M.stat)
			var/mob/living/L = M
			playsound(L.loc, L.sound_scream, 100, 0, 0, L.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)


/turf
	var/can_dig = FALSE
	var/atom/movable/buried_storage/buried_storage

	New()
		. = ..()
		for (var/atom/movable/buried_storage/buried_storage in src.contents)
			src.buried_storage = buried_storage

	proc/dig_trench()
		var/type = src.type
		if (istype(src, /turf/simulated))
			var/turf/simulated/floor/auto/trench/T = src.ReplaceWith(/turf/simulated/floor/auto/trench)
			T.old_type = type
		else if (istype(src, /turf/unsimulated))
			var/turf/unsimulated/floor/auto/trench/T = src.ReplaceWith(/turf/unsimulated/floor/auto/trench)
			T.old_type = type
		src.reset_terrainify_effects()

	proc/reset_terrainify_effects()
		if (src.z != Z_LEVEL_STATION)
			return // only apply station repair effects to station z turfs
		if ((istype(get_area(src), /area/station)))
			return // station areas do not get ambient effects
		if(global.station_repair.ambient_light)
			src.AddOverlays(global.station_repair.ambient_light, "ambient")
		if(global.station_repair.weather_img)
			if(islist(global.station_repair.weather_img))
				src.AddOverlays(pick(global.station_repair.weather_img), "weather")
			else
				src.AddOverlays(global.station_repair.weather_img, "weather")
		if(global.station_repair.weather_effect)
			var/obj/effects/E = locate(global.station_repair.weather_effect) in src
			if(!E)
				new global.station_repair.weather_effect(src)
