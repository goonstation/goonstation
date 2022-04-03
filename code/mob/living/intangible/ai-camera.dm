//ISSUES: Cameras inside beepsky and other bots cause issues. They move around and don't update properly. ((FIXED I THINK))
//		  Doors sometimes for some reason fail to properly update their opacity. Investigate.
//		  Cutting cameras is not handled. ((FIXED I THINK))
//		  And much more ...

//Things with cameras in them: (these are handled now! I'm just leaving the comment as a note if something breaks)
//Camera Cyber eyes /obj/item/organ/eye/cyber/camera X
//Spy stickers /obj/item/sticker/spy X
//Camera Helmets /obj/item/clothing/head/helmet/camera X
//Bots /obj/machinery/bot  X
//Observables /obj/observable  X
//Colosseum putts /obj/machinery/colosseum_putt  X
//Cyborgs /mob/living/silicon/robot  X

/mob/living/intangible/aieye
	name = "AI Eye"
	icon = 'icons/mob/ai.dmi'
	icon_state = "a-eye"
	density = 0
	layer = 101
	see_in_dark = SEE_DARK_FULL
	stat = 0
	mob_flags = SEE_THRU_CAMERAS | USR_DIALOG_UPDATES_RANGE

	can_lie = 0 //can't lie down, you're a floating ghostly eyeball

	var/mob/living/silicon/ai/mainframe = null
	var/last_loc = 0

	var/list/last_range = list()
	var/list/current_range = list()

	var/x_edge = 0
	var/y_edge = 0
	var/turf/T = 0

	var/outer_eye_atom = null

	New()
		src.cancel_camera()
		last_loc = src.loc
		..()
		see_invisible = INVIS_AI_EYE
		sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_AI_EYE)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
		if (render_special)
			render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))
	Login()
		.=..()
		src.client.show_popup_menus = 1
		//if (src.client)
		//	src.client.show_popup_menus = 0
		for(var/key in aiImages)
			var/image/I = aiImages[key]
			src.client << I
		SPAWN(0)
			var/sleep_counter = 0
			for(var/key in aiImagesLowPriority)
				var/image/I = aiImagesLowPriority[key]
				src.client << I
				if(sleep_counter++ % (300 * 10) == 0)
					LAGCHECK(LAG_LOW)

	Logout()
		//if (src.client)
		//	src.client.show_popup_menus = 1
		var/client/cl = src.last_client
		if(cl)
			for(var/key in aiImages)
				var/image/I = aiImages[key]
				cl.images -= I
		SPAWN(0)
			var/sleep_counter = 0
			for(var/key in aiImagesLowPriority)
				var/image/I = aiImagesLowPriority[key]
				cl?.images -= I
				if(sleep_counter++ % (300 * 10) == 0)
					LAGCHECK(LAG_LOW)

		.=..()

	isAIControlled()
		return 1

	build_keybind_styles(client/C)
		..()
		C.apply_keybind("robot")

		if (!C.preferences.use_wasd)
			C.apply_keybind("robot_arrow")

		if (C.preferences.use_azerty)
			C.apply_keybind("robot_azerty")
		if (C.tg_controls)
			C.apply_keybind("robot_tg")

	process_move(keys)
		if(keys && src.move_dir && !src.use_movement_controller && !istype(src.loc, /turf)) //when a movement key is pressed, move out of tracked mob
			var/mob/living/intangible/aieye/O = src
			O.set_loc(get_turf(src))
		. = ..()

	Move(var/turf/NewLoc, direct)//Ewww!
		last_loc = src.loc

		src.closeContextActions()
		// contextbuttons can also exist on our mainframe and the eye shares the same hud, fun stuff.
		src.mainframe.closeContextActions()

		if (src.mainframe)
			src.mainframe.tracker.cease_track()

		if (!isturf(src.loc))
			src.cancel_camera()

		if (NewLoc)
			src.set_dir(get_dir(loc, NewLoc))
			src.set_loc(NewLoc) //src.set_loc(NewLoc) we don't wanna refresh last_range here and as fas as i can tell there's no reason we Need set_loc
		else

			src.set_dir(direct)
			if((direct & NORTH) && src.y < world.maxy)
				src.y++
			if((direct & SOUTH) && src.y > 1)
				src.y--
			if((direct & EAST) && src.x < world.maxx)
				src.x++
			if((direct & WEST) && src.x > 1)
				src.x--

		//boutput(src,"[client.images.len]") //useful for debuggin that one bad bug

		if(src.loc.z != 1)	//you may only move on the station z level!!!
			src.cancel_camera()

	proc/update_statics()	//update seperate from move(). Mostly same code.
		return

	set_loc(atom/newloc)
		if (isturf(newloc) && newloc.z != Z_LEVEL_STATION) // Sorry!
			src.return_mainframe()
		else
			last_loc = src.loc
			..()

	set_eye(atom/new_eye)
		var/turf/T = new_eye ? get_turf(new_eye) : get_turf(src)
		if( !(T && isrestrictedz(T.z)) )
			src.sight |= (SEE_TURFS | SEE_MOBS | SEE_OBJS)
		else
			src.sight &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)

		if(new_eye && new_eye != src)
			var/atom/movable/temp = new_eye
			while(!istype(temp.loc, /turf))
				temp = temp.loc
			UnregisterSignal(outer_eye_atom, COMSIG_MOVABLE_SET_LOC)
			RegisterSignal(temp, COMSIG_MOVABLE_SET_LOC, .proc/check_eye_z)
			outer_eye_atom = temp
		else
			UnregisterSignal(src.outer_eye_atom, COMSIG_MOVABLE_SET_LOC)
		. = ..()


	click(atom/target, params, location, control)
		if (!src.mainframe) return

		if (!src.mainframe.stat && !src.mainframe.restrained() && !src.mainframe.hasStatus(list("weakened", "paralysis", "stunned")))
			if(src.client.check_any_key(KEY_OPEN | KEY_BOLT | KEY_SHOCK) && istype(target, /obj) )
				var/obj/O = target
				O.receive_silicon_hotkey(src)
				return

		//var/inrange = in_interact_range(target, src)
		//var/obj/item/equipped = src.equipped()

		if (!src.client.check_any_key(KEY_EXAMINE | KEY_OPEN | KEY_BOLT | KEY_SHOCK | KEY_POINT) ) // ugh
			//only allow Click-to-track on mobs. Some of the 'trackable' atoms are also machines that can open a dialog and we don't wanna mess with that!
			if (src.mainframe && ismob(target) && is_mob_trackable_by_AI(target))
				mainframe.ai_actual_track(target)
			//else if (isturf(target))
			//	var/turf/T = target
			//	src.loc = T
			//var/turf/T = target
			//boutput(world, "[T] [isturf(target)] [findtext(control, "map_viewport")] [control]")
			if( isturf(target) && findtext(control, "map_viewport") )
				set_loc(src, target)

			if (get_dist(src, target) > 0)
				src.set_dir(get_dir(src, target))


			target.attack_ai(src, params, location, control)

		if (src.client.check_any_key(KEY_POINT))
			var/turf/T = get_turf(target)
			mainframe.show_hologram_context(T)
			return

		if (src.client.check_any_key(KEY_EXAMINE))
			. = ..()

	update_cursor()
		if (src.client)
			if (src.client.check_key(KEY_OPEN))
				src.set_cursor('icons/cursors/open.dmi')
				return
			else if (src.client.check_key(KEY_BOLT))
				src.set_cursor('icons/cursors/bolt.dmi')
				return
			else if(src.client.check_key(KEY_SHOCK))
				src.set_cursor('icons/cursors/shock.dmi')
				return
			else if(src.client.check_key(KEY_POINT))
				src.set_cursor('icons/cursors/point.dmi')
				return
		return ..()

	Topic(href, href_list)
		..()
		if (usr != src || !mainframe)
			return

		if (href_list["switchcamera"])
			mainframe.tracker.cease_track()
			mainframe.switchCamera(locate(href_list["switchcamera"]))
		if (href_list["showalerts"])
			mainframe.ai_alerts()

		return

	Stat()
		..()
		if(mainframe)
			if(mainframe.cell)
				stat("Internal Power Cell:", "[mainframe.cell.charge]/[mainframe.cell.maxcharge]")

	is_spacefaring()
		return 1

	movement_delay()
		// hey, look, this is bad, I know but I don't see a nicer way to make sprinting work for AI since shift is the bolt hotkey
		if (src.client && src.client.check_key(KEY_BOLT))
			return 0.4 + movement_delay_modifier
		else
			return 0.75 + movement_delay_modifier

	say_understands(var/other)
		if (ishuman(other))
			var/mob/living/carbon/human/H = other
			if (!H.mutantrace || !H.mutantrace.exclusive_language)
				return 1
		if (isrobot(other))
			return 1
		if (isshell(other))
			return 1
		if (ismainframe(other))
			return 1
		return ..()

	say(var/message)
		if (src.mainframe)
			src.mainframe.say(message)
		else
			visible_message("[CLEAN(src)] says, <b>[CLEAN(message)]</b>")

	say_radio()
		src.mainframe.say_radio()

	say_main_radio(msg as text)
		src.mainframe.say_main_radio(msg)

	emote(var/act, var/voluntary = 0)
		if (mainframe)
			mainframe.emote(act, voluntary)

	hearing_check(var/consciousness_check = 0) //can't hear SHIT - everything is passed from the AI mob through send_message and whatever
		return 0

	resist()
		return 0 //can't actually resist anything because there's nothing to resist, but maybe the hot key could be used for something?

	//death stuff that should be passed to mainframe
	gib(give_medal, include_ejectables) //this should be admin only, I would hope
		message_admins("something tried to gib the AI Eye - if this wasn't an admin action, something has gone badly wrong")
		return 0
		//return mainframe.gib(give_medal, include_ejectables) //re-enable this when you are SUPREMELY CONFIDENT that all calls to gib() have intangible checks



	proc/mainframe_check()
		if (mainframe)
			if (isdead(mainframe))
				mainframe.return_to(src)
		else
			death()

	verb/show_laws()
		set category = "AI Commands"
		set name = "Show Laws"

		if (src.mainframe)
			mainframe.show_laws(0, src)
		else
			boutput(src, "<span class='alert'>You lack a dedicated mainframe! This is a bug, report to an admin!</span>")
		return

	verb/cmd_return_mainframe()
		set category = "AI Commands"
		set name = "Recall to Mainframe"

		return_mainframe()
		return

	proc/return_mainframe()
		if(mainframe)
			last_loc = src.loc
			mainframe.return_to(src)
			update_statics()
		else
			boutput(src, "<span class='alert'>You lack a dedicated mainframe! This is a bug, report to an admin!</span>")
		return

	verb/ai_view_crew_manifest()
		set category = "AI Commands"
		set name = "View Crew Manifest"
		if (mainframe)
			mainframe.ai_view_crew_manifest()

	verb/ai_state_laws_standard()
		set category = "AI Commands"
		set name = "State Standard Laws"
		if (mainframe)
			mainframe.ai_state_laws_standard()

	verb/ai_state_laws_all()
		set category = "AI Commands"
		set name = "State All Laws"
		if (mainframe)
			mainframe.ai_state_laws_all()

	verb/ai_set_laws_all()
		set category = "AI Commands"
		set name = "Set Fake Laws"
		if (mainframe)
			mainframe.ai_set_fake_laws()

	verb/ai_state_laws_fake()
		set category = "AI Commands"
		set name = "State Fake Laws"
		if (mainframe)
			mainframe.ai_state_fake_laws()

	verb/ai_statuschange()
		set category = "AI Commands"
		set name = "AI status"
		if (mainframe)
			mainframe.ai_statuschange()

	verb/ai_colorchange()
		set category = "AI Commands"
		set name = "AI Color"
		if (mainframe)
			mainframe.ai_colorchange()

	verb/reset_apcs()
		set category = "AI Commands"
		set name = "Reset All APCs"
		set desc = "Resets all APCs on the station."
		mainframe?.reset_apcs()

	verb/de_electrify_verb()
		set category = "AI Commands"
		set name = "Remove All Electrification"
		set desc = "Removes electrification from all airlocks on the station."
		if (mainframe)
			mainframe.de_electrify_verb()

	verb/unbolt_all_airlocks()
		set category = "AI Commands"
		set name = "Unbolt All Airlocks"
		set desc = "Unbolts all airlocks on the station."
		if (mainframe)
			mainframe.unbolt_all_airlocks()

	verb/toggle_alerts_verb()
		set category = "AI Commands"
		set name = "Toggle Alerts"
		set desc = "Toggle alert messages in the game window. You can always check them with 'Show Alerts'."
		if (mainframe)
			mainframe.toggle_alerts_verb()

	verb/access_area_apc()
		set category = "AI Commands"
		set name = "Access Area APC"
		set desc = "Access the APC of a station area."

		var/area/A = get_area(src)
		if(istype(A, /area/station/))
			var/obj/machinery/power/apc/P = A.area_apc
			if(P?.operating)
				P.attack_ai(src)
				return

		src.show_text("Unable to interface with area APC.", "red")

	verb/access_internal_pda()
		set category = "AI Commands"
		set name = "AI PDA"
		set desc = "Access your internal PDA device."

		if(mainframe)
			mainframe.access_internal_pda()

	verb/access_internal_radio()
		set category = "AI Commands"
		set name = "Access Internal Radios"
		set desc = "Access your internal radios."

		if(mainframe)
			mainframe.access_internal_radio()

	verb/ai_camera_list()
		set category = "AI Commands"
		set name = "Show Camera List"

		if(mainframe)
			mainframe.ai_camera_list()

	verb/ai_camera_track()
		set category = "AI Commands"
		set name = "Track With Camera"

		if(mainframe)
			mainframe.ai_camera_track()

	cancel_camera()
		set category = "AI Commands"
		set name = "Cancel Camera View"

		..()
		mainframe?.cancel_camera()
		SPAWN(1 DECI SECOND)
			src.return_mainframe()

	verb/ai_call_shuttle()
		set category = "AI Commands"
		set name = "Call Emergency Shuttle"
		if(mainframe)
			mainframe.ai_call_shuttle()

	verb/deploy_to()
		set category = "AI Commands"
		set name = "Deploy to Shell"
		if(mainframe)
			mainframe.deploy_to()

	verb/open_nearest_door()
		set category = "AI Commands"
		set name = "Open Nearest Door to..."
		set desc = "Automatically opens the nearest door to a selected individual, if possible."
		if(mainframe)
			mainframe.open_nearest_door_silicon()

	proc/ai_alerts()
		set category = "AI Commands"
		set name = "Show Alerts"
		if(mainframe)
			mainframe.ai_alerts()

	verb/ai_station_announcement()
		set name = "AI Station Announcement"
		set desc = "Makes a station announcement."
		set category = "AI Commands"
		if(mainframe)
			mainframe.ai_station_announcement()

	verb/view_messageLog()
		set name = "View Message Log"
		set desc = "View all messages sent by terminal connections."
		set category = "AI Commands"
		if(mainframe)
			mainframe.view_messageLog()

	verb/open_map()
		set name = "Open station map"
		set desc = "Click on the map to teleport"
		set category = "AI Commands"
		mainframe?.open_map()


