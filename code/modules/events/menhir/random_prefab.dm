//reaching farther, farther, for voice, for memory
/datum/random_event/menhir/tractorbeam
	name = "A Hand Outstretched In Yearning"
	description = "Pulls a random yet-to-be-used space prefab onto station Z at one of a few preselected sites. Unavailable once sites are expended."
	message_delay = 5 SECONDS
	weight = 70
	announcement_style = EVENT::MENHIR::NOTIFY::GLOBAL
	centcom_message = "TOREADOR-7I-22408 has begun to project an intense directional electromagnetic field."
	var/list/fxobjects = list()

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (length(src.fxobjects))
				. = FALSE
			if (!landmarks[LANDMARK_MENHIR_BEYOND] || length(landmarks[LANDMARK_MENHIR_BEYOND]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		var/turf/farlandmark = pick(landmarks[LANDMARK_MENHIR_BEYOND])
		if(!farlandmark)
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't find a turf to happen at; this shouldn't happen if event is random. Aborting event.")
			message_admins("Menhir event [src.name] couldn't find a turf to happen at; this shouldn't happen if event is random. Aborting event.")
			return

		var/list/wanted_tags = get_prefab_tags()
		var/datum/mapPrefab/mining/mprefab = pick_map_prefab(/datum/mapPrefab/mining, wanted_tags_any=wanted_tags)
		for(var/i = 1 to 3) //try again a bit if we got a drone, we don't want those picked too often
			if(mprefab.prefabSizeX > 1)
				break
			mprefab = pick_map_prefab(/datum/mapPrefab/mining, wanted_tags_any=wanted_tags)
		if (!mprefab)
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] had no mining-Z prefab to select; event was unable to fully conclude.")
			message_admins("Menhir event [src.name] had no mining-Z prefab to select; event was unable to fully conclude.")
			return

		centcom_message = "TOREADOR-7I-22408 has begun to project an unusually intense electromagnetic field on the "
		centcom_message += landmarks[LANDMARK_MENHIR_BEYOND][farlandmark]
		centcom_message += " axis. Personnel are advised to discontinue any EVA and secure equipment for possible turbulence."

		message_delay = rand(2 SECONDS, 3 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_curious.ogg', EVENT::MENHIR::ALERT_VOLUME)

		landmarks[LANDMARK_MENHIR_BEYOND].Remove(farlandmark)

		logTheThing(LOG_STATION, null, "Menhir event [src.name] at [log_loc(farlandmark)]")
		message_admins("Menhir event [src.name] triggered at [log_loc(farlandmark)]")

		var/turf/focal_nexus = locate(EVENT::MENHIR::CORE_X, EVENT::MENHIR:CORE_Y, Z_LEVEL_STATION)
		new /obj/effects/menhir_tractor_field(focal_nexus,8)
		var/far_fx_scale = ceil(max(mprefab.prefabSizeX,mprefab.prefabSizeY))
		new /obj/effects/menhir_tractor_field(farlandmark,far_fx_scale/3)

		SPAWN(1)
			var/list/coalesce_starts = new/list(12)
			var/list/coalesce_ends = new/list(12)
			for(var/turf/T in landmarks[LANDMARK_MENHIR_COALESCE])
				var/index = landmarks[LANDMARK_MENHIR_COALESCE][T]
				if(index > 12)
					coalesce_ends[index-12] = T
				else
					coalesce_starts[index] = T
			for(var/i in 1 to 20)
				var/chargevolume = 30
				if(i <= 12)
					var/turf/t_start = coalesce_starts[i]
					var/turf/t_end = coalesce_ends[i]
					var/obj/startfx = new /obj/effects(t_start)
					var/obj/endfx = new /obj/effects(t_end)
					src.fxobjects.Add(startfx)
					src.fxobjects.Add(endfx)
					src.fxobjects |= drawLineObj(startfx, endfx, /obj/line_obj/railgun, 'icons/obj/projectiles.dmi',"WholeRailG",1,1,"HalfStartRailG","HalfEndRailG",ABOVE_OBJ_LAYER,1)
					playsound(t_start, 'sound/weapons/energy/howitzer_firing.ogg', 40, 0, pitch = 0.45, extrarange = 24)
				chargevolume = 30 + (i * 3)
				playsound(focal_nexus, 'sound/items/med_scanner.ogg', chargevolume, 0, pitch = 0.5, extrarange = 48)
				sleep(1 SECOND)

			playsound_global(Z_LEVEL_STATION, 'sound/machines/shielddown.ogg', 65, 0)
			SPAWN(2) //approximately syncs sound
				playsound_global(Z_LEVEL_STATION, 'sound/effects/explosionfar.ogg', 65, 0)
				for (var/mob/M in mobs)
					SPAWN(0)
						if (M.z == Z_LEVEL_STATION && !inafterlife(M) && !isVRghost(M))
							shake_camera(M, 6, 6)

			for (var/obj/O in src.fxobjects)
				qdel(O)
			src.fxobjects = list()

			var/x_target_adj = farlandmark.x - floor(mprefab.prefabSizeX / 2)
			var/y_target_adj = farlandmark.y - floor(mprefab.prefabSizeY / 2)

			var/turf/target = locate(x_target_adj, y_target_adj, Z_LEVEL_STATION)
			var/ret = mprefab.applyTo(target)
			if(ret == 0)
				logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't apply prefab (applyTo failure); event was unable to fully conclude.")
				message_admins("Menhir event [src.name] couldn't apply prefab (applyTo failure); event was unable to fully conclude.")
				return

/obj/effects/menhir_tractor_field
	icon = 'icons/effects/96x96.dmi'
	icon_state = "circle"
	color = "#c300ff"
	layer = EFFECTS_LAYER_1
	blend_mode = BLEND_OVERLAY
	alpha = 0
	pixel_x = -32
	pixel_y = -32

	New(var/loc,var/end_scale = 1)
		..()
		animate(src, alpha = 80, time = 20 SECONDS, transform = matrix()*end_scale, easing = SINE_EASING | EASE_OUT)
		SPAWN(21 SECONDS)
			animate(src, alpha = 0, color = "#f5d3ff", time = 1 SECOND, easing = BACK_EASING)
			SPAWN(2 SECONDS)
				qdel(src)
			return

	disposing()
		if(particleMaster.CheckSystemExists(/datum/particleSystem/rads_warning, src))
			particleMaster.RemoveSystem(/datum/particleSystem/rads_warning)
		..()
