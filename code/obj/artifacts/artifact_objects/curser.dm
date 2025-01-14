// strings here correlate with the id of the status effects they're tied to
#define BLOOD_CURSE "art_blood_curse"
#define AGING_CURSE "art_aging_curse"
#define NIGHTMARE_CURSE "art_nightmare_curse"
#define MAZE_CURSE "art_maze_curse"
#define DISP_CURSE "art_displacement_curse"
#define LIGHT_CURSE "art_light_curse"

/obj/artifact/curser
	name = "artifact curser"
	associated_datum = /datum/artifact/curser

/datum/artifact/curser
	associated_object = /obj/artifact/curser
	type_name = "Curser"
	rarity_weight = 250
	validtypes = list("eldritch")
	// activation text disguises it as container, but it is covered in suspicious markings which gives it away
	activ_text = "seems like it has something inside of it..."
	deact_text = "locks back up."
	react_xray = list(2, 20, 55, 7, "HOLLOW")
	examine_hint = "It is covered in very conspicuous markings."
	shard_reward = ARTIFACT_SHARD_SPACETIME
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE
	// general vars
	var/chosen_curse
	var/list/active_cursees = list()
	var/static/list/durations = \
		list(BLOOD_CURSE = null, AGING_CURSE = null, NIGHTMARE_CURSE = null, MAZE_CURSE = null, DISP_CURSE = 2 MINUTES, LIGHT_CURSE = 3 MINUTES)
	// blood curse vars
	var/blood_curse_active = FALSE
	// aging curse vars
	var/aging_curse_active = FALSE
	var/list/participants = list()
	// maze curse vars
	var/datum/allocated_region/maze

	// displacement curse vars
	var/disp_curse_active = FALSE

	New()
		..()
		src.chosen_curse = pick(BLOOD_CURSE, AGING_CURSE, NIGHTMARE_CURSE, MAZE_CURSE, DISP_CURSE, LIGHT_CURSE)

	effect_touch(obj/O, mob/living/user)
		. = ..()
		if (.)
			return TRUE
		if (!ishuman(user) || !user.client)
			return
		if (src.active_curse_check(O, user))
			return

		if (length(src.active_cursees) || ON_COOLDOWN(O, "art_curse_activated", rand(180, 300) SECONDS))
			boutput(user, SPAN_NOTICE("[O] seems dormant. You're sure you can feel some presence inside though... creepy."))
			return

		src.active_cursees = list()

		var/list/curse_candidates = list()
		var/list/picked_to_curse = list()

		logTheThing(LOG_STATION, O, "Curser artifact with effect [src.chosen_curse] activated at [log_loc(O)] by [key_name(user)]")

		for (var/mob/living/carbon/human/H in range(5, O))
			if (H != user && !isdead(H))
				curse_candidates += H

		for (var/i = 1 to min(length(curse_candidates), rand(2, 5)))
			var/candidate = pick(curse_candidates)
			picked_to_curse += candidate
			curse_candidates -= candidate
			logTheThing(LOG_STATION, O, "Curser artifact activated by [key_name(user)] area of effect cursed [key_name(candidate)] at [log_loc(candidate)]")

		O.visible_message(SPAN_ALERT("<b>[O]</b> screeches, releasing the curse that was locked inside it!"))
		playsound(O, pick('sound/effects/ghost.ogg', 'sound/effects/ghostlaugh.ogg'), 60, TRUE)

		for (var/mob/living/carbon/human/H as anything in (picked_to_curse + list(user)))
			if (!H.last_ckey)
				continue
			if (H.hasStatus("art_talisman_held"))
				if (src.chosen_curse != BLOOD_CURSE && src.chosen_curse != AGING_CURSE)
					boutput(user, SPAN_ALERT("The artifact you're carrying wards you from a curse!"))
					for (var/datum/statusEffect/talisman_held/talisman_effect in H.statusEffects)
						talisman_effect.glimmer.activate_glimmer()
				else
					boutput(user, SPAN_ALERT("The artifact you're carrying wards you from a curse, but then suddenly detonates!"))
					for (var/datum/statusEffect/talisman_held/talisman_effect in H.statusEffects)
						explosion(talisman_effect.art, get_turf(H), -1, -1, 2)
						qdel(talisman_effect.art)
						break
				continue
			var/datum/statusEffect/active_curse = H.setStatus(src.chosen_curse, src.durations[src.chosen_curse], src)
			src.active_cursees[H] = active_curse
			if (src.chosen_curse == BLOOD_CURSE)
				src.blood_curse_active = TRUE
			else if (src.chosen_curse == AGING_CURSE)
				src.aging_curse_active = TRUE
			else if (src.chosen_curse == MAZE_CURSE)
				src.create_maze()
				O.visible_message(SPAN_ALERT("[H] suddenly disappears!"))
			else if (src.chosen_curse == DISP_CURSE)
				src.disp_curse_active = TRUE

			var/obj/decal/art_curser_sigil/sigil = new(get_turf(H))
			animate(sigil, alpha = 0, time = 2 SECONDS)
			SPAWN(2 SECONDS)
				qdel(sigil)

		if (src.chosen_curse == MAZE_CURSE)
			playsound(O, 'sound/effects/bamf.ogg', 50, TRUE)

	proc/active_curse_check(obj/O, mob/living/carbon/human/user)
		if (src.blood_curse_active)
			if (user.client && tgui_alert(user, "Donate 100u of your blood?", "Blood Curse Appeasement", list("Yes", "No")) == "Yes")
				user.blood_volume -= 100
				boutput(user, SPAN_ALERT("You place your hand on the artifact, and it draws blood from you. Ouch..."))
				playsound(user, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, TRUE)
				for (var/mob/living/carbon/human/H in src.active_cursees)
					for (var/datum/statusEffect/art_curse/blood/curse in H.statusEffects)
						if (curse == src.active_cursees[H])
							curse.blood_to_collect -= 100
							break
				return TRUE
		else if (src.aging_curse_active)
			var/mob/living/carbon/human/H = user
			if (!H.last_ckey)
				return

			var/youngest_age = INFINITY
			for (var/mob/living/carbon/human/cursed in src.active_cursees)
				youngest_age = min(youngest_age, cursed.bioHolder.age)

			if (H.bioHolder.age >= youngest_age || (H.ckey in src.participants))
				boutput(user, "<b>[O]</b> doesn't respond.")
				return TRUE
			boutput(user, "Your knuckles hurt kinda")
			src.participants.Add(H.ckey)
			if (length(src.participants) >= 3)
				src.lift_curse(TRUE)
				src.participants = list()
			else
				O.visible_message(SPAN_NOTICE("<b>[O]</b> softly stirs."))
			return TRUE
		else if (src.disp_curse_active)
			src.lift_curse(TRUE)
			return TRUE

	proc/lift_curse(do_playsound)
		for (var/mob/L as anything in src.active_cursees)
			L.delStatus(src.chosen_curse)
			if (do_playsound)
				playsound(src.holder, 'sound/effects/lit.ogg', 100, TRUE)
		src.active_cursees = list()
		src.blood_curse_active = FALSE
		src.aging_curse_active = FALSE
		src.disp_curse_active = FALSE
		if (src.maze)
			QDEL_NULL(src.maze)

	proc/lift_curse_specific(do_playsound, mob/living/L)
		if ((L in src.active_cursees) && length(src.active_cursees) == 1)
			src.lift_curse(do_playsound)
			return
		if (do_playsound)
			L.playsound_local(src.holder, 'sound/effects/lit.ogg', 100, TRUE)
		if (L in src.active_cursees)
			L.delStatus(src.active_cursees[L])
		src.active_cursees -= L

	// maze width is only defined in this proc, if changed, care needs to be taken for other values used
	// also note, loaded rooms (x1, y1) location is at the bottom left of the room, not the middle
	// TODO: replacing the maze generation with something other than BSP would be good in the future (seems to generate a lot of binary split dead ends which is a little boring)
	proc/create_maze()
		var/maze_width = 40
		src.maze = global.region_allocator.allocate(maze_width, maze_width)
		src.maze.clean_up()

		var/datum/cell_grid/maze_grid = new(maze_width, maze_width)
		maze_grid.generate_maze(1, 1, maze_width, maze_width, "F")

		var/turf/T
		var/list/floor_turfs = list()
		for (var/x in 1 to maze_width)
			for (var/y in 1 to maze_width)
				T = src.maze.turf_at(x, y)
				if (maze_grid.grid[x][y] == "F")
					T.ReplaceWith(/turf/unsimulated/floor/ancient)
					floor_turfs += T
				else
					T.ReplaceWith(/turf/unsimulated/wall/auto/adventure/ancient)

		// set up area vars of the maze
		T = src.maze.get_center()
		var/area/A = get_area(T)
		A.name = "unknown pocket dimension"
		A.teleport_blocked = 2
		A.allowed_restricted_z = TRUE

		logTheThing(LOG_STATION, src.holder, "Maze created for Curser artifact [src.holder] with center point [log_loc(T)]")

		// load start room center
		T = src.maze.turf_at(rand(2, maze_width - 8), rand(2, maze_width - 8)) // values in respect to maze room perimeters + maze perimeter

		// starting room
		var/x1 = rand(2, maze_width - 8)
		var/y1 = rand(2, maze_width - 8)
		// key room
		var/x2
		var/y2
		// escape room
		var/x3
		var/y3
		for (var/i = 1 to 50) // arbitrarily high number
			x2 = rand(2, maze_width - 8)
			y2 = rand(2, maze_width - 8)
			if (GET_DIST(src.maze.turf_at(x2, y2), src.maze.turf_at(x1, y1)) > 7)
				break
			x2 = null
			y2 = null
		if (!x2)
			logTheThing(LOG_DEBUG, src.holder, "Error creating maze Key Room for Curser artifact [src.holder]")
			CRASH("Error in Curser art maze generation, could not create Key Room.")
		for (var/i = 1 to 50)
			x3 = rand(2, maze_width - 8)
			y3 = rand(2, maze_width - 8)
			if (GET_DIST(src.maze.turf_at(x3, y3), src.maze.turf_at(x1, y1)) > 7 && GET_DIST(src.maze.turf_at(x3, y3), src.maze.turf_at(x2, y2)) > 7)
				break
			x3 = null
			y3 = null
		if (!x3)
			logTheThing(LOG_DEBUG, src.holder, "Error creating maze Escape Room for Curser artifact [src.holder]")
			CRASH("Error in Curser art maze generation, could not create Escape Room.")
		var/turf/start = src.maze.turf_at(x1, y1)
		var/turf/key = src.maze.turf_at(x2, y2)
		var/turf/escape = src.maze.turf_at(x3, y3)
		var/dmm_suite/room_loader = new
		room_loader.read_map(file2text("assets/maps/allocated/artifact_labyrinth_startroom.dmm"), start.x, start.y, start.z)
		room_loader.read_map(file2text("assets/maps/allocated/artifact_labyrinth_keyroom.dmm"), key.x, key.y, key.z)
		room_loader.read_map(file2text("assets/maps/allocated/artifact_labyrinth_escaperoom.dmm"), escape.x, escape.y, escape.z)

		for (var/i = 1 to 15)
			T = pick(floor_turfs)
			if (!istype(T, /turf/unsimulated/floor/ancient))
				continue
			new /obj/decal/cleanable/cobwebFloor(T)

		T = locate(start.x + 3, start.y + 3, start.z)

		for (var/mob/living/L in src.active_cursees)
			L.set_loc(T)
			new /obj/item/art_labyrinth_flashlight(T)