//---TURF---//
/turf/var/image/aiImage
/turf/var/list/cameras = null

/turf/proc/adjustCameraImage()
	if(!istype(src.aiImage)) return

	if( src.cameras.len >= 1 )
		src.aiImage.loc = null
	else if( src.cameras == null )
		src.aiImage.loc = src
	return

//slow
/*
/turf/MouseEntered()
	.=..()
	if(istype(usr,/mob/living/intangible/aieye))//todo, make this a var for cheapernesseress?
		if(aiImage)
			usr.client.show_popup_menus = (length(cameras))
*/

//---TURF---//

//---CAMERA---//
/obj/machinery/camera/var/list/turf/coveredTiles = null

/obj/machinery/camera/proc/updateCoverage()
	LAZYLISTADDUNIQUE(camerasToRebuild, src)
	if (current_state > GAME_STATE_WORLD_INIT && !global.explosions.exploding)
		world.updateCameraVisibility()

//---MISC---//

var/list/obj/machinery/camera/camerasToRebuild
world/proc/updateCameraVisibility(generateAiImages=FALSE)
	set waitfor = FALSE
#if defined(IM_REALLY_IN_A_FUCKING_HURRY_HERE) && !defined(SPACEMAN_DMM)
	// I don't wanna wait for this camera setup shit just GO
	return
