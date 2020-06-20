#define CAM_RANGE 7

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

/mob/dead/aieye
	name = "AI Eye"
	icon = 'icons/mob/ai.dmi'
	icon_state = "a-eye"
	invisibility = 9
	see_invisible = 9
	density = 0
	layer = 101
	see_in_dark = SEE_DARK_FULL
	stat = 0
	mob_flags = SEE_THRU_CAMERAS | USR_DIALOG_UPDATES_RANGE

	var/mob/living/silicon/ai/mainframe = null
	var/last_loc = 0

	var/list/last_range = list()
	var/list/current_range = list()

	var/x_edge = 0
	var/y_edge = 0
	var/turf/T = 0

	New()
		src.cancel_camera()
		last_loc = src.loc
		..()
		sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
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

	Logout()
		//if (src.client)
		//	src.client.show_popup_menus = 1

		if(src.last_client)
			for(var/key in aiImages)
				var/image/I = aiImages[key]
				src.last_client.images -= I

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

	Move(NewLoc, direct)//Ewww!
		last_loc = src.loc

		if (src.mainframe)
			src.mainframe.tracker.cease_track()

		if (!isturf(src.loc))
			src.cancel_camera()

		if (NewLoc)
			dir = get_dir(loc, NewLoc)
			src.loc = (NewLoc) //src.set_loc(NewLoc) we don't wanna refresh last_range here and as fas as i can tell there's no reason we Need set_loc
		else

			dir = direct
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

	set_loc(var/newloc as turf|mob|obj in world)
		if (isturf(newloc) && newloc:z != 1) // Sorry!
			src.return_mainframe()
		else
			last_loc = src.loc
			..()

	click(atom/target, params, location, control)
		if (!src.mainframe) return

		if (!src.mainframe.stat && !src.mainframe.restrained() && !src.mainframe.hasStatus(list("weakened", "paralysis", "stunned")))
			if(src.client.check_any_key(KEY_OPEN | KEY_BOLT | KEY_SHOCK) && istype(target, /obj) )
				var/obj/O = target
				O.receive_silicon_hotkey(src)
				return

		//var/inrange = in_range(target, src)
		//var/obj/item/equipped = src.equipped()

		if (!src.client.check_any_key(KEY_EXAMINE | KEY_OPEN | KEY_BOLT | KEY_SHOCK) ) // ugh
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
				dir = get_dir(src, target)


			target.attack_ai(src, params, location, control)

		if (src.client.check_any_key(KEY_EXAMINE))
			. = ..()

	update_cursor()
		if (src.client)
			if (src.client.check_key(KEY_OPEN))
				src.set_cursor('icons/cursors/open.dmi')
				return
			if (src.client.check_key(KEY_BOLT))
				src.set_cursor('icons/cursors/bolt.dmi')
				return
			if(src.client.check_key(KEY_SHOCK))
				src.set_cursor('icons/cursors/shock.dmi')
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
		if (href_list["termmsg"]) //Oh yeah, message that terminal!
			var/termid = href_list["termmsg"]
			if(!termid || !(termid in mainframe.terminals))
				boutput(src, "That terminal is not connected!")
				return
			var/t = input(usr, "Please enter message", termid, null) as text
			if (!t)
				return

			if(isdead(mainframe))
				boutput(src, "You cannot interface with a terminal because you are dead!")
				return

			t = copytext(adminscrub(t), 1, 65)
			//Send the actual message signal
			boutput(src, "<b>([termid]):</b> [t]")
			mainframe.post_status(termid, "command","term_message","data",t)
			//Might as well log what they said too!
			logTheThing("diary", src, null, ": [t]", "say")
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

	emote(var/act, var/voluntary = 0)
		if (mainframe)
			mainframe.emote(act, voluntary)

	hearing_check(var/consciousness_check = 0) //can't hear SHIT - everything is passed from the AI mob through send_message and whatever
		return 0


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
			ticker.centralized_ai_laws.show_laws(src)
		return

	verb/cmd_return_mainframe()
		set category = "AI Commands"
		set name = "Return to Mainframe"

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
			if(P && P.operating)
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
		if(mainframe)
			mainframe.cancel_camera()
		SPAWN_DBG(1 DECI SECOND)
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

//---TURF---//
/turf/var/image/aiImage
/turf/var/list/cameras = null

