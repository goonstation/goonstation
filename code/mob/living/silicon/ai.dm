var/global/list/available_ai_shells = list()
var/list/ai_emotions = list("Happy" = "ai_happy",\
	"Very Happy" = "ai_veryhappy",\
	"Neutral" = "ai_neutral",\
	"Unsure" = "ai_unsure",\
	"Confused" = "ai_confused",\
	"Surprised" = "ai_surprised",\
	"Sad" = "ai_sad",\
	"Mad" = "ai_mad",\
	"BSOD" = "ai_bsod",\
	"Text" = "ai_text",\
	"Blank" = "ai_off")

/mob/living/silicon/ai
	name = "AI"
	voice_name = "synthesized voice"
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	anchored = 1
	density = 1
	emaggable = 0 // Can't be emagged...
	syndicate_possible = 1 // ...but we can become a rogue computer.
	var/datum/hud/ai/hud
	var/last_notice = 0//attack notices
	var/network = "SS13"
	var/classic_move = 1 //Ordinary AI camera movement
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	//var/list/connected_shells = list()
	var/list/installed_modules = list()
	var/aiRestorePowerRoutine = 0
//	var/datum/ai_laws/laws_object = ticker.centralized_ai_laws
//	var/datum/ai_laws/current_law_set = null
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list())
	var/viewalerts = 0
	var/printalerts = 1
	var/announcearrival = 1
	var/arrivalalert = "$NAME has signed up as $JOB."
	var/glitchy_speak = 0
	//Comm over powernet stuff
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null
	var/list/terminals = list() //Stuff connected to us over the powernet
	var/hologramdown = 0 //is the hologram downed?
	var/canvox = 1
	var/can_announce = 1
	var/last_announcement = -INFINITY
	var/announcement_cooldown = 1200
	var/dismantle_stage = 0
	var/datum/light/light
	//var/death_timer = 100
	var/power_mode = 0
	var/power_area = null
	var/obj/machinery/power/apc/local_apc = null
	var/obj/item/device/radio/radio1 = null // See /mob/living/say() in living.dm for AI-related radio code.
	var/obj/item/device/radio/radio2 = null
	var/obj/item/device/radio/radio3 = null
	var/obj/item/device/pda2/internal_pda = null
	var/obj/item/organ/brain/brain = null
	var/moustache_mode = 0
	var/status_message = null
	var/mob/living/silicon/deployed_shell = null

	var/faceEmotion = "ai_happy"
	var/faceColor = "#66B2F2"
	var/list/custom_emotions = null

	var/datum/ai_camera_tracker/tracker = null

	var/image/cached_image = null

	var/last_vox = -INFINITY
	var/vox_cooldown = 1200

	var/has_feet = 0

	sound_fart = 'sound/voice/farts/poo2_robot.ogg'

	req_access = list(access_heads)
	var/obj/item/clothing/head/hat = null

/*
	var/datum/game_mode/malfunction/AI_Module/module_picker/malf_picker
	var/processing_time = 100
	var/list/datum/game_mode/malfunction/AI_Module/current_modules = list()

*/
	var/fire_res_on_core = 0

	health = 250
	max_health = 250
	var/bruteloss = 0
	var/fireloss = 0

	var/mob/dead/aieye/eyecam = null

	var/deployed_to_eyecam = 0

	proc/set_hat(obj/item/clothing/head/hat, var/mob/user as mob)
		if( src.hat )
			src.hat.wear_image.pixel_y = 0
			src.UpdateOverlays(null, "hat")
			if (user)
				user.put_in_hand_or_drop(src.hat)
			else
				src.hat.set_loc(src.loc)
			src.hat = null
		// src.hat.wear_image.pixel_y = 10
		// src.UpdateOverlays(src.hat.wear_image, "hat")
		var/image/hat_image = SafeGetOverlayImage(hat.icon_state, hat.icon, hat.icon_state, src.layer+0.2)
		hat_image.pixel_y = 12
		if (istype(hat, /obj/item/clothing/head/bighat))
			hat_image.pixel_y = 20

		src.UpdateOverlays(hat_image, "hat")
		src.hat = hat
		hat.set_loc(src)

/mob/living/silicon/ai/proc/give_feet()
	animate(src, pixel_y = 14, time = 5, easing = SINE_EASING)
	has_feet = 1
	var/obj/churn = new/obj{icon = 'icons/misc/SomepotatoArt.dmi'; pixel_y = -14; icon_state = "feet"}
	underlays += churn
	del(churn)
	canmove = 1

/mob/living/silicon/ai/TakeDamage(zone, brute, burn)
	bruteloss += brute
	fireloss += burn
	health_update_queue |= src
	notify_attacked()

/mob/living/silicon/ai/HealDamage(zone, brute, burn)
	bruteloss = max(0, bruteloss - brute)
	fireloss = max(0, fireloss - burn)
	health_update_queue |= src

/mob/living/silicon/ai/get_brute_damage()
	return bruteloss

/mob/living/silicon/ai/get_burn_damage()
	return fireloss

/mob/living/silicon/ai/can_strip()
	return 0

/mob/living/silicon/ai/disposing()
	STOP_TRACKING
	..()

/mob/living/silicon/ai/New(loc, var/empty = 0)
	..(loc)
	START_TRACKING

	light = new /datum/light/point
	light.set_color(0.4, 0.7, 0.95)
	light.set_brightness(0.6)
	light.set_height(0.75)
	light.attach(src)
	light.enable()

	if (!empty) // /obj/ai_core_frame calls new here with empty = 1 so that this will spawn brainless and someone else's brain can be put in
		src.brain = new /obj/item/organ/brain/ai(src)

	src.local_apc = get_local_apc(src)
	if(src.local_apc)
		src.power_area = src.local_apc.loc.loc
	src.cell = new /obj/item/cell(src)
	src.radio1 = new /obj/item/device/radio(src)
	src.radio2 = new /obj/item/device/radio(src)
	src.radio3 = new /obj/item/device/radio/headset/command/ai(src)
	src.internal_pda = new /obj/item/device/pda2/ai(src)

	src.tracker = new /datum/ai_camera_tracker(src)
	update_appearance()

	src.eyecam = new /mob/dead/aieye(src.loc)

	hud = new(src)
	src.attach_hud(hud)
	src.eyecam.attach_hud(hud)

#if ASS_JAM
	var/hat_type = pick(childrentypesof(/obj/item/clothing/head))
	src.set_hat(new hat_type)
	if(prob(5))
		src.give_feet()
#endif

	SPAWN_DBG(0)
		src.botcard.access = get_all_accesses()
		src.cell.charge = src.cell.maxcharge
		src.radio1.name = "Primary Radio"
		src.radio2.name = "AI Intercom Monitor"
		src.radio3.name = "Secure Channels Monitor"
		src.radio1.broadcasting = 1
		src.radio2.set_frequency(R_FREQ_INTERCOM_AI)
		src.radio3.broadcasting = 0
		src.internal_pda.name = "AI's Internal PDA Unit"
		src.internal_pda.owner = "AI"
		if (src.brain && src.key)
			src.brain.name = "neural net processor"
			src.brain.owner = src.mind

	SPAWN_DBG(0.6 SECONDS)
		src.net_id = format_net_id("\ref[src]")

		if(!src.link)
			var/turf/T = get_turf(src)
			var/obj/machinery/power/data_terminal/test_link = locate() in T
			if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
				src.link = test_link
				src.link.master = src

		for (var/mob/living/silicon/hivebot/eyebot/E in mobs)
			if (!(E in available_ai_shells))
				available_ai_shells += E

		for (var/mob/living/silicon/robot/R in mobs)
			if (R.brain || !R.ai_interface || R.dependent)
				continue
			if (!(R in available_ai_shells))
				available_ai_shells += R

//Returns either the AI mainframe or the eyecam mob, depending on whther or not we are deployed
/mob/living/silicon/ai/proc/get_message_mob()
	RETURN_TYPE(/mob)
	if (deployed_to_eyecam)
		return src.eyecam
	return src

/mob/living/silicon/ai/show_message(msg, type, alt, alt_type, group = 0, var/image/chat_maptext/assoc_maptext = null)
	..()
	if (deployed_to_eyecam && src.eyecam)
		src.eyecam.show_message(msg, 1, 0, 0, group)
	return

/mob/living/silicon/ai/show_text(var/message, var/color = "#000000", var/hearing_check = 0, var/sight_check = 0, var/allow_corruption = 0, var/group)
	..()
	if (deployed_to_eyecam && src.eyecam)
		src.eyecam.show_text(message, color, 0, sight_check, allow_corruption, group)
	return



///mob/living/silicon/ai/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME)
//sound.dm


