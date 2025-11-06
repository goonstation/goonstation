/**
 * Listening post prefab loading, because copy/pasting the changes between every map for every tweak sucks.
 *
 * Rotation maps **should always** have a /obj/landmark/listening_post placed or nuclear operatives will not work and traitors will be big sad.
 *
 * Listening posts based on map names are a convention from when this was created; future posts do not need to follow this pattern. Be creative!
 */

/// The in-round singleton holding the listening post state and relevant procs
/datum/listening_post
	var/unlocked = FALSE
	var/list/unlock_pattern = list(
		/area/listeningpost/vestibule,
		/area/listeningpost/general,
		/area/listeningpost/break_room,
		/area/listeningpost/barracks,
		/area/listeningpost/tech_room,
		/area/listeningpost/power,
		/area/listeningpost/syndicate_teleporter,
	)

/// Log and play the first-time
/datum/listening_post/proc/first_unlock(mob/user)
	if (src.unlocked)
		return
	src.unlocked = TRUE

	logTheThing(LOG_STATION, user, "unlocked the Listening Post at [log_loc(user)].")
	src.unlock()
	src.bootup_sequence(user)

/// Unlock all sleeper sleeper access doors
/datum/listening_post/proc/unlock()
	for (var/obj/machinery/door/airlock/M in by_type[/obj/machinery/door])
		if (M.id == "Sleeper_Access")
			M.req_access = null
			M.req_access_txt = null

/// The bootup sequence sound and light toggling effects
/datum/listening_post/proc/bootup_sequence(mob/user)
	if (istype(user))
		playsound(user.loc, 'sound/machines/shieldgen_startup.ogg', 70, pitch=0.6)
		// make it start with the teleporter if it's nukeops coming in from carnigorm
		if (istype(get_area(user), /area/listeningpost/syndicate_teleporter))
			reverse_list(src.unlock_pattern)

	var/delay = 0

	for (var/post_area_type in src.unlock_pattern)
		var/area/listeningpost/post_area
		for_by_tcl(area_to_check, /area/listeningpost)
			if (istype(area_to_check, post_area_type))
				post_area = area_to_check
				break

		if (!istype(post_area))
			continue

		// lights turn on in sequence with noticable delay; clonk.. clonk.. clonk..
		delay += 1 SECONDS + randfloat(0.4, 0.6) SECONDS
		var/turf/sfx_turf = pick(get_area_turfs(post_area, floors_only=TRUE))
		SPAWN(delay)
			post_area.lightswitch = TRUE
			post_area.power_change() // actually turn lights on
			switched_obj_toggle(SWOB_LIGHTS, post_area.name, TRUE) // handle lightswitch icon updates
			playsound(sfx_turf, 'sound/misc/lightswitch.ogg', 70, pitch=0.2) // chonky switches


/// debugging proc to reset post to locked/shut down state
/datum/listening_post/proc/reset_post()
	for (var/obj/machinery/door/airlock/M in by_type[/obj/machinery/door])
		if (M.id == "Sleeper_Access")
			M.req_access = initial(M.req_access)
			M.req_access_txt = initial(M.req_access_txt)

	for (var/area/listeningpost/post_area in src.unlock_pattern)
		post_area.lightswitch = FALSE
		post_area.power_change()
		switched_obj_toggle(SWOB_LIGHTS, post_area.name, FALSE)

TYPEINFO(/datum/mapPrefab/listening_post)
	stored_as_subtypes = TRUE
/// Map Prefabs for runtime listening post loading
/datum/mapPrefab/listening_post

/datum/mapPrefab/listening_post/standard
	prefabPath = "assets/maps/listening_post/listeningpost_standard.dmm"
/datum/mapPrefab/listening_post/atlas
	prefabPath = "assets/maps/listening_post/listeningpost_atlas.dmm"
/datum/mapPrefab/listening_post/density2
	prefabPath = "assets/maps/listening_post/listeningpost_density2.dmm"
/datum/mapPrefab/listening_post/donut3
	prefabPath = "assets/maps/listening_post/listeningpost_donut3.dmm"
