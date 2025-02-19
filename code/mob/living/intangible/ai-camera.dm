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
//Cyborgs /mob/living/silicon/robot  X

TYPEINFO(/mob/living/intangible/aieye)
	start_listen_modifiers = null
	start_listen_inputs = null
	start_listen_languages = null
	start_speech_modifiers = null
	start_speech_outputs = null

/mob/living/intangible/aieye
	name = "\improper AI eye"
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai-eye"
	density = 0
	layer = 101
	see_in_dark = SEE_DARK_FULL
	stat = STAT_ALIVE
	mob_flags = SEE_THRU_CAMERAS | USR_DIALOG_UPDATES_RANGE

	can_lie = FALSE //can't lie down, you're a floating ghostly eyeball
	can_bleed = FALSE
	metabolizes = FALSE
	blood_id = null
	use_stamina = FALSE // floating ghostly eyes dont get tired

	speech_verb_say = "states"
	speech_verb_ask = "queries"
	speech_verb_exclaim = "declares"
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	speech_bubble_icon_sing = "noterobot"
	speech_bubble_icon_sing_bad = "noterobot"

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
		APPLY_ATOM_PROPERTY(src, PROP_MOB_CANNOT_VOMIT, src)
		if (render_special)
			render_special.set_centerlight_icon("nightvision", rgb(0.5 * 255, 0.5 * 255, 0.5 * 255))
		AddComponent(/datum/component/minimap_marker/minimap, MAP_AI | MAP_OBSERVER, "ai_eye")

	Login()
		.=..()
		src.client.show_popup_menus = 1
		var/client_color = src.client.color
		src.client.color = "#000000"
		SPAWN(0) //let's try not hanging the entire server for 6 seconds every time an AI has wonky internet
			if (!src.client) // just client things
				return
			src.client.images += aiImages
			src.bioHolder.mobAppearance.pronouns = src.client.preferences.AH.pronouns
			src.update_name_tag()
			src.job = "AI"
			if (src.mind)
				src.mind.assigned_role = "AI"
			animate(src.client, 0.3 SECONDS, color = client_color)
			var/sleep_counter = 0
			for(var/image/I as anything in aiImagesLowPriority)
				src.client << I
				if(sleep_counter++ % (300 * 10) == 0)
					LAGCHECK(LAG_LOW)

	Logout()
		var/client/cl = src.last_client
		if (!cl)
			return ..()
		SPAWN(0)
			cl?.images -= aiImages
			var/sleep_counter = 0
			for(var/image/I as anything in aiImagesLowPriority)
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
		if(keys && src.move_dir && !src.override_movement_controller && !istype(src.loc, /turf)) //when a movement key is pressed, move out of tracked mob
			var/mob/living/intangible/aieye/O = src
			O.set_loc(get_turf(src))
		. = ..()

	Move(var/turf/NewLoc, direct) //Ewww!
		last_loc = src.loc

		src.contextActionsOnMove()
		// contextbuttons can also exist on our mainframe and the eye shares the same hud, fun stuff.
		src.mainframe?.contextActionsOnMove()

		if (src.mainframe)
			src.mainframe.tracker.cease_track()

		if (!isturf(src.loc))
			src.cancel_camera()

		. = ..()

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
			RegisterSignal(temp, COMSIG_MOVABLE_SET_LOC, PROC_REF(check_eye_z))
			outer_eye_atom = temp
		else
			UnregisterSignal(src.outer_eye_atom, COMSIG_MOVABLE_SET_LOC)
		. = ..()


	click(atom/target, params, location, control)
		if (!src.mainframe) return

		var/in_ai_range = (get_z(mainframe) == get_z(target)) || (inunrestrictedz(target) && inonstationz(mainframe))

		if (!src.mainframe.stat && !src.mainframe.restrained() && !src.mainframe.hasStatus(list("knockdown", "unconscious", "stunned")))
			if(src.client.check_any_key(KEY_OPEN | KEY_BOLT | KEY_SHOCK) && istype(target, /obj) )
				var/obj/O = target
				if(in_ai_range)
					O.receive_silicon_hotkey(src)
				else
					src.show_text("Your mainframe was unable relay this command that far away!", "red")
				return

		//var/inrange = in_interact_range(target, src)
		//var/obj/item/equipped = src.equipped()

		if(src.client.check_any_key(KEY_OPEN) && istype(target, /mob/living/silicon))
			var/mob/living/silicon/S = target
			src.mainframe.deploy_to_shell(S)
			return

		if (!src.client.check_any_key(KEY_EXAMINE | KEY_OPEN | KEY_BOLT | KEY_SHOCK | KEY_POINT) ) // ugh
			if (src.targeting_ability)
				..()
				return

			//only allow Click-to-track on mobs. Some of the 'trackable' atoms are also machines that can open a dialog and we don't wanna mess with that!
			if (src.mainframe && ismob(target) && is_mob_trackable_by_AI(target))
				mainframe.ai_actual_track(target)
			//else if (isturf(target))
			//	var/turf/T = target
			//	src.loc = T
			//var/turf/T = target
			//boutput(world, "[T] [isturf(target)] [findtext(control, "map_viewport")] [control]")
			if( isturf(target) && findtext(control, "map_viewport") )
				src.set_loc(target)

			if (GET_DIST(src, target) > 0)
				src.set_dir(get_dir(src, target))

			if(in_ai_range)
				target.attack_ai(src, params, location, control)

		if (src.client.check_any_key(KEY_POINT) && in_ai_range)
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

	say_radio()
		src.mainframe.say_radio()

	say_main_radio(msg as text)
		src.mainframe.say_main_radio(msg)

	emote(var/act, var/voluntary = 0)
		..()
		if (mainframe)
			mainframe.emote(act, voluntary)

	hearing_check(var/consciousness_check = 0, for_audio = FALSE) //can't hear SHIT - everything is passed from the AI mob through send_message and whatever
		if (for_audio)
			return TRUE
		return 0

	resist()
		return 0 //can't actually resist anything because there's nothing to resist, but maybe the hot key could be used for something?

	//death stuff that should be passed to mainframe
	gib(give_medal, include_ejectables) //this should be admin only, I would hope
		message_admins("something tried to gib the AI Eye - if this wasn't an admin action, something has gone badly wrong")
		return 0
		//return mainframe.gib(give_medal, include_ejectables) //re-enable this when you are SUPREMELY CONFIDENT that all calls to gib() have intangible checks


	create_viewport(kind, title, size, share_planes)
		if (length(src.client?.getViewportsByType(VIEWPORT_ID_AI)) >= src.mainframe.viewport_limit)
			boutput(src, SPAN_ALERT("You lack the computing resources needed to open another viewport."))
		else
			. = ..()

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
			boutput(src, SPAN_ALERT("You lack a dedicated mainframe! This is a bug, report to an admin!"))
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
			boutput(src, SPAN_ALERT("You lack a dedicated mainframe! This is a bug, report to an admin!"))
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

	verb/show_alerts()
		set category = "AI Commands"
		set name = "Show Alert Minimap"
		mainframe?.open_alert_minimap(src)

	verb/toggle_alerts_verb()
		set category = "AI Commands"
		set name = "Toggle Alerts"
		set desc = "Toggle alert messages in the game window. You can always check them with 'Show Alert Minimap'."
		mainframe?.toggle_alerts_verb()

	verb/access_area_apc()
		set category = "AI Commands"
		set name = "Access Area APC"
		set desc = "Access the APC of a station area."

		var/area/A = get_area(src)
		if(istype(A, /area/station/))
			var/obj/machinery/power/apc/P = A.area_apc
			if(P)
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

	verb/toggle_lock()
		set category = "AI Commands"
		set name = "Toggle Cover Lock"
		if(mainframe)
			mainframe.toggle_lock()

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

	verb/rename_self()
		set category = "AI Commands"
		set name = "Change Designation"
		set desc = "Change your name."
		mainframe?.rename_self()

	verb/go_offline()
		set category = "AI Commands"
		set name = "Go Offline"
		set desc = "Disconnect your brain such that a new AI can take your place."
		mainframe?.go_offline()

	stopObserving()
		src.set_loc(get_turf(src))
		src.observing = null

//---TURF---//
/turf/var/image/aiImage
/turf/var/list/obj/machinery/camera/cameras
/turf/var/list/datum/component/camera_coverage_emitter/camera_coverage_emitters

//slow
/*
/turf/MouseEntered()
	.=..()
	if(istype(usr,/mob/living/intangible/aieye))//todo, make this a var for cheapernesseress?
		if(aiImage)
			usr.client.show_popup_menus = (length(cameras))
*/

//---MISC---//
/mob/living/intangible/aieye/proc/check_eye_z(source)
	var/atom/movable/temp = source
	while(!istype(temp.loc, /turf))
		temp = temp.loc
	if(temp != source)
		RegisterSignal(temp, COMSIG_MOVABLE_SET_LOC, PROC_REF(check_eye_z))
		UnregisterSignal(outer_eye_atom, COMSIG_MOVABLE_SET_LOC)
		outer_eye_atom = temp

	var/turf/T = get_turf(temp)
	if(isrestrictedz(T?.z))
		src.sight &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)
	else
		src.sight |= (SEE_TURFS | SEE_MOBS | SEE_OBJS)