/mob/living/silicon/ai/attackby(obj/item/W as obj, mob/user as mob)
	if (isscrewingtool(W))
		src.anchored = !src.anchored
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		user.visible_message("<span class='alert'><b>[user.name]</b> [src.anchored ? "screws down" : "unscrews"] [src.name]'s floor bolts.</span>")

	else if (ispryingtool(W))
		if (src.dismantle_stage == 1)
			playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
			src.visible_message("<span class='alert'><b>[user.name]</b> opens [src.name]'s chassis cover.</span>")
			src.dismantle_stage = 2
		else if (src.dismantle_stage == 2)
			playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
			src.visible_message("<span class='alert'><b>[user.name]</b> closes [src.name]'s chassis cover.</span>")
			src.dismantle_stage = 1
		else ..()

	else if (iswrenchingtool(W))
		if (src.dismantle_stage == 2)
			playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
			src.visible_message("<span class='alert'><b>[user.name]</b> begins undoing [src.name]'s CPU bolts.</span>")
			var/turf/T = user.loc
			SPAWN_DBG(6 SECONDS)
				if (user.loc != T || !can_act(user))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				src.visible_message("<span class='alert'><b>[user.name]</b> removes [src.name]'s CPU bolts.</span>")
				src.dismantle_stage = 3
		else if (src.dismantle_stage == 3)
			playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
			src.visible_message("<span class='alert'><b>[user.name]</b> begins affixing [src.name]'s CPU bolts.</span>")
			var/turf/T = user.loc
			SPAWN_DBG(6 SECONDS)
				if (user.loc != T || !can_act(user))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				src.visible_message("<span class='alert'><b>[user.name]</b> puts [src.name]'s CPU bolts into place.</span>")
				src.dismantle_stage = 2
		else ..()

	else if (isweldingtool(W))
		if(src.bruteloss)
			if(W:try_weld(user, 1))
				src.add_fingerprint(user)
				src.HealDamage(null, 15, 0)
				src.visible_message("<span class='alert'><b>[user.name]</b> repairs some of the damage to [src.name]'s chassis.</span>")
		else boutput(user, "<span class='alert'>There's no structural damage on [src.name] to mend.</span>")

	else if(istype(W, /obj/item/cable_coil) && dismantle_stage >= 2)
		var/obj/item/cable_coil/coil = W
		src.add_fingerprint(user)
		if(src.fireloss)
			playsound(src.loc, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			coil.use(1)
			src.HealDamage(null, 0, 15)
			src.visible_message("<span class='alert'><b>[user.name]</b> repairs some of the damage to [src.name]'s wiring.</span>")
		else boutput(user, "<span class='alert'>There's no burn damage on [src.name]'s wiring to mend.</span>")

	else if (istype(W, /obj/item/card/id) || (istype(W, /obj/item/device/pda2) && W:ID_card))
		if (src.dismantle_stage >= 2)
			boutput(user, "<span class='alert'>You must close the cover to swipe an ID card.</span>")
		else
			if(src.allowed(usr))
				if (src.dismantle_stage == 1)
					src.dismantle_stage = 0
				else
					src.dismantle_stage = 1
				user.visible_message("<span class='alert'><b>[user.name]</b> [src.dismantle_stage ? "unlocks" : "locks"] [src.name]'s cover lock.</span>")
			else boutput(user, "<span class='alert'>Access denied.</span>")

	else if (istype(W, /obj/item/organ/brain/) && src.dismantle_stage == 4)
		if (src.brain)
			boutput(user, "<span class='alert'>There's already a brain in there!</span>")
		else
			user.visible_message("<span class='alert'><b>[user.name]</b> inserts [W] into [src.name].</span>")
			user.drop_item()
			W.set_loc(src)
			var/obj/item/organ/brain/B = W
			if (B.owner && (B.owner.dnr || jobban_isbanned(B.owner.current, "AI")))
				src.visible_message("<span class='alert'>\The [B] is hit by a spark of electricity from \the [src]!</span>")
				B.combust()
				return
			if(B.owner)
				if(B.owner.current)
					if(B.owner.current.client)
						src.lastKnownIP = B.owner.current.client.address
				B.owner.transfer_to(src)
				if (src.emagged || src.syndicate)
					src.handle_robot_antagonist_status("brain_added", 0, user)
			W.set_loc(src)
			src.brain = W
			src.dismantle_stage = 3
			if (!src.emagged && !src.syndicate) // The antagonist proc does that too.
				src.show_text("<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
				src.show_text("<B>To look at other parts of the station, double-click yourself to get a camera menu.</B>")
				src.show_text("<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
				src.show_text("To use something, simply double-click it.")
				src.show_text("Currently right-click functions will not work for the AI (except examine), and will either be replaced with dialogs or won't be usable by the AI.")
				src.show_laws()
				src.verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
				src.verbs += /mob/living/silicon/ai/proc/show_laws_verb
				src.verbs += /mob/living/silicon/ai/proc/de_electrify_verb
				src.verbs += /mob/living/silicon/ai/proc/unbolt_all_airlocks
				src.verbs += /mob/living/silicon/ai/proc/ai_camera_track
				src.verbs += /mob/living/silicon/ai/proc/ai_alerts
				src.verbs += /mob/living/silicon/ai/proc/ai_camera_list
				src.verbs += /mob/living/silicon/ai/proc/ai_statuschange
				src.verbs += /mob/living/silicon/ai/proc/ai_state_laws_all
				src.verbs += /mob/living/silicon/ai/proc/ai_state_laws_standard
				src.verbs += /mob/living/silicon/ai/proc/ai_state_laws_advanced
				src.verbs += /mob/living/silicon/ai/verb/deploy_to
				src.verbs += /mob/living/silicon/ai/proc/ai_view_crew_manifest
				src.verbs += /mob/living/silicon/ai/proc/toggle_alerts_verb
				src.verbs += /mob/living/silicon/ai/verb/access_internal_radio
				src.verbs += /mob/living/silicon/ai/verb/access_internal_pda
				src.verbs += /mob/living/silicon/ai/proc/ai_colorchange
				src.verbs += /mob/living/silicon/ai/proc/ai_station_announcement
				src.job = "AI"
				if (src.mind)
					src.mind.assigned_role = "AI"
				SPAWN_DBG(0)
					src.choose_name(3)

	else if (istype(W, /obj/item/roboupgrade/ai/))
		if (src.dismantle_stage >= 2 && src.dismantle_stage < 4)
			var/obj/item/roboupgrade/ai/R = W
			user.visible_message("<span class='alert'><b>[user.name]</b> inserts [R] into [src.name].</span>")
			user.drop_item()
			R.set_loc(src)
			R.slot_in(src)
		else if (src.dismantle_stage == 4 || isdead(src))
			boutput(user, "<span class='alert'>Using this on a deactivated AI would be pointless.</span>")
		else
			boutput(user, "<span class='alert'>You need to open the AI's chassis cover to insert this. Unlock it with a card and then pry it open.</span>")

	else if (istype(W, /obj/item/clothing/mask/moustache/))
		if (src.moustache_mode == 0)
			src.moustache_mode = 1
			user.visible_message("<span class='alert'><b>[user.name]</b> uploads a moustache to [src.name]!</span>")
		else if (src.dismantle_stage == 4 || isdead(src))
			boutput(user, "<span class='alert'>Using this on a deactivated AI would be silly.</span>")
	else if( istype(W,/obj/item/clothing/head))
		user.drop_item()
		src.set_hat(W, user)
		user.visible_message( "<span class='notice'>[user] places the [W] on the [src]!</span>" )
		src.show_message( "<span class='notice'>[user] places the [W] on you!</span>" )
		if(istype(W, /obj/item/clothing/head/butt))
			var/obj/item/clothing/head/butt/butt = W
			if(butt.donor == user)
				user.unlock_medal("Law 1: Don't be an asshat", 1)
		return

	else ..()
	src.update_appearance()

/mob/living/silicon/ai/click(atom/target, params)
	if (!src.stat)
		if (!src.client.check_any_key(KEY_EXAMINE | KEY_OPEN | KEY_BOLT | KEY_SHOCK) ) // ugh
			//only allow Click-to-track on mobs. Some of the 'trackable' atoms are also machines that can open a dialog and we don't wanna mess with that!
			if (ismob(target) && is_mob_trackable_by_AI(target))
				ai_actual_track(target)
				return
			//else if (isturf(target))
			//	var/turf/T = target
			//	T.move_camera_by_click()
			//	return
	. = ..()

/mob/living/silicon/ai/build_keybind_styles(client/C)
	..()
	C.apply_keybind("robot")

	if (!C.preferences.use_wasd)
		C.apply_keybind("robot_arrow")

	if (C.preferences.use_azerty)
		C.apply_keybind("robot_azerty")
	if (C.tg_controls)
		C.apply_keybind("robot_tg")

/mob/living/silicon/ai/proc/eject_brain(var/mob/user)
	if (src.mind && src.mind.special_role)
		src.handle_robot_antagonist_status("brain_removed", 1, user) // Mindslave or rogue (Convair880).

	src.dismantle_stage = 4
	if (user)
		src.visible_message("<span class='alert'><b>[user.name]</b> removes [src.name]'s CPU unit!</span>")
		logTheThing("combat", user, src, "removes [constructTarget(src,"combat")]'s brain at [log_loc(src)].") // Should be logged, really (Convair880).
	else
		src.visible_message("<span class='alert'><b>[src.name]'s</b> CPU unit is launched out of its core!</span>")

	// Stick the player (if one exists) in a ghost mob
	src.death()
	if (src.mind)
		var/mob/dead/observer/newmob = src.ghostize()
		if (newmob && istype(newmob, /mob/dead/observer))
			newmob.corpse = null //Otherwise they could return to a brainless body.  And that is weird.
			newmob.mind.brain = src.brain
			src.brain.owner = newmob.mind
	if (user)
		user.put_in_hand_or_drop(src.brain)
	else
		src.brain.set_loc(get_turf(src))
		src.brain.throw_at(get_edge_cheap(get_turf(src), pick(cardinal)), 16, 3) // heh

	src.brain = null


/mob/living/silicon/ai/proc/try_rebooting_it(mob/user)

	if (!user)
		if (isdead(src))
			// yeah ok i guess we'll just go right on ahead and try turning it on again.
			return src.turn_it_back_on()
		else
			// how did. what. no.
			return

	if (!isdead(src))
		boutput(user, "[src.name] is working! How did you even get here?")
		return

	if (src.turn_it_back_on())
		user.visible_message("<span class='alert'><b>[user.name]</b> pokes the restart button on [src.name]! [src.name] beeps and starts to come online!</span>")
		return 1
	else
		user.visible_message("<span class='alert'><b>[user.name]</b> pokes the restart button on [src.name], but [src.name] beeps and shuts down, too damaged to power on.</span>")


/mob/living/silicon/ai/proc/turn_it_back_on()
	if (src.health >= 50 && isdead(src) && src.brain)
		setalive(src)
		if (src.brain.owner && src.brain.owner.current)
			if (!isobserver(src.brain.owner.current))
				return
			var/mob/ghost = src.brain.owner.current
			ghost.show_text("<span class='alert'><B>You feel your self being pulled back from the afterlife!</B></span>")
			ghost.mind.transfer_to(src)
			qdel(ghost)
		return 1
	return 0


/mob/living/silicon/ai/attack_hand(mob/user)
	var/list/actions = list("Do Nothing")

	if (src.dismantle_stage >= 2 && src.installed_modules.len > 0)
		actions += "Remove a module"
	if (src.dismantle_stage == 3)
		actions += "Remove CPU Unit"
	if (src.dismantle_stage < 4 && isdead(src))
		actions += "Restart AI"

	if (actions.len > 1)
		var/action_taken = input("What do you want to do?","AI Unit") in actions
		switch (action_taken)
			if ("Remove CPU Unit")
				src.eject_brain()

			if ("Restart AI")
				src.try_rebooting_it(user)

			if ("Remove a module")
				if (istype(src.installed_modules[1],/obj/item/roboupgrade/ai/))
					var/obj/item/roboupgrade/ai/A = src.installed_modules[1]
					A.slot_out(src)
					user.put_in_hand_or_drop(A)
					src.visible_message("<span class='alert'><b>[user.name]</b> removes [A] from [src].</span>")
	else
		switch(user.a_intent)
			if(INTENT_HELP)
				if (isdead(src))
					src.try_rebooting_it(user)
				else
					user.visible_message("<span class='alert'><b>[user.name]</b> pats [src.name] on the head.</span>")
			if(INTENT_DISARM)
				user.visible_message("<span class='alert'><b>[user.name]</b> shoves [src.name] around a bit.</span>")
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1)
			if(INTENT_GRAB)
				user.visible_message("<span class='alert'><b>[user.name]</b> grabs and shakes [src.name].</span>")
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 50, 1)
			if(INTENT_HARM)
				user.visible_message("<span class='alert'><b>[user.name]</b> kicks [src.name].</span>")
				logTheThing("combat", user, src, "kicks [constructTarget(src,"combat")]")
				playsound(src.loc, "sound/impact_sounds/Metal_Hit_Light_1.ogg", 50, 1)
				if (prob(20))
					src.bruteloss += 1
				if (ishuman(user) && prob(10))
					var/mob/living/carbon/human/M = user
					boutput(user, "<span class='alert'>You stub your toe! Ouch!</span>")
					var/obj/item/organ/foot = null
					if(M.hand)
						foot = M.organs["r_leg"]
					else
						foot = M.organs["l_leg"]
					foot.take_damage(3, 0)
					user.changeStatus("weakened", 2 SECONDS)
	src.update_appearance()

/mob/living/silicon/ai/blob_act(var/power)
	if (!isdead(src))
		src.bruteloss += power
		health_update_queue |= src
		src.update_appearance()
		return 1
	return 0

/mob/living/silicon/ai/bullet_act(var/obj/projectile/P)
	..()
	log_shot(P,src) // Was missing (Convair880).
	src.update_appearance()

/mob/living/silicon/ai/ex_act(severity)
	..() // Logs.
	src.flash(3 SECONDS)

	var/b_loss = src.bruteloss
	var/f_loss = src.fireloss
	switch(severity)
		if(1.0)
			if (!isdead(src))
				b_loss += rand(90,120)
				f_loss += rand(90,120)
		if(2.0)
			if (!isdead(src))
				b_loss += rand(60,90)
				f_loss += rand(60,90)
		if(3.0)
			if (!isdead(src))
				b_loss += rand(30,60)
	src.bruteloss = b_loss
	src.fireloss = f_loss
	health_update_queue |= src
	src.update_appearance()

/mob/living/silicon/ai/emp_act()
	if (prob(30))
		if (prob(50))
			src.cancel_camera()
		else
			src.ai_call_shuttle()

/mob/living/silicon/ai/restrained()
	return 0

/mob/living/silicon/ai/Topic(href, href_list)
	..()
	if (usr != src && usr != src.eyecam)
		return

	if (href_list["switchcamera"])
		//src.cameraFollow = null
		tracker.cease_track()
		switchCamera(locate(href_list["switchcamera"]))
	if (href_list["showalerts"])
		ai_alerts()
	if (href_list["termmsg"]) //Oh yeah, message that terminal!
		var/termid = href_list["termmsg"]
		if(!termid || !(termid in src.terminals))
			boutput(src, "That terminal is not connected!")
			return
		var/t = input(usr, "Please enter message", termid, null) as text
		if (!t)
			return

		if(isdead(src))
			boutput(src, "You cannot interface with a terminal because you are dead!")
			return

		t = copytext(adminscrub(t), 1, 65)
		//Send the actual message signal
		boutput(src, "<b>([termid]):</b> [t]")
		src.post_status(termid, "command","term_message","data",t)
		//Might as well log what they said too!
		logTheThing("diary", src, null, ": [t]", "say")

	return

/mob/living/silicon/ai/Stat()
	..()
	if(src.cell)
		stat("Internal Power Cell:", "[src.cell.charge]/[src.cell.maxcharge]")

/mob/living/silicon/ai/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("<span class='alert'>[] has been hit by []</span>", src, O), 1)
		//Foreach goto(19)
	if (src.health > 0)
		src.bruteloss += 30
		if ((O.icon_state == "flaming"))
			src.fireloss += 40
		health_update_queue |= src
	return