#endif

	if(generateAiImages)
		var/mutable_appearance/ma = new(image('icons/misc/static.dmi', icon_state = "static"))
		ma.plane = PLANE_HUD
		ma.layer = 100
		ma.color = "#777777"
		ma.dir = pick(alldirs)
		ma.appearance_flags = TILE_BOUND | KEEP_APART | RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR
		ma.name = " "

		// takes about one second compared to the ~12++ that the actual calculations take
		game_start_countdown?.update_status("Updating cameras...\n(Calculating...)")
//pod wars has no AI so this is just a waste of time...
#if !defined(MAP_OVERRIDE_POD_WARS) && !defined(UPSCALED_MAP)
		var/list/turf/cam_candidates = block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION))

		var/lastpct = 0
		var/thispct = 0
		var/donecount = 0

		for(var/turf/t as anything in cam_candidates) //ugh
			t.aiImage = new
			t.aiImage.appearance = ma
			t.aiImage.dir = pick(alldirs)
			t.aiImage.loc = t

			addAIImage(t.aiImage, "aiImage_\ref[t.aiImage]", low_priority=istype(t, /turf/space))

			donecount++
			thispct = round(donecount / cam_candidates.len * 100)
			if (thispct != lastpct)
				lastpct = thispct
				game_start_countdown?.update_status("Updating cameras...\n[thispct]%")

			LAGCHECK(100)

		for_by_tcl(cam, /obj/machinery/camera)
			LAZYLISTADDUNIQUE(camerasToRebuild, cam)
		game_start_countdown?.update_status("Updating camera vis...\n")

	var/list/turf/staticUpdateTurfs = list()

	for(var/obj/machinery/camera/cam as anything in camerasToRebuild)
		var/list/prev_tiles = cam.coveredTiles
		var/list/new_tiles = list()
		if(cam.camera_status && !isnull(get_turf(cam)))
			for(var/turf/T in view(CAM_RANGE, get_turf(cam)))
				new_tiles += T
		if (prev_tiles)
			for(var/turf/T as anything in (prev_tiles - new_tiles))
				staticUpdateTurfs |= T
				if(isnull(T.cameras)) continue
				T.cameras -= cam
				if(!length(T.cameras))
					T.cameras = null
		if (new_tiles)
			for(var/turf/T as anything in (new_tiles - prev_tiles))
				LAZYLISTADDUNIQUE(T.cameras, cam)
				staticUpdateTurfs |= T

		cam.coveredTiles = new_tiles

	for(var/turf/T as anything in staticUpdateTurfs)
		T.aiImage?.loc = length(T.cameras) ? null : T

	camerasToRebuild = null
#endif

// to be called by admins if everything breaks. TODO move to an admin verb
/proc/force_full_camera_rebuild()
	for_by_tcl(cam, /obj/machinery/camera)
		LAZYLISTADDUNIQUE(camerasToRebuild, cam)
	world.updateCameraVisibility()

/mob/living/intangible/aieye/proc/check_eye_z(source)
	var/atom/movable/temp = source
	while(!istype(temp.loc, /turf))
		temp = temp.loc
	if(temp != source)
		RegisterSignal(temp, COMSIG_MOVABLE_SET_LOC, .proc/check_eye_z)
		UnregisterSignal(outer_eye_atom, COMSIG_MOVABLE_SET_LOC)
		outer_eye_atom = temp

	var/turf/T = get_turf(temp)
	if(isrestrictedz(T?.z))
		src.sight &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)
	else
		src.sight |= (SEE_TURFS | SEE_MOBS | SEE_OBJS)