#undef BLOOD_CURSE
#undef AGING_CURSE
#undef NIGHTMARE_CURSE
#undef MAZE_CURSE
#undef DISP_CURSE
#undef LIGHT_CURSE

/*********** MAZE STUFF *************/

/obj/item/art_labyrinth_flashlight
	name = "\improper mysterious claw"
	desc = "A scary looking Eldritch artifact. At least it emits light? Seems it has some sort of activatable mechanism too."
	icon = 'icons/obj/artifacts/art_labyrinth.dmi'
	icon_state = "flashlight"
	help_message = "Activate in-hand to create or destroy a marking sigil, on Void turf."

	var/datum/component/loctargeting/medium_directional_light/light_dir
	New()
		..()
		var/col = rgb2num("#f8d7ff")
		light_dir = src.AddComponent(/datum/component/loctargeting/medium_directional_light, col[1], col[2], col[3], 230)
		light_dir.update(TRUE)

	attack_self(mob/user)
		..()
		var/turf/T = get_turf(user)
		var/sigil_decal = locate(/obj/decal/art_curser_sigil/labyrinth) in T
		if (sigil_decal)
			qdel(sigil_decal)
		else if (istype(T, /turf/unsimulated/floor/ancient))
			new /obj/decal/art_curser_sigil/labyrinth(get_turf(user))