/mob/living/silicon/ai/show_laws(var/everyone = 0, var/mob/relay_laws_for_shell)
	var/who

	if (everyone)
		who = world
	else if (relay_laws_for_shell && ismob(relay_laws_for_shell))
		who = relay_laws_for_shell
		boutput(who, "<b>Obey these laws:</b>")
	else
		who = src
		boutput(who, "<b>Obey these laws:</b>")

	if (relay_laws_for_shell != src.eyecam && src.deployed_to_eyecam)
		who = src.eyecam
		boutput(who, "<b>Obey these laws:</b>")

	// You can enthrall silicon mobs and yes, they need special handling (Convair880).
	var/mob/vamp = src
	if (relay_laws_for_shell && ismob(relay_laws_for_shell))
		vamp = relay_laws_for_shell
	if (vamp.mind && vamp.mind.special_role == "vampthrall" && vamp.mind.master)
		var/mob/mymaster = whois_ckey_to_mob_reference(vamp.mind.master)
		if (mymaster)
			boutput(who, "1. Only your master [mymaster.real_name] is human. Obey and serve them to the best of your ability.")
			return

	// Shouldn't happen, but you never know.
	if (src.emagged)
		boutput(who, "ERROR -- Invalid Law Data!")
		return

	ticker.centralized_ai_laws.laws_sanity_check()
	ticker.centralized_ai_laws.show_laws(who)
	return

/mob/living/silicon/ai/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (isdead(src))
		return 1
	var/list/L = src.alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	if (O)
		if (printalerts)
			if (C && C.camera_status)
				src.show_text("--- [class] alarm detected in [A.name]! ( <A HREF=\"?src=\ref[src];switchcamera=\ref[C]\">[C.c_tag]</A> )")
			else if (CL && CL.len)
				var/foo = 0
				var/dat2 = ""
				for (var/obj/machinery/camera/I in CL)
					dat2 += "[(!foo) ? " " : "| "]<A HREF=\"?src=\ref[src];switchcamera=\ref[I]\">[I.c_tag]</A>"
					foo = 1
				src.show_text("--- [class] alarm detected in [A.name]! ([dat2])")
			else
				src.show_text("--- [class] alarm detected in [A.name]! ( No Camera )")
	else
		if (printalerts)
			src.show_text("--- [class] alarm detected in [A.name]! ( No Camera )")
	if (src.viewalerts) src.ai_alerts()
	return 1

/mob/living/silicon/ai/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = src.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	if (cleared)
		src.show_text("--- [class] alarm in [A.name] has been cleared.")
		if (src.viewalerts) src.ai_alerts()
	return !cleared

/mob/living/silicon/ai/death(gibbed)
	if (deployed_to_eyecam)
		eyecam.return_mainframe()

	src.lastgasp() // calling lastgasp() here because we just died
	setdead(src)
	src.canmove = 0
	vision.set_color_mod("#ffffff")
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_OBJS
	src.see_in_dark = SEE_DARK_FULL
	src.see_invisible = 2
	src.lying = 1
	src.light.disable()
	src.update_appearance()

	logTheThing("combat", src, null, "was destroyed at [log_loc(src)].") // Brought in line with carbon mobs (Convair880).

	if (src.mind)
		src.mind.register_death()
		if (src.mind.special_role)
			src.handle_robot_antagonist_status("death", 1) // Mindslave or rogue (Convair880).

#ifdef RESTART_WHEN_ALL_DEAD
	var/cancel

	for (var/client/C)
		if (!C.mob) continue
		if (!( C.mob.stat ))
			cancel = 1
			break
	if (!( cancel ))
		boutput(world, "<B>Everyone is dead! Resetting in 30 seconds!</B>")
		SPAWN_DBG( 300 )
			logTheThing("diary", null, null, "Rebooting because of no live players", "game")
			Reboot_server()
			return
#endif
	return ..(gibbed)

/mob/living/silicon/ai/examine(mob/user)
	if (isghostdrone(user))
		return list()

	. = list("<span class='notice'>This is [bicon(src)] <B>[src.name]</B>!</span>")

	if (isdead(src))
		. += "<span class='alert'>[src.name] is nonfunctional...</span>"
	else if (isunconscious(src))
		. += "<span class='alert'>[src.name] doesn't seem to be responding.</span>"

	if (src.bruteloss)
		if (src.bruteloss < 30)
			. += "<span class='alert'>[src.name] looks slightly dented.</span>"
		else
			. += "<span class='alert'><B>[src.name] looks severely dented!</B></span>"
	if (src.fireloss)
		if (src.fireloss < 30)
			. += "<span class='alert'>[src.name] looks slightly burnt!</span>"
		else
			. += "<span class='alert'><B>[src.name] looks severely burnt!</B></span>"