/turf/proc/addCameraCoverage(var/obj/machinery/camera/C) //copy pasted for use below in updatecoverage to reduce heavy proc calls. dont change one without the other!
	var/cam_amount = src.cameras ? src.cameras.len : 0
	if(src.cameras == null)
		src.cameras = list(C)
		if(C.coveredTiles == null)
			C.coveredTiles = list(src)
		else
			if(!C.coveredTiles.Find(src))
				C.coveredTiles.Add(src)
	else
		if(!src.cameras.Find(C))
			src.cameras.Add(C)
		if(C.coveredTiles == null)
			C.coveredTiles = list(src)
		else
			if(!C.coveredTiles.Find(src))
				C.coveredTiles.Add(src)

	if (cam_amount < src.cameras.len)
		if (src.aiImage)
			src.aiImage.loc = null

	return

/turf/proc/removeCameraCoverage(var/obj/machinery/camera/C) //copy pasted for use below in updatecoverage to reduce heavy proc calls. dont change one without the other!
	if(src.cameras == null) return

	if(src.cameras.Find(C))
		src.cameras.Remove(C)

	if(C.coveredTiles.Find(src))
		C.coveredTiles.Remove(src)

	if(!src.cameras.len)
		src.cameras = null

		if (src.aiImage)
			src.aiImage.loc = src

	return

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
	if(istype(usr,/mob/dead/aieye))//todo, make this a var for cheapernesseress?
		if(aiImage)
			usr.client.show_popup_menus = (cameras && cameras.len)
*/

//---TURF---//

//---CAMERA---//
/obj/machinery/camera/var/list/coveredTiles = null

/obj/machinery/camera/proc/updateCoverage()
	//					HEY READ THIS
	//This proc gets called a lot and it loops through a lot of stuff so I've copy+pasted anything it invokes to cut down on proc calls
	//					HEY READ THIS

	var/list/prev_tiles = 0
	var/list/new_tiles = list()

	if (coveredTiles != null && coveredTiles.len)
		prev_tiles = coveredTiles

	for(var/turf/T in view(CAM_RANGE, get_turf(src)))
		new_tiles += T

	if (prev_tiles)
		for(var/atom in (prev_tiles - new_tiles))
			var/turf/O = atom
			//O.removeCameraCoverage(src)
			//removeCameraCoverage copy+paste begin!
			if(O.cameras == null) continue

			//if(O.cameras.Find(src))
			//	O.cameras.Remove(src)
			O.cameras -= src
			//if(src.coveredTiles.Find(O))
			//	src.coveredTiles.Remove(O)
			src.coveredTiles -= O

			if(!O.cameras.len)
				O.cameras = null

				if (O.aiImage)
					O.aiImage.loc = O

			LAGCHECK(LAG_HIGH)
			//copy paste end!

	for(var/atom in (new_tiles - prev_tiles))
		var/turf/t = atom

		//t.addCameraCoverage(src)
		//add camera coverage copy+paste begin!
		var/cam_amount = t.cameras ? t.cameras.len : 0
		if(t.cameras == null)
			t.cameras = list(src)
			if(src.coveredTiles == null)
				src.coveredTiles = list(t)
			else
				//if(!src.coveredTiles.Find(t))
				//	src.coveredTiles.Add(t)
				src.coveredTiles += t
		else
			//if(!t.cameras.Find(src))
			//	t.cameras.Add(src)
			t.cameras += src
			if(src.coveredTiles == null)
				src.coveredTiles = list(t)
			else
				//if(!src.coveredTiles.Find(t))
				//	src.coveredTiles.Add(t)
				src.coveredTiles += t

		if (cam_amount < t.cameras.len)
			if (t.aiImage)
				t.aiImage.loc = null
		//copy paste end!


		//t.adjustCameraImage()
		//adjustCameraImage copy+paste begin!
		if(!istype(t.aiImage)) continue

		if( t.cameras.len >= 1 )
			t.aiImage.loc = null
		else if( t.cameras == null )
			t.aiImage.loc = t

		LAGCHECK(LAG_HIGH)
		//copy paste end!

	return


	//old version below
	/*
	if(coveredTiles != null && coveredTiles.len)
		for(var/turf/O in coveredTiles.Copy())
			LAGCHECK(LAG_HIGH)

			//O.removeCameraCoverage(src)
			//removeCameraCoverage copy+paste begin!
			if(O.cameras == null) continue

			if(O.cameras.Find(src))
				O.cameras.Remove(src)

			if(src.coveredTiles.Find(O))
				src.coveredTiles.Remove(O)

			if(!O.cameras.len)
				O.cameras = null

				if (O.aiImage)
					O.aiImage.alpha = 255
					O.aiImage.override = 1

			//copy paste end!



	for(var/turf/t in view(CAM_RANGE, get_turf(src)))
		LAGCHECK(LAG_HIGH)

		//t.addCameraCoverage(src)
		//add camera coverage copy+paste begin!
		var/cam_amount = t.cameras ? t.cameras.len : 0
		if(t.cameras == null)
			t.cameras = list(src)
			if(src.coveredTiles == null)
				src.coveredTiles = list(t)
			else
				if(!src.coveredTiles.Find(t))
					src.coveredTiles.Add(t)
		else
			if(!t.cameras.Find(src))
				t.cameras.Add(src)
			if(src.coveredTiles == null)
				src.coveredTiles = list(t)
			else
				if(!src.coveredTiles.Find(t))
					src.coveredTiles.Add(t)

		if (cam_amount < t.cameras.len)
			if (t.aiImage)
				t.aiImage.alpha = 0
				t.aiImage.override = 0
		//copy paste end!


		//t.adjustCameraImage()
		//adjustCameraImage copy+paste begin!
		if(!istype(t.aiImage)) continue

		if( t.cameras.len >= 1 )
			t.aiImage.alpha = 0
			t.aiImage.override = 0
		else if( t.cameras == null )
			t.aiImage.alpha = 255
			t.aiImage.override = 1
		//copy paste end!

	return
	*/

