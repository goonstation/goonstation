//Each room must have:
//An area/unspace subtype with name, local facing and seek tag
//The map file itself (with that area applied to at minimum its entryway); map file must also have a CONFIGURED landmark at the end of the viewcone
//A configured room roll (entrance side and map path at minimum)

ABSTRACT_TYPE(/area/unspace)
/area/unspace
	icon_state = "purple"
	filler_turf = "/turf/unsimulated/floor/setpieces/bluefloor"
	sound_environment = 1
	skip_sims = 1
	sound_group = "precursor"
	sound_loop = 'sound/ambience/industrial/Precursor_Drone1.ogg'
	requires_power = FALSE

	sound_environment = 1
	///Do we have an east, or west entrance?
	var/local_facing = WEST
	///This tag should match the path of the prefab in allocated.dm, lowercase with underscores, and have a matching tagged landmark within the prefab.
	var/seek_tag = "fix"

	proc/update_visual_mirrors(turf/otherside_ref)
		if(ON_COOLDOWN(src, "update_vismirrors", 3 SECONDS)) return
		//Find our landmark
		var/obj/anchor = locate(seek_tag)
		if(!anchor)
			return
		var/anchor_x = anchor.x
		var/anchor_y = anchor.y
		var/anchor_z = anchor.z

		var/turf/T
		var/turf/otherside_turf

		//---- Projection within our "pocket" ----

		//Horizontal iteration goes up if we're east facing, and down if we're west facing
		var/dirsign = 1
		if(local_facing == WEST) dirsign = -1

		var/oriented_horz
		var/clamped_horz
		var/maxvert
		var/v_offset

		for (var/horz = -1 to 10)
			oriented_horz = horz * dirsign
			clamped_horz = max(horz, 0)
			maxvert = min((2 * clamped_horz), 15) //Follow the contour of the cone
			v_offset = min(clamped_horz, 7) //Bump the start lower according to contour
			for (var/vert = 0 to maxvert)
				T = locate(anchor_x + (oriented_horz), anchor_y + (vert - v_offset), anchor_z)
				otherside_turf = locate(otherside_ref.x + (oriented_horz), otherside_ref.y + (vert - v_offset), otherside_ref.z)

				T.vis_contents = null// clear previously assigned vis_contents
				if (otherside_turf)
					otherside_turf.appearance_flags |= KEEP_TOGETHER
					if (!otherside_turf.listening_turfs)
						otherside_turf.listening_turfs = list()
					otherside_turf.listening_turfs += T

					T.vis_contents += otherside_turf
					T.density = otherside_turf.density
					T.opacity = otherside_turf.opacity
					for (var/atom/A as anything in otherside_turf)
						if (A.opacity)
							T.opacity = TRUE
							break
					T.name = otherside_turf.name
					T.desc = otherside_turf.desc
					T.icon = otherside_turf.icon
					T.icon_state = otherside_turf.icon_state
					T.dir = otherside_turf.dir
				else // past edge of map
					T.icon = null
					T.icon_state = null
					T.density = TRUE
					T.opacity = TRUE
					T.name = ""
					T.desc = ""
				//T.RL_Init()

		//---- Projection from our pocket back into regular space (only tie traversible tiles) ----
		dirsign = -dirsign

		for (var/horz = 2 to 5)
			oriented_horz = horz * dirsign

			if(horz > 3)
				maxvert = 2
				v_offset = 1
			else
				maxvert = 0
				v_offset = 0

			for (var/vert = 0 to maxvert)
				otherside_turf = locate(anchor_x + (oriented_horz), anchor_y + (vert - v_offset), anchor_z)
				T = locate(otherside_ref.x + (oriented_horz), otherside_ref.y + (vert - v_offset), otherside_ref.z)

				T.vis_contents = null// clear previously assigned vis_contents
				if (otherside_turf)
					otherside_turf.appearance_flags |= KEEP_TOGETHER
					if (!otherside_turf.listening_turfs)
						otherside_turf.listening_turfs = list()
					otherside_turf.listening_turfs += T

					T.vis_contents += otherside_turf
					T.density = otherside_turf.density
					T.opacity = otherside_turf.opacity
					for (var/atom/A as anything in otherside_turf)
						if (A.opacity)
							T.opacity = TRUE
							break
					T.name = otherside_turf.name
					T.desc = otherside_turf.desc
					T.icon = otherside_turf.icon
					T.icon_state = otherside_turf.icon_state
					T.dir = otherside_turf.dir
				//T.RL_Init()