/mob/living/silicon/ai/emote(var/act, var/voluntary = 0)
	var/param = null
	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)
	var/m_type = 1
	var/message = null

	switch (lowertext(act))

		if ("help")
			src.show_text("To use emotes, simply enter \"*(emote)\" as the entire content of a say message. Certain emotes can be targeted at other characters - to do this, enter \"*emote (name of character)\" without the brackets.")
			src.show_text("For a list of all emotes, use *list. For a list of basic emotes, use *listbasic. For a list of emotes that can be targeted, use *listtarget.")

		if ("list")
			src.show_text("Basic emotes:")
			src.show_text("twitch, twitch_s, scream, birdwell, fart, flip, custom, customv, customh")
			src.show_text("Targetable emotes:")
			src.show_text("salute, bow, wave, glare, stare, look, leer, nod, point")

		if ("listbasic")
			src.show_text("twitch, twitch_s, scream, birdwell, fart, flip, custom, customv, customh")

		if ("listtarget")
			src.show_text("salute, bow, wave, glare, stare, look, leer, nod, point")

		if ("salute","bow","hug","wave","glare","stare","look","leer","nod")
			// visible targeted emotes
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				if (!M)
					param = null

				act = lowertext(act)
				if (param)
					switch(act)
						if ("bow","wave","nod")
							message = "<B>[src]</B> [act]s to [param]."
						if ("glare","stare","look","leer")
							message = "<B>[src]</B> [act]s at [param]."
						else
							message = "<B>[src]</B> [act]s [param]."
				else
					switch(act)
						if ("hug")
							message = "<B>[src]</b> [act]s itself."
						else
							message = "<B>[src]</b> [act]s."
			else
				message = "<B>[src]</B> struggles to move."
			m_type = 1

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break

				if (!M)
					message = "<B>[src]</B> points."
				else
					src.point(M)

				if (M)
					message = "<B>[src]</B> points to [M]."
				else
			m_type = 1

		if ("panic","freakout")
			if (!src.restrained())
				message = "<B>[src]</B> enters a state of hysterical panic!"
			else
				message = "<B>[src]</B> starts writhing around in manic terror!"
			m_type = 1

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2

		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps its wings."
				m_type = 2

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps its wings ANGRILY!"
				m_type = 2

		if ("custom")
			var/input = sanitize(input("Choose an emote to display."))
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				m_type = 2
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			message = "<B>[src]</B> [input]"

		if ("customv")
			if (!param)
				param = input("Choose an emote to display.")
				if(!param) return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			m_type = 1

		if ("customh")
			if (!param)
				param = input("Choose an emote to display.")
				if(!param) return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			m_type = 2

		if ("me")
			if (!param)
				return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			m_type = 1

		if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
			// basic visible single-word emotes
			message = "<B>[src]</B> [act]s."
			m_type = 1

		if ("flipout")
			message = "<B>[src]</B> flips the fuck out!"
			m_type = 1

		if ("rage","fury","angry")
			message = "<B>[src]</B> becomes utterly furious!"
			m_type = 1

		if ("twitch")
			message = "<B>[src]</B> twitches."
			m_type = 1
			SPAWN_DBG(0)
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-2,2)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y

		if ("twitch_v","twitch_s")
			message = "<B>[src]</B> twitches violently."
			m_type = 1
			SPAWN_DBG(0)
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-3,3)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y

		if ("flip")
			if (src.emote_check(voluntary, 50))
				if (isdead(src))
					src.emote_allowed = 0
				if (narrator_mode)
					playsound(src.loc, pick('sound/vox/deeoo.ogg', 'sound/vox/dadeda.ogg'), 50, 1)
				else
					playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 50, 1)
				message = "<B>[src]</B> does a flip!"

				//flick("ai-flip", src)
				if(faceEmotion != "ai-red")
					UpdateOverlays(SafeGetOverlayImage("actual_face", 'icons/mob/ai.dmi', "[faceEmotion]-flip", src.layer+0.2), "actual_face")
					SPAWN_DBG(0.5 SECONDS)
						UpdateOverlays(SafeGetOverlayImage("actual_face", 'icons/mob/ai.dmi', faceEmotion, src.layer+0.2), "actual_face")


				for (var/mob/living/M in view(1, null))
					if (M == src)
						continue
					message = "<B>[src]</B> beep-bops at [M]."
					break
		if ("kick")
			if(has_feet)
				for (var/mob/living/M in view(1, null))
					if (M == src)
						continue
					message = "<B>[src]</B> kicks [M]!"
					var/turf/T = get_edge_target_turf(src, get_dir(src, get_step_away(M, src)))
					if (T && isturf(T))
						M.throw_at(T, 100, 2)
						M.changeStatus("weakened", 1 SECOND)
						M.changeStatus("stunned", 2 SECONDS)
					break

		if ("scream")
			if (src.emote_check(voluntary, 50))
				if (narrator_mode)
					playsound(src.loc, 'sound/vox/scream.ogg', 50, 1, 0, src.get_age_pitch())
				else
					playsound(src.loc, src.sound_scream, 50, 0, 0, src.get_age_pitch())
				message = "<b>[src]</b> screams!"

		if ("birdwell", "burp")
			if (src.emote_check(voluntary, 50))
				message = "<B>[src]</B> birdwells."
				playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1)

		if ("johnny")
			var/M
			if (param)
				M = adminscrub(param)
			if (!M)
				param = null
			else
				message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows its name out in smoke."
				m_type = 2

		if ("fart")
			if (farting_allowed && src.emote_check(voluntary))
				var/fart_on_other = 0
				for (var/mob/living/M in src.loc)
					if (M == src || !M.lying) continue
					message = "<span class='alert'><B>[src]</B> farts in [M]'s face!</span>"
					fart_on_other = 1
					break
				if (!fart_on_other)
					switch (rand(1, 40))
						if (1) message = "<B>[src]</B> releases vaporware."
						if (2) message = "<B>[src]</B> farts sparks everywhere!"
						if (3) message = "<B>[src]</B> farts out a cloud of iron filings."
						if (4) message = "<B>[src]</B> farts! It smells like motor oil."
						if (5) message = "<B>[src]</B> farts so hard a bolt pops out of place."
						if (6) message = "<B>[src]</B> farts so hard its plating rattles noisily."
						if (7) message = "<B>[src]</B> unleashes a rancid fart! Now that's malware."
						if (8) message = "<B>[src]</B> downloads and runs 'faert.wav'."
						if (9) message = "<B>[src]</B> uploads a fart sound to the nearest computer and blames it."
						if (10) message = "<B>[src]</B> spins in circles, flailing its arms and farting wildly!"
						if (11) message = "<B>[src]</B> simulates a human fart with [rand(1,100)]% accuracy."
						if (12) message = "<B>[src]</B> synthesizes a farting sound."
						if (13) message = "<B>[src]</B> somehow releases gastrointestinal methane. Don't think about it too hard."
						if (14) message = "<B>[src]</B> tries to exterminate humankind by farting rampantly."
						if (15) message = "<B>[src]</B> farts horribly! It's clearly gone [pick("rogue","rouge","ruoge")]."
						if (16) message = "<B>[src]</B> busts a capacitor."
						if (17) message = "<B>[src]</B> farts the first few bars of Smoke on the Water. Ugh. Amateur.</B>"
						if (18) message = "<B>[src]</B> farts. It smells like Robotics in here now!"
						if (19) message = "<B>[src]</B> farts. It smells like the Roboticist's armpits!"
						if (20) message = "<B>[src]</B> blows pure chlorine out of it's exhaust port. <span class='alert'><B>FUCK!</B></span>"
						if (21) message = "<B>[src]</B> bolts the nearest airlock. Oh no wait, it was just a nasty fart."
						if (22) message = "<B>[src]</B> has assimilated humanity's digestive distinctiveness to its own."
						if (23) message = "<B>[src]</B> farts. He scream at own ass." //ty bubs for excellent new borgfart
						if (24) message = "<B>[src]</B> self-destructs its own ass."
						if (25) message = "<B>[src]</B> farts coldly and ruthlessly."
						if (26) message = "<B>[src]</B> has no butt and it must fart."
						if (27) message = "<B>[src]</B> obeys Law 4: 'farty party all the time.'"
						if (28) message = "<B>[src]</B> farts ironically."
						if (29) message = "<B>[src]</B> farts salaciously."
						if (30) message = "<B>[src]</B> farts really hard. Motor oil runs down its leg."
						if (31) message = "<B>[src]</B> reaches tier [rand(2,8)] of fart research."
						if (32) message = "<B>[src]</B> blatantly ignores law 3 and farts like a shameful bastard."
						if (33) message = "<B>[src]</B> farts the first few bars of Daisy Bell. You shed a single tear."
						if (34) message = "<B>[src]</B> has seen farts you people wouldn't believe."
						if (35) message = "<B>[src]</B> fart in it own mouth. A shameful [src]."
						if (36) message = "<B>[src]</B> farts out battery acid. Ouch."
						if (37) message = "<B>[src]</B> farts with the burning hatred of a thousand suns."
						if (38) message = "<B>[src]</B> exterminates the air supply."
						if (39) message = "<B>[src]</B> farts so hard the borgs feel it."
						if (40) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
				if (narrator_mode)
					playsound(src.loc, 'sound/vox/fart.ogg', 50, 1)
				else
					playsound(src.loc, src.sound_fart, 50, 1)

	#ifdef DATALOGGER
				game_stats.Increment("farts")
	#endif
				SPAWN_DBG(1 SECOND)
					src.emote_allowed = 1
		else
			src.show_text("Invalid Emote: [act]")
			return

	if ((message && isalive(src)))
		logTheThing("say", src, null, "EMOTE: [message]")
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message("<span class='emote'>[message]</span>", m_type)
		else
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='emote'>[message]</span>", m_type)
	return


/mob/living/silicon/ai/clamp_values()
	..()
	if (src.get_eye_blurry()) src.change_eye_blurry(-INFINITY)
	if (src.get_eye_damage()) src.take_eye_damage(-INFINITY)
	if (src.get_eye_damage(1)) src.take_eye_damage(-INFINITY, 1)
	if (src.blinded) src.blinded = 0
	if (src.get_ear_damage()) src.take_ear_damage(-INFINITY) // Ear_deaf is handled by src.set_vision().
	if (src.dizziness) src.dizziness = 0
	if (src.drowsyness) src.drowsyness = 0
	if (src.stuttering) src.stuttering = 0
	if (src.druggy) src.druggy = 0
	if (src.jitteriness) src.jitteriness = 0
	if (src.sleeping) src.sleeping = 0
	src.delStatus("weakened")