//---CAMERA---//

//---MISC---//
var/list/camImages = list()


//moved to input.dm
/*
/client/Click(thing)
	if (src.mob.mob_flags & SEE_THRU_CAMERAS)
		if(isturf(thing) && (!thing:cameras || !thing:cameras.len))
			return
	return ..()
*/


/*
/atom/RL_SetOpacity(newopacity)
	if( opacity == newopacity ) return
	.=..()
	//for(var/turf/t in range(CAM_RANGE, src))
	//	t.cameraTotal = 0

	SPAWN_DBG(0) //maybe bad, maybe good... this is a test by MBC, please remove if its shit. (There's just a lot of things that call RL_SetOpacity that we don't really want to be stalled by lagcheck!)
		if (isturf(src.loc))
			var/turf/T = src.loc
			for(var/obj/machinery/camera/C in T.cameras)
				//if( get_dist(C.loc, src) <= CAM_RANGE )
				//var/list/inview = view(CAM_RANGE,C)
				for(var/turf/t in range(CAM_RANGE, C))
					LAGCHECK(LAG_MED)
					if( !t.aiImage ) continue
					//var/camTotal = 0

					//var/dist = get_dist(t, C)
					//if( t in inview )
					//	camTotal++
					//else
					//	camTotal = max(camTotal-1,0)

					if( t.cameras && t.cameras.len )
						t.aiImage.alpha = 0
						t.aiImage.override = 0
					else
						t.aiImage.alpha = 255
						t.aiImage.override = 1
				if (C.unsubscribe_grace_counter == -1) //we are not a processing camera. Do manual update call!
					C.updateCoverage()
			LAGCHECK(LAG_REALTIME)
*/

//---MISC---//


var/aiDirty = 2
world/proc/updateCameraVisibility()
	if(!aiDirty) return
	if(aiDirty == 2)
		var/mutable_appearance/ma = new(image('icons/misc/static.dmi', icon_state = "static"))
		ma.plane = PLANE_HUD
		ma.layer = 100
		ma.color = "#777777"
		ma.dir = pick(alldirs)
		ma.appearance_flags = TILE_BOUND | KEEP_APART
		ma.name = " "
		for(var/turf/t in world)//ugh
			if( t.z != 1 ) continue
			//t.aiImage = new /obj/overlay/tile_effect/camstatic(t)

			t.aiImage = new
			t.aiImage.appearance = ma
			t.aiImage.loc = t

			addAIImage(t.aiImage, "aiImage_\ref[t.aiImage]")

			LAGCHECK(100)

		aiDirty = 1
	for(var/obj/machinery/camera/C in cameras)
		for(var/turf/t in view(CAM_RANGE, get_turf(C)))
			LAGCHECK(LAG_HIGH)
			if (!t.aiImage) continue
			//var/dist = get_dist(t, C)
			if (t.cameras && t.cameras.len)
				t.aiImage.loc = null
			else
				t.aiImage.loc = t
	aiDirty = 0

/obj/machinery/camera/proc/remove_from_turfs() //check if turf cameras is 0 . Maybe loop through each affected turf's cameras, and update static on them here instead of going thru updateCameraVisibility()?
	//world << "Camera deleted! @ [src.loc]"
	for(var/turf/t in view(CAM_RANGE,get_turf(src)))
		LAGCHECK(LAG_HIGH)
		if(t.aiImage)
			t.aiImage.loc = t
	aiDirty = 1

	world.updateCameraVisibility()

/obj/machinery/camera/proc/add_to_turfs() //chck if turf cameras is 1
	aiDirty = 1
	if (current_state > GAME_STATE_WORLD_INIT)
		world.updateCameraVisibility()