/area/unspace/medical
	name = "Soothing Chamber"
	local_facing = WEST
	seek_tag = "menhir_room_medical"

/area/unspace/lounge
	name = "Secluded Alcove"
	local_facing = EAST
	seek_tag = "menhir_room_lounge"

/area/unspace/botany
	name = "Damp Antechamber"
	local_facing = EAST
	seek_tag = "menhir_room_botany"

/area/unspace/poolroom
	name = "Misty Cavern"
	local_facing = WEST
	seek_tag = "menhir_room_cavern"
	sound_environment = 10

	reservoir
		icon_state = "blue"
		sound_loop = null

/area/unspace/bball
	name = "Reverberating Arena"
	local_facing = WEST
	seek_tag = "menhir_room_bball"

/area/unspace/sepulchre
	name = "Unworldly Halls"
	local_facing = EAST
	seek_tag = "menhir_room_sepulchre"

ABSTRACT_TYPE(/obj/menhir_room_objs)
/obj/menhir_room_objs
	name = ""
	desc = ""
	anchored = ANCHORED_ALWAYS
	invisibility = INVIS_ALWAYS

	ex_act()
		return

ABSTRACT_TYPE(/obj/menhir_room_objs/cross_dummy)
/obj/menhir_room_objs/cross_dummy
	invisibility = INVIS_ALWAYS
	var/turf/exit_turf
	var/required_dir

	New(newLoc, turf/exit)
		..()
		src.exit_turf = exit

	disposing()
		src.exit_turf = null
		..()

	Crossed(atom/movable/AM)
		if (istype(AM, /obj/projectile))
			var/obj/projectile/P = AM
			var/obj/projectile/new_proj = initialize_projectile(src.exit_turf, P.proj_data, P.xo, P.yo, P.shooter)
			new_proj.travelled = P.travelled
			new_proj.launch()
			P.die()
		else if (AM.dir == src.required_dir && !istype(AM, /obj/menhir_room_objs/cross_dummy))
			// makes it look like an animation glide
			AM.set_loc(get_step(src.exit_turf, turn(AM.dir, 180)))
			SPAWN(0.001) // just a really low value
				AM.set_loc(src.exit_turf)
				if (istype(AM, /obj/stool)) // i dont like this but buckled is weird as shit
					var/obj/stool/stool = AM
					if (stool.buckled_guy)
						stool.buckled_guy.set_loc(src.exit_turf)
		else
			return ..()

	east
		required_dir = EAST

	west
		required_dir = WEST

/obj/menhir_room_objs/mirror_update_dummy
	invisibility = INVIS_ALWAYS
	var/area/unspace/update_area = null
	var/turf/otherside_ref

	New(newLoc, area/updatearea, turf/othersideref)
		..()
		src.update_area = updatearea
		src.otherside_ref = othersideref

	disposing()
		src.update_area = null
		src.otherside_ref = null
		..()

	Crossed(atom/movable/AM)
		if (isliving(AM) && !isintangible(AM))
			if(src.update_area) src.update_area.update_visual_mirrors(src.otherside_ref)
			return ..()
		return ..()

/obj/menhir_room_objs/hidey_helper
	name = "hidey helper"
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "access_spawn"
	var/zone = null

	New()
		..()
		var/area/our_region = get_area(src)
		src.zone = our_region.name
		START_TRACKING
		SPAWN(5)
			for (var/obj/O in src.loc)
				if(safe_to_grab(O))
					O.set_loc(src)

	proc/safe_to_grab(var/obj/O)
		. = TRUE
		if (!isobj(O) || O.invisibility == INVIS_ALWAYS || istype(O,/obj/overlay))
			. = FALSE

	proc/deposit_contents()
		var/newloc = src.loc
		showswirl(newloc)
		for (var/obj/O in src)
			O.set_loc(newloc)
		SPAWN(0)
			qdel(src)

	disposing()
		STOP_TRACKING
		..()