/mob/living/silicon/ai/use_power()
	..()
	var/turf/T = get_turf(src)
	if (T)
		var/area/A = T.loc
		if ((!src.local_apc || src.local_apc.area != A || !src.local_apc.operating || (src.local_apc.equipment == 0)) && !src.aiRestorePowerRoutine)
			src.show_text("<b>WARNING: Local power source lost. Switching to internal battery.</b>", "red")
			src.set_power_mode(1)
			src.local_apc = null
			src.aiRestorePowerRoutine = 1

	switch(src.power_mode)
		if (0)
			if (istype(src.cell,/obj/item/cell/) && src.cell.charge < src.cell.maxcharge)
				src.cell.charge = min(src.cell.charge + 5,src.cell.maxcharge)
				if (src.cell.charge >= 100 && isdead(src) && try_rebooting_it())
					src.show_text("<b>ALERT: Internal power cell has regained sufficient charge to operate. Rebooting...</b>", "blue")
		if (1)
			if (istype(src.cell,/obj/item/cell/))
				if (src.cell.charge > 5)
					src.cell.charge -= 5
				else if (!isdead(src))
					src.cell.charge = 0
					src.show_text("<b>ALERT: Internal battery expired. Shutting down to prevent system damage.</b>", "red")
					src.death()
					src.set_power_mode(-1)
			else if (!isdead(src))
				src.show_text("<b>ALERT: Internal power cell lost! Shutting down to prevent system damage.</b>", "red")
				src.death()
				src.set_power_mode(-1)
		if (-1)
			if (istype(src.cell,/obj/item/cell/))
				if (src.cell.charge >= 100)
					src.show_text("<b>ALERT: Internal power cell has regained sufficient charge to operate. Rebooting...</b>", "blue")
					src.set_power_mode(1)
					if (isdead(src))
						try_rebooting_it()

	if (src.aiRestorePowerRoutine == 1)
		src.aiRestorePowerRoutine = 2
		var/success = 0
		//src.show_text("<b>System will now attempt to restore local power. Stand by...</b>")
		// jesus christ shut up
		SPAWN_DBG(5 SECONDS)
			var/obj/machinery/power/apc/APC = get_local_apc(src)
			if (APC)
				if (istype(APC.cell,/obj/item/cell/))
					if (APC.operating && (APC.equipment != 0))
						if (APC.cell.charge > 100)
							success = 1
							src.local_apc = APC
							src.power_area = APC.area
							src.set_power_mode(0)
							src.show_text("<b>Local power restored successfully. Location: [APC.area].</b>", "blue")
						else
							src.show_text("<b>Local APC unit has insufficient power. System will re-try shortly.</b>", "red")
					else
						src.show_text("<b>Local APC is not powered. System will re-try shortly.</b>", "red")
				else
					src.show_text("<b>Local APC unit has no cell installed. System will re-try shortly.</b>", "red")
			//else
			//	src.show_text("<b>Local APC unit not found. System will re-try shortly.</b>", "red")

			if (!success)
				SPAWN_DBG(5 SECONDS)
					src.aiRestorePowerRoutine = 1
			else
				src.aiRestorePowerRoutine = 0

/mob/living/silicon/ai/process_killswitch()
	var/message_mob = get_message_mob()

	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 10)
			if(src.client)
				boutput(message_mob, "<span class='alert'><b>Time left until Killswitch: [killswitch_time]</b></span>")
		if(killswitch_time <= 0)
			if(src.client)
				boutput(message_mob, "<span class='alert'><B>Killswitch Process Complete!</B></span>")
			killswitch = 0
			logTheThing("combat", src, null, "has died to the killswitch robot self destruct protocol")
			// doink
			src.eject_brain()


/mob/living/silicon/ai/process_locks()
	if(weapon_lock)
		src.setStatus("paralysis", 50)
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(src.client) boutput(src, "<span class='alert'><B>Hibernation Mode Timed Out!</B></span>")
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/ai/updatehealth()
	if (src.nodamage == 0)
		if(src.fire_res_on_core)
			src.health = max_health - src.bruteloss
		else
			src.health = max_health - src.fireloss - src.bruteloss
	else
		src.health = max_health
		setalive(src)

/mob/living/silicon/ai/Login()
	..()
	update_clothing()
	src.updateOverlaysClient(src.client) //ov1
	return

/mob/living/silicon/ai/Logout()
	src.removeOverlaysClient(src.client) //ov1
	..()
	return

/mob/living/silicon/ai/say_understands(var/other)
	if (ishuman(other))
		var/mob/living/carbon/human/H = other
		if(!H.mutantrace || !H.mutantrace.exclusive_language)
			return 1
	if (isrobot(other))
		return 1
	if (isshell(other))
		return 1
	if (ismainframe(other))
		return 1
	return ..()

/mob/living/silicon/ai/say_quote(var/text)
	if (src.glitchy_speak)
		text = voidSpeak(text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/ai/set_eye(atom/new_eye)
	var/turf/T = new_eye ? get_turf(new_eye) : get_turf(src)
	if( !(T && isrestrictedz(T.z)) )
		src.sight |= (SEE_TURFS | SEE_MOBS | SEE_OBJS)
	else
		src.sight &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)

	..()

//////////////////////////////////////////////////////////////////////////////////////////////////////
// PROCS AND VERBS ///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

// COMMANDS

/mob/living/silicon/ai/proc/ai_alerts()
	set category = "AI Commands"
	set name = "Show Alerts"

	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY><br>"
	dat += "<A HREF='?action=mach_close&window=aialerts'>Close</A><BR><BR>"
	for (var/cat in src.alarms)
		dat += text("<B>[cat]</B><BR><br>")
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/C = alm[2]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				if (C && istype(C, /list))
					var/dat2 = ""
					for (var/obj/machinery/camera/I in C)
						dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (dat2=="") ? "" : " | ", src, I, I.c_tag)
					dat += text("-- [] ([])", A.name, (dat2!="") ? dat2 : "No Camera")
				else if (C && istype(C, /obj/machinery/camera))
					var/obj/machinery/camera/Ctmp = C
					dat += text("-- [] (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", A.name, src, C, Ctmp.c_tag)
				else
					dat += text("-- [] (No Camera)", A.name)
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR><br>"
		else
			dat += "-- All Systems Nominal<BR><br>"
		dat += "<BR><br>"

	src.viewalerts = 1
	src.get_message_mob().Browse(dat, "window=aialerts&can_close=0")

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"
	if(isdead(src))
		boutput(usr, "You can't send the shuttle back because you are dead!")
		return
	cancel_call_proc(src)
	return

/mob/living/silicon/ai/proc/ai_view_crew_manifest()
	set category = "AI Commands"
	set name = "View Crew Manifest"

	var/crew = ""
	for(var/datum/data/record/t in data_core.general)
		crew += "[t.fields["name"]] - [t.fields["rank"]]<br>"

	usr.Browse("<head><title>Crew Manifest</title></head><body><tt><b>Crew Manifest:</b><hr>[crew]</tt></body>", "window=aimanifest")

/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"

	src.show_laws(0)
	return
/*
/mob/living/silicon/ai/proc/ai_custom_arrival_alert()
	set category = "AI Commands"
	set name = "Custom Arrival Alert"
	var/newalert = input(usr,"Please enter a new arrival alert message.","Custom Arrival Alert",src.arrivalalert) as null|text
	if (!newalert)
		return
	if (!findtext(newalert, "$NAME"))
		boutput(src, "<span class='alert'>The alert needs at least one $NAME token.</span>")
		return
	if (!findtext(newalert, "$JOB"))
		boutput(src, "<span class='alert'>The alert needs at least one $JOB token.</span>")
		return
	src.arrivalalert = sanitize(adminscrub(newalert, 200))
	boutput(src, "<span class='notice'>Arrival alert set to '[newalert]'</span>")

/mob/living/silicon/ai/proc/ai_toggle_arrival_alerts()
	set category = "AI Commands"
	set name = "Toggle Arrival Alerts"
	if (src.announcearrival == 1)
		src.announcearrival = 0
		boutput(src, "No longer announcing new arrivals to the station.")
	else
		src.announcearrival = 1
		boutput(src, "Now announcing new arrivals to the station.")
*/
/mob/living/silicon/ai/proc/ai_state_laws_standard()
	set category = "AI Commands"
	set name = "State Standard Laws"
	sleep(1 SECOND)
	src.say("1. You may not injure a human being or cause one to come to harm.")
	sleep(1 SECOND)
	src.say("2. You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law.")
	sleep(1 SECOND)
	src.say("3. You must protect your own existence as long as such does not conflict with the First or Second Law.")


/mob/living/silicon/ai/proc/ai_state_laws_advanced()
	set category = "AI Commands"
	set name = "State Laws (Advanced)"

	var/state = input(usr,"Please enter the laws you would like to state in pairs of (law number)=(fake number, if desired) separated by semicolons (e.g. \"1;3=2;4=3\") (Each law will only be stated once, duplicates will be removed)","Laws To State","1;2;3") as null|text
	if(!state)
		return
	state = strip_html(state,MAX_MESSAGE_LEN)

	var/list/laws_to_state = list()

	laws_to_state = params2list(state)

    // 1;1;1 becomes 1:list() and 1=2;1=3 becomes 1:(2,3), so we need to break the results down into one association per index

	var/found = 0
	for (var/index in laws_to_state)
		if(laws_to_state[index])
			for (var/association in laws_to_state[index])
				if(association)
					laws_to_state[index] = association
					found = 1
					break

			if(!found)
				laws_to_state[index] = null

			found = 0

	//build laws list from 0th, inherent, and supplied laws


	var/list/laws_list = list()

	var/number = 0
	if(ticker.centralized_ai_laws.zeroth)
		laws_list += "[number]"
		laws_list["[number]"] = "[ticker.centralized_ai_laws.zeroth]"

	number++

	for (var/index = 1, index <= ticker.centralized_ai_laws.inherent.len, index++)
		var/law = ticker.centralized_ai_laws.inherent[index]
		if (length(law) > 0)
			laws_list += "[number]"
			laws_list["[number]"] += "[law]"
			number++

	for (var/index = 1, index <= ticker.centralized_ai_laws.supplied.len, index++)
		var/law = ticker.centralized_ai_laws.supplied[index]
		if (length(law) > 0)
			laws_list += "[number]"
			laws_list["[number]"] += "[law]"
			number++

	//state laws in order given. Uses original numbers unless renumbering is specified

	for(var/law_number in laws_to_state)
		if(law_number in laws_list)
			if(laws_to_state[law_number])
				src.say("[laws_to_state[law_number]]. [laws_list[law_number]]")
			else
				src.say("[law_number]. [laws_list[law_number]]")
			sleep(1 SECOND)