/datum/mapPrefab/listening_post/kondaru
	prefabPath = "assets/maps/listening_post/listeningpost_kondaru.dmm"
/datum/mapPrefab/listening_post/nadir
	prefabPath = "assets/maps/listening_post/listeningpost_nadir.dmm"
/datum/mapPrefab/listening_post/neon
	prefabPath = "assets/maps/listening_post/listeningpost_neon.dmm"
/datum/mapPrefab/listening_post/oshan
	prefabPath = "assets/maps/listening_post/listeningpost_oshan.dmm"
/datum/mapPrefab/listening_post/wrestlemap
	prefabPath = "assets/maps/listening_post/listeningpost_wrestlemap.dmm"


proc/load_listening_post()
	for_by_tcl(landmark, /obj/landmark/listening_post)
		landmark.apply()

/// Landmark for wher to load the listening post
/obj/landmark/listening_post
	icon = 'icons/effects/mapeditor/32x32tiles.dmi'
	icon_state = "listening_post"
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/apply()
		var/datum/mapPrefab/listening_post/listening_post = new map_settings.listening_post_prefab
		listening_post.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "loaded listening post [listening_post.prefabPath]")
		qdel(src)

//
// Listening Post Areas
//

/area/listeningpost
	name = "Listening Post"
	icon_state = "brig"
	teleport_blocked = AREA_TELEPORT_BLOCKED
	do_not_irradiate = TRUE
	lightswitch = FALSE
	minimaps_to_render_on = MAP_SYNDICATE
	station_map_colour = MAPC_SYNDICATE
	occlude_foreground_parallax_layers = TRUE
	expandable = FALSE
	var/unlocks_post = TRUE

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	Entered(atom/movable/A, atom/oldloc)
		. = ..()
		if (!src.unlocks_post)
			return
		if (!ismob(A) || !isliving(A))
			return
		var/datum/listening_post/listening_post = get_singleton(/datum/listening_post)
		if (listening_post.unlocked)
			return
		listening_post.first_unlock(A)

/area/listeningpost/vestibule
	name = "Listening Post Vestibule"
	icon_state = "purple"

/area/listeningpost/general
	name = "Listening Post Lobby"
	icon_state = "red"

/area/listeningpost/barracks
	name = "Listening Post Barracks"
	icon_state = "pink"

/area/listeningpost/break_room
	name = "Listening Post Break Room"
	icon_state = "green"

/area/listeningpost/tech_room
	name = "Listening Post Tech Room"
	icon_state = "orange"

/area/listeningpost/power
	name = "Listening Post Power Room"
	icon_state = "engineering"

/area/listeningpost/solars
	name = "Listening Post Solar Array"
	icon_state = "yellow"
	luminosity = 1
	requires_power = FALSE
	unlocks_post = FALSE

/area/listeningpost/comm_dish
	name = "Listening Post Comms Dish"
	icon_state = "blue"
	luminosity = 1
	requires_power = FALSE
	unlocks_post = FALSE

/area/listeningpost/landing_bay
	name = "Listening Post Landing Bay"
	icon_state = "hangar"
	requires_power = FALSE
	lightswitch = TRUE
	unlocks_post = FALSE

/area/listeningpost/syndicate_teleporter
	name = "Syndicate Teleporter"
	icon_state = "teleporter"
	requires_power = 0

/area/listeningpost/shark_tank
	name = "Listening Post Shark Tank"
	icon_state = "hangar"
	requires_power = FALSE
	unlocks_post = FALSE

/obj/critter/gunbot/drone/gunshark/listening_post
	name = "Trained Syndicate Gun Shark"

	select_target(var/atom/newtarget)
		if(!valid_target(newtarget))
			return
		. = ..(newtarget)

	ai_think()
		if(src.target && !valid_target(src.target))
			src.target = null
			src.last_found = world.time
			src.frustration = 0
			src.task = "thinking"
			walk_to(src,0)
		. = ..()

	proc/valid_target(var/atom/target)
		if(!istype(get_area(target), /area/listeningpost/shark_tank))
			return FALSE
		if(istrainedsyndie(target))
			return FALSE
		return TRUE