/obj/menhir_room_objs/hidey_helper_trigger
	name = "hidey helper trigger"
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	var/working = FALSE

	Crossed(atom/movable/AM)
		if (!src.working && ismob(AM))
			src.working = TRUE
			SPAWN(0)
				src.begin_unhiding()
			return ..()
		return ..()

	proc/begin_unhiding()
		var/area/our_area = get_area(src)
		var/local_zone = our_area.name
		for_by_tcl(hidey_helper,/obj/menhir_room_objs/hidey_helper)
			if(hidey_helper.zone == local_zone)
				hidey_helper.deposit_contents()
				sleep(1)
		qdel(src)

#ifdef MAP_OVERRIDE_MENHIR

///General helper: evaluate the tag of a node to see which public exits it can make available for event
/proc/nodetagcheck(var/tag_to_check)
	. = 0
	if(tag_to_check == "WEST" || tag_to_check == "NORTHEAST" || tag_to_check == "SOUTHEAST")
		. = WEST
	if(tag_to_check == "EAST" || tag_to_check == "NORTHWEST" || tag_to_check == "SOUTHWEST")
		. = EAST
	return

ABSTRACT_TYPE(/datum/menhir_room_roll)
///Dataset for a particular room that can be summoned; provides path to prefab as well as context data
/datum/menhir_room_roll
	var/name = "cat gym"
	/// Which side the room is entered from; this may be EAST or WEST.
	/// * WEST entrance is allowed at west, northeast and southeast nodes.
	/// * EAST entrance is allowed at east, northwest and southwest nodes.
	var/entrance_side = EAST

	///Path to prefab we load in.
	var/map_path = null
	///Base weight of prefab.
	var/base_weight = 100
	///Areas to check for occupancy in the process of room selection (optional). Assigned value is weight added per person in that type of area.
	var/list/area_busy_checks = null
	///Some of the rooms that match more conventional functions maaaaaaay have had their contents appropriated from somewhere that misses it
	var/list/stole_from = null

	///If you want a room to always show up when a particular condition is met, set this to TRUE and override special_eval()
	var/has_special_condition = FALSE
	///Child proc should call this first (passing a FALSE result back immediately) then define its own success condition to return TRUE for.
	proc/special_eval(var/direction_eligibility)
		. = FALSE
		if(direction_eligibility & src.entrance_side)
			. = TRUE

	proc/get_weight()
		. = src.base_weight
		if(area_busy_checks)
			for (var/mob/living/carbon/human/H in mobs)
				for(var/A in area_busy_checks)
					if(istype(get_area(H),A))
						. += area_busy_checks[A]
		return

/datum/menhir_room_roll/medbay
	name = "soothing chamber (medical)"
	entrance_side = WEST
	map_path = /datum/mapPrefab/allocated/menhir_room_medical
	base_weight = 50
	area_busy_checks = list(/area/station/medical/medbay = 12,\
		/area/station/medical = 2,\
		/area/station/security = 1,\
		/area/station/crown = 2)
	stole_from = list("medical bay","medbay","med wing")

/datum/menhir_room_roll/lounge
	name = "secluded alcove (lounge)"
	entrance_side = EAST
	map_path = /datum/mapPrefab/allocated/menhir_room_lounge
	base_weight = 80
	area_busy_checks = list(/area/station/crew_quarters = 5,\
		/area/station/hallway/secondary = 2)
	stole_from = list("rec room","cafeteria","bar")

/datum/menhir_room_roll/botany
	name = "damp antechamber (botany)"
	entrance_side = EAST
	map_path = /datum/mapPrefab/allocated/menhir_room_botany
	base_weight = 80
	area_busy_checks = list(/area/station/hydroponics = 6,\
		/area/station/ranch = 3,\
		/area/station/crew_quarters/cafeteria = 1)
	stole_from = list("hydroponics","botany","ag bay")