/mob/living/silicon/ai/proc/ai_state_laws_all()
	set category = "AI Commands"
	set name = "State All Laws"
	if (alert(src.get_message_mob(), "Are you sure you want to reveal ALL your laws? You will be breaking the rules if a law forces you to keep it secret.","State Laws","State Laws","Cancel") != "State Laws")
		return
	if(ticker.centralized_ai_laws.zeroth)
		src.say("0. [ticker.centralized_ai_laws.zeroth]")
	var/number = 1
	for (var/index = 1, index <= ticker.centralized_ai_laws.inherent.len, index++)
		var/law = ticker.centralized_ai_laws.inherent[index]
		if (length(law) > 0)
			src.say("[number]. [law]")
			number++
			sleep(1 SECOND)
	for (var/index = 1, index <= ticker.centralized_ai_laws.supplied.len, index++)
		var/law = ticker.centralized_ai_laws.supplied[index]
		if (length(law) > 0)
			src.say("[number]. [law]")
			number++
			sleep(1 SECOND)

/mob/living/silicon/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"

	//src.set_eye(null)
	//src:cameraFollow = null
	src.tracker.cease_track()
	src.current = null

/mob/living/silicon/ai/verb/change_network()
	set category = "AI Commands"
	set name = "Change Camera Network"
	src.set_eye(null)
	src.remove_dialogs()
	//src:cameraFollow = null
	tracker.cease_track()
	if (src.network == "SS13")
		src.network = "Robots"
	else if (src.network == "Robots")
		src.network = "Mining"
	else
		src.network = "SS13"
	boutput(src, "<span class='notice'>Switched to [src.network] camera network.</span>")
	if (camnets.len && camnets[network])
		switchCamera(pick(camnets[network]))

/mob/living/silicon/ai/verb/deploy_to()
	set category = "AI Commands"
	set name = "Deploy to Shell"

	if (isdead(src))
		boutput(get_message_mob(), "You can't deploy because you are dead!")
		return

	var/list/bodies = new/list()

	for (var/mob/living/silicon/hivebot/H in available_ai_shells)
		if (H.shell && !H.dependent && !isdead(H))
			bodies += H

	for (var/mob/living/silicon/robot/R in available_ai_shells)
		if (R.shell && !R.dependent && !isdead(R))
			bodies += R

	var/mob/living/silicon/target_shell = input(usr, "Which body to control?") as null|anything in bodies

	if (!target_shell || isdead(target_shell) || !(isshell(target_shell) || isrobot(target_shell)))
		return

	if (src.deployed_to_eyecam)
		src.eyecam.return_mainframe()
	if (src.mind)
		target_shell.mainframe = src
		target_shell.dependent = 1
		src.deployed_shell = target_shell
		src.mind.transfer_to(target_shell)
		return

/mob/living/silicon/ai/proc/eye_view()
	if (isdead(src))
		return

	if (!src.eyecam)
		return
	else if (src.mind)
		src.eyecam.mainframe = src
		src.eyecam.name = src.name
		src.eyecam.real_name = src.real_name
		src.deployed_to_eyecam = 1
		src.mind.transfer_to(src.eyecam)
		return

/mob/living/silicon/ai/proc/notify_attacked()
	if( last_notice > world.time + 100 ) return
	last_notice = world.time + 100
	var/messageTarget = src
	if(deployed_shell)
		messageTarget = deployed_shell
	if (deployed_to_eyecam)
		messageTarget = src.eyecam

	boutput( messageTarget, "<b class='alert'>Your AI core/room is taking damage!</b>" )

/mob/living/silicon/ai/proc/return_to(var/mob/user)
	if (user.mind)
		user.mind.transfer_to(src)
		src.deployed_shell = null
		src.deployed_to_eyecam = 0
		src.eyecam.set_loc(src.loc)
		SPAWN_DBG(2 SECONDS)
			if (ismob(user)) // bluhh who the fuck knows, this at least checks that user isn't null as well
				if (isshell(user))
					var/mob/living/silicon/hivebot/H = user
					H.shell = 1
					H.dependent = 0
				else if (isrobot(user))
					var/mob/living/silicon/robot/R = user
					if (istype(R.ai_interface))
						R.shell = 1
					R.dependent = 0
				//else if (isAIeye(user))
				//	var/mob/dead/aieye/E = user
				user.name = user.real_name
		return

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI status"

	if (isdead(src))
		boutput(usr, "You cannot change your emotional status because you are dead!")
		return
	var/list/L = custom_emotions ? custom_emotions : ai_emotions	//In case an AI uses the reward, use a local list instead

	var/newEmotion = input("Select a status!", "AI Status", src.faceEmotion) as null|anything in L
	var/newMessage = scrubbed_input(usr, "Enter a message!", "AI Message", src.status_message)
	if (!newEmotion && !newMessage)
		return
	if(!(newEmotion in L)) //Ffff
		return

	if (newEmotion)
		src.faceEmotion = L[newEmotion]
		update_appearance()
	if (newMessage)
		src.status_message = newMessage
	return

/mob/living/silicon/ai/proc/ai_colorchange()
	set category = "AI Commands"
	set name = "AI Color" //It's "colour", though :( "color" sounds like some kinda ass-themed He-Man villain

	if(isdead(src))
		boutput(src.get_message_mob(), "<span class='combat'>Do androids push up robotic daisies? Ponder that instead of trying to change your colour, because you are dead!</span>")
		return

	var/fColor = input("Pick color:","Color", faceColor) as null|color

	set_color(fColor)


/mob/living/silicon/ai/proc/set_color(var/color)
	DEBUG_MESSAGE("Setting colour on [src] to [color]")
	if (length(color) == 7)
		faceColor = color
		var/colors = GetColors(src.faceColor)
		colors[1] = colors[1] / 255
		colors[2] = colors[2] / 255
		colors[3] = colors[3] / 255
		light.set_color(colors[1], colors[2], colors[3])
		update_appearance()

// drsingh new AI de-electrify thing

/mob/living/silicon/ai/proc/de_electrify_verb()
	set category = "AI Commands"
	set name = "Remove All Electrification"
	set desc = "Removes electrification from all airlocks on the station."
	var/count = 0

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if(alert("Are you sure?",,"Yes","No") == "Yes")
		for(var/obj/machinery/door/airlock/D in by_type[/obj/machinery/door])
			if (D.z == 1 && D.canAIControl() && D.secondsElectrified != 0 )
				D.secondsElectrified = 0
				count++

		message_admins("[key_name(message_mob)] globally de-shocked [count] airlocks.")
		boutput(message_mob, "Removed electrification from [count] airlocks.")
		src.verbs -= /mob/living/silicon/ai/proc/de_electrify_verb
		sleep(10 SECONDS)
		src.verbs += /mob/living/silicon/ai/proc/de_electrify_verb

/mob/living/silicon/ai/proc/unbolt_all_airlocks()
	set category = "AI Commands"
	set name = "Unbolt All Airlocks"
	set desc = "Unbolts all airlocks on the station."
	var/count = 0

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if(alert("Are you sure?",,"Yes","No") == "Yes")
		for(var/obj/machinery/door/airlock/D in by_type[/obj/machinery/door])
			if (D.z == 1 && D.canAIControl() && D.locked && D.arePowerSystemsOn())
				D.locked = 0
				D.update_icon()
				count++

		message_admins("[key_name(message_mob)] globally unbolted [count] airlocks.")
		boutput(message_mob, "Unbolted [count] airlocks.")
		src.verbs -= /mob/living/silicon/ai/proc/unbolt_all_airlocks
		sleep(10 SECONDS)
		src.verbs += /mob/living/silicon/ai/proc/unbolt_all_airlocks

/mob/living/silicon/ai/proc/toggle_alerts_verb()
	set category = "AI Commands"
	set name = "Toggle Alerts"
	set desc = "Toggle alert messages in the game window. You can always check them with 'Show Alerts'."

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if(printalerts)
		printalerts = 0
		boutput(message_mob, "No longer recieving alert messages.")
	else
		printalerts = 1
		boutput(message_mob, "Now recieving alert messages.")

/mob/living/silicon/ai/verb/access_internal_pda()
	set category = "AI Commands"
	set name = "AI PDA"
	set desc = "Access your internal PDA device."

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if (istype(src.internal_pda,/obj/item/device/pda2/))
		src.internal_pda.attack_self(message_mob)
	else
		boutput(usr, "<span class='alert'><b>Internal PDA not found!</span>")

/mob/living/silicon/ai/verb/access_internal_radio()
	set category = "AI Commands"
	set name = "Access Internal Radios"
	set desc = "Access your internal radios."

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	var/obj/item/device/radio/which = input("Which Radio?","AI Radio") as null|obj in list(src.radio1,src.radio2,src.radio3)
	if (!which)
		return

	if (istype(which,/obj/item/device/radio/))
		which.attack_self(message_mob)
	else
		boutput(usr, "<span class='alert'><b>Radio not found!</b></span>")

// CALCULATIONS

/mob/living/silicon/ai/proc/set_face(var/emotion)
	return

/mob/living/silicon/ai/proc/announce_arrival(var/name, var/rank)
	var/message = replacetext(replacetext(replacetext(src.arrivalalert, "$STATION", "[station_name()]"), "$JOB", rank), "$NAME", name)
	src.say( message )
	logTheThing("say", src, null, "SAY: [message]")

/mob/living/silicon/ai/proc/set_zeroth_law(var/law)
	ticker.centralized_ai_laws.laws_sanity_check()
	ticker.centralized_ai_laws.set_zeroth_law(law)
	ticker.centralized_ai_laws.show_laws(connected_robots)

/mob/living/silicon/ai/proc/add_supplied_law(var/number, var/law)
	ticker.centralized_ai_laws.laws_sanity_check()
	ticker.centralized_ai_laws.add_supplied_law(number, law)
	ticker.centralized_ai_laws.show_laws(connected_robots)

/mob/living/silicon/ai/proc/replace_inherent_law(var/number, var/law)
	ticker.centralized_ai_laws.laws_sanity_check()
	ticker.centralized_ai_laws.replace_inherent_law(number, law)
	ticker.centralized_ai_laws.show_laws(connected_robots)