/obj/decal/art_curser_sigil
	name = "\improper strange sigil"
	desc = "Some strange symbol."
	icon = 'icons/obj/artifacts/art_labyrinth.dmi'
	icon_state = "maze_sigil"

	New()
		..()
		var/list/col = rgb2num("#774777")
		src.add_simple_light("sigil_glow", col + list(200))

	disposing()
		src.remove_simple_light("sigil_glow")
		..()

	labyrinth
		desc = "Some strange symbol. Probably related to the curse"

/obj/item/art_labyrinth_firekey
	name = "\improper fire key"
	desc = "A key that looks like fire, or fire in the shape of a key? You're not sure, but it doesn't seem hot."
	icon = 'icons/obj/artifacts/art_labyrinth.dmi'
	icon_state = "fire_key"

/obj/art_labyrinth_escapedoor
	name = "Presumably The Escape"
	desc = "A door in open space in a labyrinth... this seems like the escape. It appears to be made of ice though.... and needs a key..."
	icon = 'icons/obj/artifacts/art_labyrinth.dmi'
	icon_state = "escape_door"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	color = "#4d73c5"

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/art_labyrinth_firekey))
			qdel(I)
			boutput(user, SPAN_NOTICE("\The [I] disperses in your hand, combining with the ice!"))
			src.icon_state = "escape_open"
			src.density = FALSE

	Crossed(atom/movable/AM)
		if (!src.density && AM.hasStatus("art_maze_curse"))
			var/datum/statusEffect/art_curse/maze/curse = AM.getStatusList()["art_maze_curse"]
			curse.linked_curser.lift_curse_specific(TRUE, AM)
		else
			return ..()