/datum/menhir_room_roll/poolroom
	name = "misty cavern (pool)"
	entrance_side = WEST
	map_path = /datum/mapPrefab/allocated/menhir_room_cavern
	has_special_condition = TRUE

	special_eval(direction_eligibility)
		. = ..()
		if (. == FALSE) return
		. = FALSE
		var/obj/plinth = locate("menhir_plinth")
		if(plinth)
			for (var/obj/O in get_turf(plinth))
				if(istype(O,/obj/item/beach_ball))
					playsound(plinth.loc, 'sound/musical_instruments/artifact/Artifact_Precursor_4.ogg', 55, 0)
					. = TRUE
					return

/datum/menhir_room_roll/bball
	name = "reverberating arena (bball)"
	entrance_side = WEST
	base_weight = 5
	map_path = /datum/mapPrefab/allocated/menhir_room_bball
	has_special_condition = TRUE
	area_busy_checks = list(/area/station/crew_quarters/fitness = 1)

	special_eval(direction_eligibility)
		. = ..()
		if (. == FALSE) return
		. = FALSE
		var/obj/plinth = locate("menhir_plinth")
		if(plinth)
			for (var/obj/O in get_turf(plinth))
				if(istype(O,/obj/item/basketball))
					playsound(plinth.loc, 'sound/musical_instruments/artifact/Artifact_Precursor_4.ogg', 55, 0)
					. = TRUE
					return

/datum/menhir_room_roll/sepulchure
	name = "unworldly halls (sepulchre)"
	entrance_side = EAST
	base_weight = 0
	map_path = /datum/mapPrefab/allocated/menhir_room_sepulchre
	has_special_condition = TRUE

	special_eval(direction_eligibility)
		. = ..()
		if (. == FALSE) return
		. = FALSE
		var/obj/plinth = locate("menhir_plinth")
		if(plinth)
			for (var/obj/O in get_turf(plinth))
				if(istype(O,/obj/item/chilly_orb))
					playsound(plinth.loc, 'sound/musical_instruments/artifact/Artifact_Precursor_4.ogg', 55, 0)
					. = TRUE
					return