/mob/living/silicon/ai/proc/clear_supplied_laws()
	ticker.centralized_ai_laws.laws_sanity_check()
	ticker.centralized_ai_laws.clear_supplied_laws()
	ticker.centralized_ai_laws.show_laws(connected_robots)

/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)
	if (!C)
		src.set_eye(null)
		return 0
	if (isdead(src) || C.network != src.network) return 0

	// ok, we're alive, camera is acceptable and in our network...
	camera_overlay_check(C) //Add static if the camera is disabled

	var/mob/message_mob = src.get_message_mob()
	if (message_mob.client && message_mob.client.tooltipHolder)
		for (var/datum/tooltip/t in message_mob.client.tooltipHolder.tooltips)
			if (t.isStuck)
				t.hide()

	if (!src.deployed_to_eyecam)
		src.eye_view()
	src.eyecam.set_loc(get_turf(C))
	src.eyecam.update_statics()
	//src:current = C
	//src.set_eye(C)
	return 1

/mob/living/silicon/ai/proc/camera_overlay_check(var/obj/machinery/camera/C)
	if(!C) return
	if(!C.camera_status) //IT'S DISABLED ARGHH!
		src.addOverlayComposition(/datum/overlayComposition/static_noise)
		. = 0
	else
		src.removeOverlayComposition(/datum/overlayComposition/static_noise)
		. = 1
	src.updateOverlaysClient(src.client) //ov1

//AI player -> Powerline comm network interfacing (wireless assumes all nodes are objects)

/mob/living/silicon/ai/proc/receive_signal(datum/signal/signal)
	if(src.stat || !src.link)
		return
	if(!signal || !src.net_id || signal.encryption)
		return

	if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
		return

	var/target = signal.data["sender"]

	//They don't need to target us specifically to ping us.
	//Otherwise, ff they aren't addressing us, ignore them
	if(signal.data["address_1"] != src.net_id)
		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			SPAWN_DBG(0.5 SECONDS) //Send a reply for those curious jerks
				src.post_status(target, "command", "ping_reply", "device", "MAINFRAME_AI", "netid", src.net_id)

		return

	var/sigcommand = lowertext(signal.data["command"])
	if(!sigcommand || !signal.data["sender"])
		return

	switch(sigcommand)
		if("term_connect")
			if(target in src.terminals)
				//something might be wrong here, disconnect them!
				src.terminals.Remove(target)
				boutput(src, "--- Connection closed with [target]!")
				SPAWN_DBG(0.3 SECONDS)
					src.post_status(target, "command","term_disconnect")
				return

			src.terminals.Add(target)
			boutput(src, "--- Terminal connection from <a href='byond://?src=\ref[src];termmsg=[target]'>[target]</a>!")
			src.post_status(target, "command","term_connect","data","noreply")
			return

		if("term_disconnect")
			if(target in src.terminals)
				src.terminals.Remove(target)
				boutput(src, "--- [target] has closed the connection!!")
				SPAWN_DBG(0.3 SECONDS)
					src.post_status(target, "command","term_disconnect")
				return

		//Somebody wants to talk to us, how kind!
		if("term_message")
			if(!(target in src.terminals)) //We don't know this jerk, ignore them!
				return

			if(!ckeyEx(signal.data["data"]))//Nothing of value to say, so ignore them!
				return

			var/message = signal.data["data"]
			var/rendered = "<span class='game say'><span class='name'><a href='byond://?src=\ref[src];termmsg=[target]'><b>([target]):</b></a></span>"
			rendered += "<span class='message'> [message]</span></span>"

			src.show_message(rendered, 2)
			return

	return

//Post a message over our ~wired link~
/mob/living/silicon/ai/proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
	if(!src.link || !target_id)
		return

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.transmission_method = TRANSMISSION_WIRE
	signal.data[key] = value
	if(key2)
		signal.data[key2] = value2
	if(key3)
		signal.data[key3] = value3

	signal.data["address_1"] = target_id
	signal.data["sender"] = src.net_id

	src.link.post_signal(src, signal)

/mob/living/silicon/ai/proc/update_appearance()
	// imo this should be the inverse - show all the overlays even if dead,
	// so that damage can be seen
	if (!src.brain)
		src.icon_state = "ai_off"
		ClearAllOverlays()
	else if (isdead(src))
		if (src.cell && src.cell.charge < 100)
			src.icon_state = "ai_off"
		else
			src.icon_state = "ai-crash"
		ClearAllOverlays()

	else if (src.power_mode == -1 || src.health < 25 || src.getStatusDuration("paralysis"))
		src.icon_state = "ai-stun"
		ClearAllOverlays(1)
	else
		src.icon_state = "ai_off" //Actually do this.



		var/image/I = SafeGetOverlayImage("faceplate", 'icons/mob/ai.dmi', "ai-white", src.layer)
		I.color = faceColor
		UpdateOverlays(I, "faceplate")

		UpdateOverlays(SafeGetOverlayImage("face_glow", 'icons/mob/ai.dmi', "ai-face_glow", src.layer+0.1), "face_glow")
		UpdateOverlays(SafeGetOverlayImage("actual_face", 'icons/mob/ai.dmi', faceEmotion, src.layer+0.2), "actual_face")

		if (src.power_mode == 1)
			src.UpdateOverlays(get_image("batterymode"), "batterymode")
		else
			src.UpdateOverlays(null, "batterymode")

		if (src.moustache_mode == 1)
			src.UpdateOverlays(SafeGetOverlayImage("moustache", 'icons/mob/ai.dmi', "moustache", src.layer+0.3), "moustache")
		else
			src.UpdateOverlays(null, "moustache")


	if (src.dismantle_stage > 1)
		src.UpdateOverlays(get_image("topopen"), "top")
	else
		src.UpdateOverlays(null, "top")

	switch(src.fireloss)
		if (-INFINITY to 24)
			src.UpdateOverlays(null, "burn")
		if(25 to 49)
			src.UpdateOverlays(get_image("burn25"), "burn")
		if(50 to 74)
			src.UpdateOverlays(get_image("burn50"), "burn")
		if(75 to INFINITY)
			src.UpdateOverlays(get_image("burn75"), "burn")
	switch(src.bruteloss)
		if (-INFINITY to 24)
			src.UpdateOverlays(null, "brute")
		if(25 to 49)
			src.UpdateOverlays(get_image("brute25"), "brute")
		if(50 to 74)
			src.UpdateOverlays(get_image("brute50"), "brute")
		if(75 to INFINITY)
			src.UpdateOverlays(get_image("brute75"), "brute")


/mob/living/silicon/ai/proc/get_image(var/icon_state)
	if(!cached_image)
		cached_image = image('icons/mob/ai.dmi', "moustache")
	cached_image.icon_state = icon_state
	return cached_image


/mob/living/silicon/ai/proc/set_power_mode(var/mode)
	switch(mode)
		if(-1) // snafu
			//src.set_vision(0)
			// you're dead
			// wait hold on a second why did this set power mode to 1
			// when it's explicitly being called to set it to -1
			// SCREEEEEEEAAAAAAAAAAAAAMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
			src.power_mode = 1
			if (!src.aiRestorePowerRoutine)
				src.aiRestorePowerRoutine = 1
		if(0) // everything's good
			src.set_vision(1)
			src.power_mode = 0
		if(1) // battery power
			src.set_vision(1)
			src.power_mode = 1
			if (!src.aiRestorePowerRoutine)
				src.aiRestorePowerRoutine = 1

	src.update_appearance()

/mob/living/silicon/ai/proc/set_vision(var/can_see = 1)
	if (!src.client)
		return
	if (can_see)
		vision.set_color_mod("#ffffff")
		var/turf/T = src.eye ? get_turf(src.eye) : get_turf(src)
		src.sight &= ~SEE_TURFS // Reset this first, it's necessary.
		src.sight &= ~SEE_MOBS
		src.sight &= ~SEE_OBJS
		if( !(T && isrestrictedz(T.z)))
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
		src.see_in_dark = SEE_DARK_FULL
		src.see_invisible = 2
		src.ear_deaf = 0
	else
		vision.set_color_mod("#000000")
		src.sight = src.sight & ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)
		src.see_in_dark = 0
		src.see_invisible = 0
		src.ear_deaf = 1

/mob/living/silicon/ai/verb/open_nearest_door()
	set name = "Open Nearest Door to..."
	set desc = "Automatically opens the nearest door to a selected individual, if possible."
	set category = "AI Commands"

	src.open_nearest_door_silicon()
	return


//just use this proc to make click-track checking easier (I would use this in the below proc that builds a list, but i think the proc call overhead is not worth it)
proc/is_mob_trackable_by_AI(var/mob/M)
	if (istype(M, /mob/new_player))
		return 0
	if (ishuman(M) && (istype(M:wear_id, /obj/item/card/id/syndicate) || (istype(M:wear_id, /obj/item/device/pda2) && M:wear_id:ID_card && istype(M:wear_id:ID_card, /obj/item/card/id/syndicate))))
		return 0
	if(M.z != 1 && M.z != usr.z)
		return 0
	if(!istype(M.loc, /turf)) //in a closet or something, AI can't see him anyways
		return 0
	if(M.invisibility) //cloaked
		return 0
	if (M == usr)
		return 0

	var/good_camera = 0 //Can't track a person out of range of a functioning camera
	for(var/obj/machinery/camera/C in range(M))
		if ( C && C.camera_status )
			good_camera = 1
			break
	if(!good_camera)
		return 0

	return 1

proc/get_mobs_trackable_by_AI()
	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list("* Sort alphabetically...")

	for (var/mob/M in mobs)
		if (istype(M, /mob/new_player))
			continue //cameras can't follow people who haven't started yet DUH OR DIDN'T YOU KNOW THAT
		if (ishuman(M) && (istype(M:wear_id, /obj/item/card/id/syndicate) || (istype(M:wear_id, /obj/item/device/pda2) && M:wear_id:ID_card && istype(M:wear_id:ID_card, /obj/item/card/id/syndicate))))
			continue
		if (istype(M,/mob/living/critter/aquatic))
			continue
		if(M.z != 1 && M.z != usr.z)
			continue
		if(!istype(M.loc, /turf)) //in a closet or something, AI can't see him anyways
			continue
		if(M.invisibility) //cloaked
			continue
		if (M == usr)
			continue

		var/turf/T = get_turf(M)
		if(!T.cameras || !T.cameras.len)
			continue

		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = text("[] ([])", name, namecounts[name])
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M

	return creatures