/turf/unsimulated/floor/artmaze_icefloor
	name = "ice floor"
	desc = "A hard ice floor"
	icon_state = "ice1"

	New()
		..()
		src.icon_state = "[pick("ice1","ice2","ice3","ice4","ice5","ice6","ice7","ice8","ice9","ice10")]"
		src.set_dir(pick(cardinal))

/turf/unsimulated/floor/artmaze_silicatefloor
	name = "silicate crust"
	desc = "A hard silicate floor"
	icon_state = "iocrust"

/turf/unsimulated/floor/lava/artmaze_lavafloor
	Entered(atom/movable/O, atom/old_loc)
		if (istype(O, /obj/item/art_labyrinth_firekey))
			return
		..()

/turf/unsimulated/floor/artmaze_catwalkfloor
	name = "catwalk support"
	icon = 'icons/turf/catwalk_support.dmi'
	icon_state = "auto_lava"
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MED
	can_burn = FALSE
	can_break = FALSE

	New()
		..()
		var/image/lava = image(icon = 'icons/turf/floors.dmi', icon_state = "lava", layer = src.layer - 0.1)
		src.UpdateOverlays(lava, "lava")

	vertical
		icon_state = "0"

	horizontal
		icon_state = "4"

/*********** DISPLACEMENT CURSE STUFF *************/

/mob/living/intangible/art_curser_displaced_soul
	var/list/statusUiElements = list()

	New(newLoc, mob/living/carbon/human/H)
		src.name = "soul of [H.name]"
		src.real_name = src.name
		src.desc = "This is the soul of [H.name]. Where's their body at?"
		..()
		event_handler_flags &= ~MOVE_NOCLIP
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
		src.sight = 0
		src.see_invisible = INVIS_NONE
		src.see_in_dark = SEE_DARK_HUMAN

		var/icon/I = new /icon()
		I.Insert(H.build_flat_icon(SOUTH), dir = SOUTH)
		I.Insert(H.build_flat_icon(NORTH), dir = NORTH)
		I.Insert(H.build_flat_icon(EAST), dir = EAST)
		I.Insert(H.build_flat_icon(WEST), dir = WEST)
		src.icon = I
		src.color = "#7b88ff"
		src.alpha = 200
		src.add_filter("soul blur", 0, gauss_blur_filter(size = 0.5))

	is_spacefaring()
		return TRUE

	updateStatusUi()
		for(var/datum/statusEffect/S as anything in src.statusUiElements)
			src.client?.screen -= src.statusUiElements[S]
			if (!(S in src.statusEffects))
				qdel(statusUiElements[S])
				src.statusUiElements -= S

		var/spacing = 0.6
		var/pos_x = spacing - 0.2

		for(var/datum/statusEffect/S as anything in src.statusEffects)
			if((S in statusUiElements) && statusUiElements[S])
				var/atom/movable/screen/statusEffect/U = statusUiElements[S]
				U.icon_state = "bg-new"
				U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH-0.7"
				U.update_value()
				src.client?.screen += U
				pos_x -= spacing
			else
				var/atom/movable/screen/statusEffect/U = new /atom/movable/screen/statusEffect
				U.init(src, S)
				U.icon_state = "bg-new"
				statusUiElements[S] = U
				U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH-0.7"
				U.update_value()
				src.client?.screen += U
				pos_x -= spacing
				animate_buff_in(U)

	say()
		if (!ON_COOLDOWN(src, "displaced_soul_speak", 2 SECONDS))
			src.visible_message(SPAN_ALERT("\The [src.name]'s mouth moves, but you can't tell what they're saying!"), SPAN_ALERT("Nothing comes out of your mouth!"))
		return

	click(atom/target)
		if (src.client?.check_key(KEY_EXAMINE))
			src.examine_verb(target)

	Move(turf/NewLoc, direct) // moves through mobs but not obstacles
		for (var/obj/O in NewLoc)
			if (direct in NewLoc.blocked_dirs)
				return FALSE
			if (NewLoc.blocked_dirs)
				return ..()
			if (O.density)
				if (istype(O, /obj/machinery/door/airlock))
					src.set_loc(NewLoc)
					return TRUE
				return FALSE
		return ..()

	mouse_drop()
		return

	MouseDrop_T()
		return