/datum/random_event/menhir/room
	name = "The Crown Holds Court"
	message_delay = 1 MINUTE
	weight = 20
	customization_available = 1
	///Consumable pool of room data.
	var/list/room_pool = list()
	///Keep track of rooms we've created.
	var/list/rooms_made = list()

	New()
		for (var/R in concrete_typesof(/datum/menhir_room_roll))
			var/datum/room = new R
			src.room_pool += room
		. = ..()

	///Menhir room event scales its rate of appearance based on server population
	/// * 170 weight (semi-common) at 30 pop, 300 weight (matching the most-common emissary event) at 56 pop
	proc/update_weight()
		src.weight = 20 + (total_clients() * 5)

	admin_call(var/source)
		if (..())
			return

		var/node2use = null
		if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) return //if no nodes remain whatsoever, don't trigger event

		var/list/nodenames = list()
		for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
			nodenames += landmarks[LANDMARK_MENHIR_NODE][T]

		var/noderequest = input(usr,"Which node to spawn at?",src.name) as null|anything in nodenames
		if(!noderequest) return

		for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
			if (landmarks[LANDMARK_MENHIR_NODE][T] == noderequest)
				node2use = T
				break

		var/room2use = null
		room2use = input(usr,"What room would you like to spawn?",src.name) as null|anything in src.room_pool

		src.event_effect(source, node2use, room2use)
		return

	is_event_available(var/ignore_time_lock, var/natural_event = TRUE)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no nodes remain whatsoever, don't trigger event
				. = FALSE
			if (natural_event) //do we have a valid outcome? skip this for triggers through special_eval, which are taking care of this on their own
				var/direction_eligibility = 0
				for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
					var/result = nodetagcheck(landmarks[LANDMARK_MENHIR_NODE][T])
					if(result) direction_eligibility |= result
				var/available_gens = FALSE
				for (var/datum/menhir_room_roll/RR in src.room_pool)
					if (RR.base_weight > 0 && direction_eligibility & RR.entrance_side)
						available_gens = TRUE
						break
				if (!available_gens)
					. = FALSE

	event_effect(source, node_override, room_override)
		///Node the room will spawn into
		var/turf/nodelandmark
		///Tag for the node the event is occurring in, when a node is selected
		var/node_tag = null
		///Datum that lets us know which room we're going to be spawning
		var/datum/menhir_room_roll/room_data = null

		///Records available directions from unused nodes, to determine which are available for spawns
		var/direction_eligibility = 0

		if (node_override)
			nodelandmark = node_override
			node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]
		else
			for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
				var/result = nodetagcheck(landmarks[LANDMARK_MENHIR_NODE][T])
				if(result) direction_eligibility |= result

			if (!direction_eligibility)
				logTheThing(LOG_DEBUG, null, "Menhir room event couldn't collect node directional information; aborting event.")
				message_admins("Menhir room event couldn't collect node directional information; aborting event.")

		if(room_override)
			room_data = room_override
		else
			///Our list of rooms may not always have spawnables that work for current directions
			var/list/currently_spawnable_rooms = list()

			for(var/datum/menhir_room_roll/RR in src.room_pool)
				if(RR.has_special_condition && RR.special_eval(direction_eligibility))
					room_data = RR
					break
				if(direction_eligibility & RR.entrance_side) //deliberately not elseif'd.
					var/weightdata = RR.get_weight()
					if(weightdata > 0) currently_spawnable_rooms[RR] = weightdata

			if(!room_data) room_data = weighted_pick(currently_spawnable_rooms)

			if(!nodelandmark)
				var/list/eligible_nodes = list()
				for (var/turf/T in landmarks[LANDMARK_MENHIR_NODE])
					var/result = nodetagcheck(landmarks[LANDMARK_MENHIR_NODE][T])
					if(result & room_data.entrance_side) eligible_nodes += T

				nodelandmark = pick(eligible_nodes)
			node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

		if (!room_data.map_path)
			logTheThing(LOG_DEBUG, null, "Menhir room '[room_data.name]' has invalid map_path configuration.")
			message_admins("Menhir room '[room_data.name]' has invalid map_path configuration.")
			return

		var/datum/mapPrefab/allocated/room_handler = get_singleton(room_data.map_path)

		var/datum/allocated_region/spawned_room = room_handler.load()
		src.rooms_made += spawned_room
		src.initialize_entrance(room_data.entrance_side, nodelandmark, spawned_room)
		src.room_pool -= room_data
		if(room_data.has_special_condition) random_events.menhir_special_rooms -= room_data

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		src.localize_reading(nodelandmark)

		message_delay = rand(20 SECONDS, 50 SECONDS)
		..()

		if(room_data.stole_from && prob(60)) //if prob is 100 this is debug
			SPAWN(message_delay + rand(2 MINUTES, 3 MINUTES))
				var/who = generate_random_station_name(TRUE)
				command_alert(get_admonishment(room_data.stole_from), alert_origin = "Communication from [who]")
				playsound_global(world, 'sound/misc/announcement_1.ogg', 60)

		logTheThing(LOG_STATION, null, "Menhir room '[room_data.name]' entrance created at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir room '[room_data.name]' entrance created at [node_tag] arm - [log_loc(nodelandmark)]")

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again

	proc/initialize_entrance(entrance_side, turf/nodelandmark, datum/allocated_region/pocket_region)
		var/region_tag = pocket_region.name
		var/turf/pocket_landmark = get_turf(locate(region_tag)) //Same position as the door

		var/otherway
		switch(entrance_side)
			if(EAST)
				otherway = WEST
			if(WEST)
				otherway = EAST

		var/turf/pocket_doormat = get_step(pocket_landmark,otherway)
		var/turf/pocket_midpoint = get_step(pocket_doormat,otherway) //Inside-to-outside cross dummy starts here
		var/turf/pocket_inside = get_step(pocket_midpoint,otherway) //Outside-to-inside cross dummy exits here

		var/turf/real_midpoint = get_step(nodelandmark,entrance_side) //Outside-to-inside cross dummy starts here
		var/turf/real_doormat = get_step(real_midpoint,entrance_side) //Inside-to-outside cross dummy exits here
		var/turf/door_here = get_step(real_doormat,entrance_side) //Inside-to-outside cross dummy exits here

		var/turf/pocket_juncture = get_step(pocket_inside,otherway) //The "junction point" inside room prefabs
		var/turf/real_juncture = get_step(nodelandmark, otherway) //Real space corresponding to the "junction point" inside room prefabs
		var/list/where_to_wall

		var/obj/menhir_room_objs/cross_dummy/inside_dummy

		switch (entrance_side)
			if (EAST)
				new /obj/menhir_room_objs/cross_dummy/west(real_midpoint, pocket_midpoint) //Moving west into the space
				inside_dummy = new /obj/menhir_room_objs/cross_dummy/east(pocket_doormat, real_doormat) //Moving east out of the space
				where_to_wall = list(NORTHWEST,WEST,SOUTHWEST)

			if (WEST)
				new /obj/menhir_room_objs/cross_dummy/east(real_midpoint, pocket_midpoint) //Moving east into the space
				inside_dummy = new /obj/menhir_room_objs/cross_dummy/west(pocket_doormat, real_doormat) //Moving west out of the space
				where_to_wall = list(NORTHEAST,EAST,SOUTHEAST)

		new /obj/menhir_room_objs/mirror_update_dummy(get_step(pocket_inside,otherway), get_area(inside_dummy), door_here)
		new /obj/menhir_room_objs/mirror_update_dummy(real_doormat, get_area(inside_dummy), door_here)

		real_midpoint.reachable_turfs += pocket_inside
		pocket_midpoint.reachable_turfs += real_doormat

		var/obj/machinery/door/unpowered/blue/doorbius = new /obj/machinery/door/unpowered/blue/vertical(door_here)
		doorbius.locks_on_open = TRUE

		//detect any additional walls we may have in the prefab
		var/turf/nturf = get_step(pocket_juncture,NORTH)
		var/turf/sturf = get_step(pocket_juncture,SOUTH)
		if(nturf.density) where_to_wall += NORTH
		if(sturf.density) where_to_wall += SOUTH

		for(var/dir in alldirs)
			if(dir == EAST || dir == WEST)
				continue
			var/turf/to_replace = get_step(real_midpoint,dir)
			to_replace.ReplaceWith(/turf/unsimulated/wall/auto/adventure/icemooninterior,force=TRUE)

		for(var/dir in where_to_wall)
			var/turf/to_replace = get_step(real_juncture,dir)
			to_replace.ReplaceWith(/turf/unsimulated/wall/auto/adventure/icemooninterior,force=TRUE)

		SPAWN(20)
			var/area/unspace/our_space = get_area(inside_dummy)
			our_space.update_visual_mirrors(door_here)
			RL_UPDATE_LIGHT(real_doormat)

	proc/get_admonishment(where_stolen)
		var/possible_responses = list("To all Nanotrasen assets in region, please be advised, an unknown threat - likely salvagers - is on the move. Our [pick(where_stolen)] was remotely ransacked before we realized what was happening - teleport block is advised.",\
			"Broadcasting for [station_name(0)]. I don't know what the fuck you guys are up to but our [pick(where_stolen)] just had half its shit vanish and our sensor logs are pointing straight at you. Cut it out.",\
			"Facility captain to [station_name(0)], we've just had an anomalous event of some kind and our [pick(where_stolen)] has abruptly lost most of its contents. Advise going to a high alert status until we hear back from NT.",\
			"[station_name(0)], your artifact's acting up. We just lost a lot of hardware from our [pick(where_stolen)] and the eggheads are about 90% sure Toreador whatever is at fault. PLEASE return the equipment at your earliest convenience, if that thing even lets you.",\
			"Anyone who's hearing this, lock your [pick(where_stolen)] down. Somebody just yoinked our shit in the last five minutes without so much as a sound.",\
			"OUR [uppertext(pick(where_stolen))] IS FUCKING GONE"
		)
		. = pick(possible_responses)

#endif