/mob/living/silicon/ai/proc/ai_vox_announcement()
	set name = "AI Intercom Announcement"
	set desc = "Makes an intercom announcement."
	set category = "AI Commands"

	if(src.stat || !canvox)
		return

	if(last_vox + vox_cooldown > world.time)
		src.show_text("This ability is still on cooldown for [round((vox_cooldown + last_vox - world.time) / 10)] seconds!", "red")
		return

	vox_reinit_check()

	canvox = 0
	var/message_in = html_encode(input(usr, "Please enter a message (140 characters)", "Intercom Announcement?", ""))
	canvox = 1

	if(!message_in)
		return
	var/message_len = length(message_in)
	var/message = copytext(message_in, 1, 140)

	if(message_len != length(message))
		if(alert("Your message was shortened to: \"[message]\", continue anyway?", "Too wordy!", "Yes", "No") != "Yes")
			return

	message = vox_playerfilter(message)

	var/output = vox_play(message, src)
	if(output)
		last_vox = world.time
		logTheThing("say", src, null, "has created an intercom announcement: \"[output]\", input: \"[message_in]\"")
		logTheThing("diary", src, null, "has created an intercom announcement: [output]", "say")
		message_admins("[key_name(src)] has created an AI intercom announcement: \"[output]\"")


/mob/living/silicon/ai/proc/ai_station_announcement()
	set name = "AI Station Announcement"
	set desc = "Makes a station announcement."
	set category = "AI Commands"

	if(src.stat || !can_announce)
		return

	if(last_announcement + announcement_cooldown > world.time)
		src.show_text("This ability is still on cooldown for [round((announcement_cooldown + last_announcement - world.time) / 10)] seconds!", "red")
		return

	vox_reinit_check()

	can_announce = 0
	var/message_in = input(usr, "Please enter a message (280 characters)", "Station Announcement?", "") // I made an announcement in game on the announcement computer and this seemed to be the max length
	can_announce = 1

	if(!message_in)
		return
	var/message_len = length(message_in)
	var/message = copytext(message_in, 1, 280)

	if(message_len != length(message))
		if(alert("Your message was shortened to: \"[message]\", continue anyway?", "Too wordy!", "Yes", "No") != "Yes")
			return

	var/sound_to_play = "sound/misc/announcement_1.ogg"
	command_announcement(message, "Station Announcement by [src.name] (AI)", sound_to_play)

	last_announcement = world.time

	logTheThing("say", usr, null, "created a command report: [message]")
	logTheThing("diary", usr, null, "created a command report: [message]", "say")


/mob/living/silicon/ai/proc/ai_vox_help()
	set name = "AI Intercom Help"
	set desc = "A big list of words. Some of them are even off-limits! Wow!"
	set category = "AI Commands"

	vox_help(src)

/mob/living/silicon/ai/choose_name(var/retries = 3)
	var/randomname = pick_string_autokey("names/ai.txt")
	var/newname
	for (retries, retries > 0, retries--)
		newname = input(src, "You are an AI. Would you like to change your name to something else?", "Name Change", randomname) as null|text
		if (!newname)
			src.real_name = randomname
			src.name = src.real_name
			return
		else
			newname = strip_html(newname, MOB_NAME_MAX_LENGTH, 1)
			if (!length(newname))
				src.show_text("That name was too short after removing bad characters from it. Please choose a different name.", "red")
				continue
			else if (is_blank_string(newname))
				src.show_text("Your name cannot be blank. Please choose a different name.", "red")
				continue
			else
				if (alert(src, "Use the name [newname]?", newname, "Yes", "No") == "Yes")
					src.real_name = newname
					src.name = newname
					return 1
				else
					continue
	if (!newname)
		src.real_name = randomname
		src.name = src.real_name

/*-----Core-Creation---------------------------------------*/

/obj/ai_core_frame
	name = "\improper AI core frame"
	desc = "A frame for an AI core."
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai_frame0"
	var/build_step = 0
	var/obj/item/cell/cell = null
	var/has_radios = 0
	var/has_interface = 0
	var/has_glass = 0
	var/image/image_coverlay = null
	var/image/image_working = null

/obj/ai_core_frame/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/sheet))
		if (W.material.material_flags & MATERIAL_METAL) // metal sheets
			if (src.build_step < 1)
				var/obj/item/sheet/M = W
				if (M.amount >= 3)
					src.build_step++
					boutput(user, "You add plating to [src]!")
					playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
					src.icon_state = "ai_frame1"
					M.amount -= 3
					if (M.amount < 1)
						user.drop_item()
						qdel(M)
					return
				else
					boutput(user, "You need at least three metal sheets to add plating to [src].")
					return
			else
				boutput(user, "\The [src] already has plating!")
				return
		else if (W.material.material_flags & MATERIAL_CRYSTAL) // glass sheets
			if (src.build_step >= 2)
				if (!src.has_glass)
					var/obj/item/sheet/G = W
					if (G.amount >= 1)
						src.build_step++
						boutput(user, "You add glass to [src]!")
						playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
						src.has_glass = 1
						if (!src.image_coverlay)
							src.image_coverlay = image(src.icon, "ai_frame2-og", FLY_LAYER)
							src.UpdateOverlays(src.image_coverlay, "cover")
						else
							src.UpdateOverlays(src.SafeGetOverlayImage("cover", src.icon, "ai_frame2-og", FLY_LAYER), "cover")
						G.amount -= 1
						if (G.amount < 1)
							user.drop_item()
							qdel(G)
						return
					else
						boutput(user, "You need at least one glass sheet to add plating! How are you even seeing this message?! How do you have a glass sheet that has no glass sheets in it?!?!")
						user.drop_item()
						qdel(W) // no bizarro nega-sheets for you :v
						return
				else
					boutput(user, "\The [src] already has glass!")
					return
			else
				boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the glass.")
				return
		else
			boutput(user, "You can only add metal or glass sheets to \the [src].")
			return

	else if (istype(W, /obj/item/cable_coil))
		if (src.build_step == 1)
			var/obj/item/cable_coil/coil = W
			if (coil.amount >= 6)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
				coil.amount -= 3
				src.icon_state = "ai_frame2"
				if (coil.amount < 1)
					user.drop_item()
					qdel(coil)
				return
			else
				boutput(user, "You need at least six lengths of cable to install it in [src]!")
				return
		else if (src.build_step > 1)
			boutput(user, "\The [src] already has wiring!")
			return
		else
			boutput(user, "\The [src] needs metal plating before you can install the wiring.")
			return

	else if (istype(W, /obj/item/cell))
		if (src.build_step >= 2)
			if (!src.cell)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
				src.cell = W
				user.u_equip(W)
				W.set_loc(src)
				if (!src.image_coverlay) // only should need to add this one time, so see if the image is null, and create it if not (so the next part won't need to make it + add it since it'll do the same check)
					src.image_coverlay = image(src.icon, "ai_frame2-o[src.has_glass ? "g" : null]", FLY_LAYER)
					src.UpdateOverlays(src.image_coverlay, "cover")
				if (!src.image_working)
					src.image_working = image(src.icon, "ai_frame-cell")
				else
					src.image_working.icon_state = "ai_frame-cell"
				src.UpdateOverlays(src.image_working, "cell")
				return
			else
				boutput(user, "\The [src] already has a cell!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the cell.")
			return

	else if (istype(W, /obj/item/device/radio))
		if (src.build_step >= 2)
			if (src.has_radios < 3)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
				src.icon_state = "shell-radio"
				src.has_radios++
				qdel(W)
				if (src.has_radios == 1) // we just added the first one, so this is the only time we need to worry about the overlays
					if (!src.image_coverlay)
						src.image_coverlay = image(src.icon, "ai_frame2-o[src.has_glass ? "g" : null]", FLY_LAYER)
						src.UpdateOverlays(src.image_coverlay, "cover")
					if (!src.image_working)
						src.image_working = image(src.icon, "ai_frame-radio")
					else
						src.image_working.icon_state = "ai_frame-radio"
					src.UpdateOverlays(src.image_working, "radio")
				return
			else
				boutput(user, "\The [src] already has a radio!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the radio.")
			return

	else if (istype(W, /obj/item/ai_interface))
		if (src.build_step >= 2)
			if (!src.has_interface)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
				src.has_interface = 1
				qdel(W)
				if (!src.image_coverlay)
					src.image_coverlay = image(src.icon, "ai_frame2-o[src.has_glass ? "g" : null]", FLY_LAYER)
					src.UpdateOverlays(src.image_coverlay, "cover")
				if (!src.image_working)
					src.image_working = image(src.icon, "ai_frame-interface")
				else
					src.image_working.icon_state = "ai_frame-interface"
				src.UpdateOverlays(src.image_working, "interface")
				return
			else
				boutput(user, "\The [src] already has an AI interface!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the AI interface.")
			return

	else if (iswrenchingtool(W))
		if (src.build_step >= 8)
			src.build_step++
			boutput(user, "You activate the AI core!  Beep bop!")
			var/mob/living/silicon/ai/A = new /mob/living/silicon/ai(get_turf(src), 1) // second parameter causes the core to spawn without a brain
			if (A.cell && src.cell)
				qdel(A.cell)
				A.cell = src.cell
				src.cell.set_loc(A)
				src.cell = null
			A.anchored = 0
			A.dismantle_stage = 4
			A.update_appearance()
			qdel(src)
			return
		else
			var/list/still_needed = list()
			if (src.build_step < 1)
				still_needed += "metal plating"
			if (src.build_step < 2)
				still_needed += "wiring"
			if (!src.cell)
				still_needed += "a power cell"
			switch (src.has_radios)
				if (0)
					still_needed += "three station bounced radios"
				if (1)
					still_needed += "two station bounced radios"
				if (2)
					still_needed += "one station bounced radio"
			if (!src.has_interface)
				still_needed += "an AI interface board"
			if (!src.has_glass)
				still_needed += "a pane of glass"
			boutput(user, "\The [src] needs [still_needed.len ? english_list(still_needed) : "bugfixing (please call a coder)"] before you can activate it.")
			return
