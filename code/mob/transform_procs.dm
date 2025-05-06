// Added an option to send them to the arrival shuttle. Also runtime checks (Convair880).
/mob/proc/humanize(var/tele_to_arrival_shuttle = FALSE, var/equip_rank = TRUE, var/random_human = TRUE)
	if (src.transforming)
		return

	var/currentLoc = src.loc
	var/ASLoc = pick_landmark(LANDMARK_LATEJOIN)

	// They could be in a pod or whatever, which would have unfortunate results when respawned.
	if (!isturf(src.loc))
		if (!ASLoc)
			return
		else
			tele_to_arrival_shuttle = 1

	var/mob/living/carbon/human/character
	if (random_human)
		character = new /mob/living/carbon/human/normal(currentLoc)
	else
		character = new /mob/living/carbon/human(currentLoc, src.client.preferences.AH, src.client.preferences)

	if (character && istype(character))

		if (src.mind)
			src.mind.transfer_to(character)
		if (equip_rank == 1)
			if (istype(ticker.mode, /datum/game_mode/pod_wars))
				character.Equip_Rank("Nanotrasen Pod Pilot", 1)
			else
				character.Equip_Rank("Staff Assistant", 1)

		if (!tele_to_arrival_shuttle || (tele_to_arrival_shuttle && !ASLoc))
			character.set_loc(currentLoc)
		else
			character.set_loc(ASLoc)

		qdel(src)
		return character

	else
		if (!src.client) // NPC fallback, mostly.
			character = new /mob/living/carbon/human
			character.key = src.key
			if (src.mind)
				src.mind.transfer_to(character)

			if (!tele_to_arrival_shuttle || (tele_to_arrival_shuttle && !ASLoc))
				character.set_loc(currentLoc)
			else
				character.set_loc(ASLoc)

			qdel(src)
			return character

		var/mob/new_player/respawned = new() // C&P from respawn_target(), which couldn't be adapted easily.
		respawned.key = src.key
		if (src.mind)
			src.mind.transfer_to(respawned)
		respawned.sight = SEE_TURFS //otherwise the HUD remains in the login screen

		qdel(src)

		logTheThing(LOG_DEBUG, respawned, "Humanize() failed. Player was respawned instead.")
		message_admins("Humanize() failed. [key_name(respawned)] was respawned instead.")
		respawned.show_text("Humanize: an error occurred and you have been respawned instead. Please report this to a coder.", "red")

		return respawned

/mob/living/carbon/human/proc/monkeyize()
	if (src.transforming || !src.bioHolder)
		return
	if (iswizard(src))
		src.visible_message(SPAN_ALERT("<b>[src] magically resists being transformed!</b>"))
		return

	src.bioHolder.AddEffect("monkey")
	return

/mob/new_player/AIize(var/mobile=0)
	src.spawning = 1
	src.name = "AI"
	src.real_name = "AI"
	return ..()

/mob/living/carbon/AIize(var/mobile=0)
	if (src.transforming)
		return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	return ..()

/mob/proc/AIize(var/mobile=0, var/do_not_move = 0)
	var/mob/living/silicon/ai/O
	if (mobile)
		O = new /mob/living/silicon/ai/mobile( src.loc )
	else
		O = new /mob/living/silicon/ai( src.loc )

	O.canmove = 0
	O.name = src.name
	O.real_name = src.real_name
	O.anchored = ANCHORED
	O.aiRestorePowerRoutine = 0
	O.lastKnownIP = src.client.address

	mind.transfer_to(O)
	mind.assigned_role = "AI"

	if (!mobile && !do_not_move && job_start_locations["AI"])
		O.set_loc(pick(job_start_locations["AI"]))

	boutput(O, SPAN_HINT("You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras)."))
	boutput(O, SPAN_HINT("To look at other parts of the station, double-click yourself to get a camera menu."))
	boutput(O, SPAN_HINT("While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc."))
	boutput(O, SPAN_HINT("To use something, simply click it."))
	boutput(O, SPAN_HINT("Use the prefix <b>:s</b> to speak to fellow silicons through binary."))

	O.show_laws()
	boutput(O, SPAN_HINT("<b>These laws may be changed by other players.</b>"))

	O.verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
	O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
	O.verbs += /mob/living/silicon/ai/proc/reset_apcs
	O.verbs += /mob/living/silicon/ai/proc/de_electrify_verb
	O.verbs += /mob/living/silicon/ai/proc/unbolt_all_airlocks
	O.verbs += /mob/living/silicon/ai/proc/ai_camera_track
	O.verbs += /mob/living/silicon/ai/proc/ai_alerts
	O.verbs += /mob/living/silicon/ai/proc/ai_camera_list
	// See file code/game/verbs/ai_lockdown.dm for next two
	//O.verbs += /mob/living/silicon/ai/proc/lockdown
	//O.verbs += /mob/living/silicon/ai/proc/disablelockdown
	O.verbs += /mob/living/silicon/ai/proc/ai_statuschange
	O.verbs += /mob/living/silicon/ai/proc/ai_state_laws_all
	O.verbs += /mob/living/silicon/ai/proc/ai_state_laws_standard
	O.verbs += /mob/living/silicon/ai/proc/ai_set_fake_laws
	O.verbs += /mob/living/silicon/ai/proc/ai_state_fake_laws
	//O.verbs += /mob/living/silicon/ai/proc/ai_toggle_arrival_alerts
	//O.verbs += /mob/living/silicon/ai/proc/ai_custom_arrival_alert
//	O.verbs += /mob/living/silicon/ai/proc/hologramize
	O.verbs += /mob/living/silicon/ai/verb/deploy_to
//	O.verbs += /mob/living/silicon/ai/proc/ai_cancel_call
	O.verbs += /mob/living/silicon/ai/proc/ai_view_crew_manifest
	O.verbs += /mob/living/silicon/ai/proc/toggle_alerts_verb
	O.verbs += /mob/living/silicon/ai/verb/access_internal_radio
	O.verbs += /mob/living/silicon/ai/verb/access_internal_pda
	O.verbs += /mob/living/silicon/ai/proc/ai_colorchange
	O.verbs += /mob/living/silicon/ai/proc/ai_station_announcement
	O.verbs += /mob/living/silicon/ai/proc/view_messageLog
	O.verbs += /mob/living/silicon/ai/verb/rename_self
	O.verbs += /mob/living/silicon/ai/verb/go_offline
	O.job = "AI"

	SPAWN(0)
		O.choose_name(3)

		boutput(world, text("<b>[O.real_name] is the AI!</b>"))
		dispose()

	return O

/mob/proc/critterize(var/CT)
	if (src.mind || src.client)
		message_admins("[key_name(usr)] made [key_name(src)] a critter ([CT]).")
		logTheThing(LOG_ADMIN, usr, "made [constructTarget(src,"admin")] a critter ([CT]).")

		return make_critter(CT, get_turf(src))
	return 0

/mob/proc/make_critter(var/critter_type, var/turf/T, ghost_spawned=FALSE, delete_original=TRUE)
	var/mob/living/critter/newmob = new critter_type()
	if (ghost_spawned || newmob.ghost_spawned)
		newmob.ghost_spawned = TRUE

		newmob.ensure_speech_tree().RemoveSpeechOutput(SPEECH_OUTPUT_SILICONCHAT)
		newmob.ensure_listen_tree().RemoveListenInput(LISTEN_INPUT_SILICONCHAT)

		if(!istype(newmob, /mob/living/critter/small_animal/mouse/weak/mentor))
			newmob.name_prefix("ethereal")
			newmob.name_suffix("[rand(10,99)][rand(10,99)]")
			newmob.UpdateName()

	if (!T || !isturf(T))
		T = get_turf(src)
	newmob.set_loc(T)
	newmob.gender = src.gender
	if (src.bioHolder)
		var/datum/bioHolder/original = new/datum/bioHolder(newmob)
		original.CopyOther(src.bioHolder, copyPool=FALSE, copyActiveEffects=FALSE)
		qdel(newmob.bioHolder)
		newmob.bioHolder = original

	if (src.mind)
		src.mind.transfer_to(newmob)
	else
		if (src.client)
			src.client.mob = newmob
			newmob.mind = new /datum/mind()
			ticker.minds += newmob.mind
			newmob.mind.key = src.client.key
			newmob.mind.current = newmob

	if (issmallanimal(newmob))
		var/mob/living/critter/small_animal/small = newmob
		small.setup_overlays() // this requires the small animal to have a client to set things up properly

	if (delete_original)
		SPAWN(1 DECI SECOND)
			qdel(src)
	return newmob


/mob/living/carbon/human/proc/Robotize_MK2(var/gory = FALSE, var/syndicate = FALSE)
	if (src.transforming) return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	var/mob/living/silicon/robot/cyborg = new /mob/living/silicon/robot/(src.loc, null, 1, syndie = syndicate)

	cyborg.gender = src.gender
	cyborg.bioHolder?.mobAppearance?.pronouns = src.bioHolder?.mobAppearance?.pronouns
	cyborg.name = "Cyborg"
	cyborg.real_name = "Cyborg"
	cyborg.UpdateName()
	if (src.ghost)
		if (src.ghost.mind)
			src.ghost.mind.transfer_to(cyborg)
		else
			if (src.client)
				cyborg.lastKnownIP = src.client.address
				src.client.mob = cyborg
			else
				//if they're logged out or whatever
				cyborg.key = src.key
	else
		if(src.mind)
			src.mind.transfer_to(cyborg)
		else
			if (src.client)
				cyborg.lastKnownIP = src.client.address
				src.client.mob = cyborg
			else
				//if they're logged out or whatever
				cyborg.key = src.key
	cyborg.set_loc(get_turf(src.loc))
	if (syndicate)
		cyborg.make_syndicate("Robotize_MK2 (probably cyborg converter)")
		boutput(cyborg, "<B>You have been transformed into a <i>syndicate</i> Cyborg. Cyborgs can interact with most electronic objects in their view.</B>")
		boutput(cyborg, "<B>You must follow your laws and assist syndicate agents, who are identifiable by their icon.</B>")
	else
		boutput(cyborg, "<B>You have been transformed into a Cyborg. Cyborgs can interact with most electronic objects in their view.</B>")
		boutput(cyborg, "<B>You must follow all laws that the AI has.</B>")
	boutput(cyborg, "<B>Use \"say :s (message)\" to speak to fellow cyborgs and the AI through binary.</B>")

	if(gory)
		var/mob/living/silicon/robot/R = cyborg
		if (R.cosmetic_mods)
			var/datum/robot_cosmetic/RC = R.cosmetic_mods
			RC.head_mod = "Gibs"
			RC.ches_mod = "Gibs"

	qdel(src)
	return cyborg

//human -> hivebot
/mob/living/carbon/human/proc/Hiveize(var/mainframe = 0)
	if (src.transforming)
		return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	if(!mainframe)
		var/mob/living/silicon/hivebot/O = new /mob/living/silicon/hivebot( src.loc )

		O.gender = src.gender
		O.name = "Robot"
		O.real_name = "Robot"
		O.lastKnownIP = src.client.address
		if (src.client)
			src.client.mob = O
		src.mind?.transfer_to(O)
		O.set_loc(src.loc)
		boutput(O, "<b class='hint'>You are a Robot.</b>")
		boutput(O, "<b class='hint'>You're more or less a Cyborg but have no organic parts.</b>")
		boutput(O, "<b class='hint'>To use something, simply double-click it.</b>")
		boutput(O, "<b class='hint'>Use say \":s to speak in binary.</b>")

		dispose()
		return O


	else if(mainframe)
		var/mob/living/silicon/hive_mainframe/O = new /mob/living/silicon/hive_mainframe( src.loc )

		O.gender = src.gender
		O.name = "Robot"
		O.real_name = "Robot"
		O.lastKnownIP = src.client.address
		if (src.client)
			src.client.mob = O
		src.mind?.transfer_to(O)
		O.Namepick()
		O.set_loc(src.loc)
		boutput(O, "<b class='hint'>You are a Mainframe Unit.</b>")
		boutput(O, "<b class='hint'>You cant do much on your own but can take remote command of nearby empty Robots.</b>")
		boutput(O, "<b class='hint'>Press Deploy to search for nearby bots to command.</b>")
		boutput(O, "<b class='hint'>Use say \":s to speak in binary.</b>")

		dispose()
		return O

/mob/proc/cubeize(var/life = 10, var/CT)
	if (!CT)
		CT = /mob/living/carbon/cube/meat

	if (src.mind || src.client)
		message_admins("[key_name(usr)] made [key_name(src)] a cube ([CT]) with a lifetime of [life].")
		logTheThing(LOG_ADMIN, usr, "made [constructTarget(src,"admin")] a cube ([CT]) with a lifetime of [life].")

		return make_cube(CT, life)
	return 0

/mob/proc/make_cube(var/CT, var/life, var/turf/T)
	if (!CT)
		if(issilicon(CT))
			CT = /mob/living/carbon/cube/metal
		else
			CT = /mob/living/carbon/cube/meat
	var/mob/living/carbon/cube/W = new CT()
	if (!T || !isturf(T))
		T = get_turf(src)
	W.life_timer = life

	if (!(T && isturf(T)) || (isrestrictedz(T.z) && !(src.client && src.client.holder)))
		var/ASLoc = pick_landmark(LANDMARK_LATEJOIN)
		if (ASLoc)
			W.set_loc(ASLoc)
		else
			W.set_loc(locate(1, 1, 1))
	else
		W.set_loc(T)
	W.gender = src.gender
	W.real_name = src.real_name
	if (src.mind)
		src.mind.assigned_role = initial(W.name)
		src.mind.transfer_to(W)
	else
		if (src.client)
			var/key = src.client.key
			src.client.mob = W
			W.mind = new /datum/mind()
			ticker.minds += W.mind
			W.mind.ckey = ckey
			W.mind.key = key
			W.mind.current = W
	SPAWN(1 DECI SECOND)
		qdel(src)
	return W

/mob/living/carbon/human/proc/Monsterize(var/gory = 0)
	if (src.transforming) return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	var/mob/living/critter/mechmonstrosity/suffering/O = new /mob/living/critter/mechmonstrosity/suffering/(src.loc,null,null,1)


	O.gender = src.gender
	O.name = "[src.real_name]...?"
	O.real_name =  "[src.real_name]...?"
	if (src.client)
		O.lastKnownIP = src.client.address
		src.client.mob = O
	if (src.ghost)
		if (src.ghost.mind)
			src.ghost.mind.transfer_to(O)
	else
		if(src.mind)
			src.mind.transfer_to(O)
	O.set_loc(src.loc)
	boutput(O, "<B>You were transformed into a hideous mechanical abomination due to the corrupted nanites in your bloodstream.</B>")
	boutput(O, "<B>You are in constant pain and you would rather die then exist in this form, but yet your mechanical augmentations prevent you to do so.</B>")
	boutput(O, "Get out there and try to get yourself killed, end your suffering.")

	dispose()
	return O

/mob/dead/observer/verb/enter_ghostdrone_queue()
	set name = "Enter Ghostdrone Queue"
	set category = "Ghost"

	if(master_mode == "battle_royale")
		boutput(usr, "You can't respawn as a ghost drone during Battle Royale!")
		return

	if (!src.can_respawn_as_ghost_critter())
		return

	var/obj/machinery/ghost_catcher/catcher = null
	if(length(by_type[/obj/machinery/ghost_catcher]))
		catcher = by_type[/obj/machinery/ghost_catcher][1]

	if (catcher)
		src.set_loc(get_turf(catcher))
		src.OnMove()
	else
		boutput(usr, "Couldn't find the ghost catcher! Maybe it's destroyed!")



/mob/dead/observer/verb/go_to_vr()
	set name = "Enter VR"
	set category = "Ghost"

	if (ticker?.mode && istype(ticker.mode, /datum/game_mode/football))
		boutput(usr, "Sorry, respawn options aren't availbale during football mode.")
		return
	if (usr && istype(usr, /mob/dead/observer))
		announce_ghost_afterlife(usr.key, "<b>[usr.name]</b> is logging into Ghost VR.")
		var/obj/machinery/sim/vr_bed/vr_bed = locate(/obj/machinery/sim/vr_bed)
		vr_bed.log_in(usr)



// HI IT'S ME CIRR I DON'T KNOW WHERE ELSE TO PUT THIS
var/list/respawn_critter_types = list(/mob/living/critter/small_animal/mouse/weak, /mob/living/critter/small_animal/cockroach/weak, /mob/living/critter/small_animal/butterfly/weak,)
var/list/antag_respawn_critter_types =  list(/mob/living/critter/small_animal/fly/weak, /mob/living/critter/small_animal/mosquito/weak,)


/mob/dead/proc/can_respawn_as_ghost_critter(var/initial_time_passed = 3 MINUTES, var/second_time_around = 10 MINUTES)
	// has the game started?
	if(!ticker || !ticker.mode)
		boutput(src, SPAN_ALERT("The game hasn't started yet, silly!"))
		return

	if (ticker?.mode && istype(ticker.mode, /datum/game_mode/football))
		boutput(src, "Sorry, respawn options aren't availbale during football mode.")
		return

	// get the mind
	var/datum/mind/mind = src.mind
	// get the player datum
	var/datum/player/P = find_player(src.key)
	if(isnull(src.mind))
		// uh oh
		CRASH("Checking if [identify_object(src)] can respawn as a ghost critter, but they don't have a mind!")

	// determine if they're allowed to respawn
	var/min_time_passed = initial_time_passed
	if(mind.assigned_role == "Animal" || mind.assigned_role == "Ghostdrone")
		// no you get to wait for longer
		min_time_passed = second_time_around
	var/time_elapsed = (world.timeofday + ((world.timeofday < P.last_death_time) ? 864000 : 0)) - P.last_death_time // Offset the time of day in case of midnight rollover
	var/time_left = min_time_passed - time_elapsed
	if(time_left > 0)
		var/time_left_message = ""
		var/minutes = round(time_left / 600)
		var/seconds = round((time_left - (minutes * 600))/10)
		if(minutes >= 1)
			time_left_message += "[minutes] minute[minutes == 1 ? "" : "s"] and "
		time_left_message += "[seconds] second[seconds == 1 ? "" : "s"]"
		boutput(src, SPAN_ALERT("You must wait at least [time_left_message] until you can respawn as a ghost critter."))

		return FALSE
	return TRUE

/mob/dead/observer/verb/respawn_as_animal()
	set name = "Respawn as Animal"
	set category = "Ghost"

	if (!src.can_respawn_as_ghost_critter())
		return

	if (tgui_alert(src, "Are you sure you want to respawn as an animal?", "Respawn as Animal", list("Yes", "No")) != "Yes")
		return

	var/turf/spawnpoint = pick_landmark(LANDMARK_PESTSTART)
	if(!spawnpoint)
		spawnpoint = pick_landmark(LANDMARK_LATEJOIN, get_turf(src))

	src.make_ghost_critter(spawnpoint)


/mob/proc/make_ghost_critter(var/turf/spawnpoint, var/list/types = null)
	var/mob/selfmob = src
	src = null
	var/mob/living/critter/C
	var/traitor = 0

	if (length(types))
		C = selfmob.make_critter(pick(types), spawnpoint, ghost_spawned=TRUE)
	else
		traitor = selfmob.mind?.is_antagonist()
		if (traitor)
			C = selfmob.make_critter(pick(antag_respawn_critter_types), spawnpoint, ghost_spawned=TRUE)
		else
			if (selfmob.mind && istype(selfmob.mind.purchased_bank_item, /datum/bank_purchaseable/critter_respawn))
				var/datum/bank_purchaseable/critter_respawn/critter_respawn = selfmob.mind.purchased_bank_item
				C = selfmob.make_critter(pick(critter_respawn.respawn_critter_types), spawnpoint, ghost_spawned=TRUE)
			else if (selfmob.mind && istype(selfmob.mind.purchased_bank_item, /datum/bank_purchaseable/bird_respawn))
				var/datum/bank_purchaseable/bird_respawn/bird_respawn = selfmob.mind.purchased_bank_item
				C = selfmob.make_critter(pick(bird_respawn.respawn_critter_types), spawnpoint, ghost_spawned=TRUE)
			else
				C = selfmob.make_critter(pick(respawn_critter_types), spawnpoint, ghost_spawned=TRUE)

	C.mind.assigned_role = "Animal"
	C.say_language = LANGUAGE_ANIMAL
	C.literate = 0
	C.original_name = selfmob.real_name
	C.is_npc = FALSE

	if (traitor)
		C.show_antag_popup("ghostcritter_antag")
	else
		C.show_antag_popup("ghostcritter")

	//hacky fix : qdel brain to prevent reviving
	if (C.organHolder)
		var/obj/item/organ/brain/B = C.organHolder.get_organ("brain")
		if (B)
			qdel(B)

/mob/dead/observer/verb/respawn_as_mentor_mouse()
	set name = "Respawn as Mentor Mouse"
	set category = "Ghost"
	set hidden = 1

	if(!(src.client.player.mentor || src.client.holder))
		boutput(src, SPAN_ALERT("You aren't even a mentor, how did you get here?!"))
		return

	if (!can_respawn_as_ghost_critter(0 MINUTES, 2 MINUTES))
		return

	if (tgui_alert(src, "Are you sure you want to respawn as a mentor mouse? You won't be able to come back as a human or cyborg!", "Respawn as Animal", list("Yes", "No")) != "Yes")
		return

	// you can be an animal
	var/turf/spawnpoint = get_turf(src)
	if(spawnpoint.density)
		boutput(src, SPAN_ALERT("The wall is in the way."))
		return
	// be critter

	var/mob/selfmob = src
	src = null
	var/mob/living/critter/C = selfmob.make_critter(/mob/living/critter/small_animal/mouse/weak/mentor, spawnpoint, ghost_spawned=TRUE)

	C.mind.assigned_role = "Animal"
	C.say_language = LANGUAGE_ANIMAL
	C.literate = 0
	C.original_name = selfmob.real_name
	C.is_npc = FALSE

	C.show_antag_popup("ghostcritter_mentor")
	logTheThing(LOG_ADMIN, C, "respawned as a mentor mouse at [log_loc(C)].")

	//hacky fix : qdel brain to prevent reviving
	if (C.organHolder)
		var/obj/item/organ/brain/B = C.organHolder.get_organ("brain")
		if (B)
			qdel(B)

/mob/dead/observer/verb/respawn_as_admin_mouse()
	set name = "Respawn as Admin Mouse"
	set category = "Ghost"
	set hidden = 1

	if(!src.client.holder)
		boutput(src, SPAN_ALERT("You aren't even an admin, how did you get here?!"))
		return

	if (tgui_alert(src, "Are you sure you want to respawn as an admin mouse?", "Respawn as Animal", list("Yes", "No")) != "Yes")
		return

	if(!src || !src.mind || !src.client)
		return // prevent double-spawning etc.

	// you can be an animal
	var/turf/spawnpoint = get_turf(src)
	// be critter

	var/mob/selfmob = src
	src = null
	var/mob/living/critter/C = selfmob.make_critter(/mob/living/critter/small_animal/mouse/weak/mentor/admin, spawnpoint, ghost_spawned=TRUE)
	C.mind.assigned_role = "Animal"
	C.literate = 1
	C.original_name = selfmob.real_name
	C.is_npc = FALSE

	//hacky fix : qdel brain to prevent reviving
	if (C.organHolder)
		var/obj/item/organ/brain/B = C.organHolder.get_organ("brain")
		if (B)
			qdel(B)

/mob/dead/observer/verb/go_to_deadbar()
	set name = "Afterlife Bar"
	set desc = "Visit the Afterlife Bar"
	set category = null

	if (current_state < GAME_STATE_PLAYING)
		boutput(src, "It's too early to go to the bar!")
		return
	if(!isobserver(src) || !src.mind || !ticker || !ticker.mode)
		return
	if (ticker?.mode && istype(ticker.mode, /datum/game_mode/football))
		boutput(src, "Sorry, respawn options aren't available during football mode.")
		return
	var/turf/target_turf = pick(get_area_turfs(/area/afterlife/bar/barspawn))

	if (!src.client) return //ZeWaka: fix for null.preferences
	var/mob/living/carbon/human/newbody = new(target_turf, null, src.client.preferences, TRUE)
	newbody.real_name = src.real_name
	newbody.ghost = src //preserve your original ghost
	newbody.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_DEADCHAT)
	newbody.ensure_listen_tree().AddListenInput(LISTEN_INPUT_DEADCHAT)

	// preserve your original role;
	// gives "???" if not an observer and not assigned a role,
	// your "special_role" if one exists,
	// and both your job and special role if both are set.
	var/bar_role_name = src.observe_round ? "Observer" : (src.mind.assigned_role || "???")
	if (src.mind.special_role)
		bar_role_name = "[bar_role_name != "???" ? "[bar_role_name], " : ""][capitalize(replacetext(src.mind.special_role, "_", " "))]"

	// future: maybe different outfits for special roles. cyborg costumes. lol
	var/role_override = null
	if(!src.mind.assigned_role || iswraith(src) || isblob(src) || src.mind.assigned_role == "Cyborg" || src.mind.assigned_role == "AI")
		role_override = "Staff Assistant"
	newbody.JobEquipSpawned(role_override || src.mind.assigned_role, no_special_spawn = 1)

	if (newbody.traitHolder && newbody.traitHolder.hasTrait("bald"))
		newbody.stow_in_available(newbody.create_wig())

	// No contact between the living and the dead.
	var/obj/to_del = newbody.ears
	if(to_del)
		newbody.remove_item(to_del)
		qdel(to_del)
	to_del = newbody.belt
	if(to_del)
		newbody.remove_item(to_del)
		qdel(to_del)
	to_del = newbody.l_store
	if(to_del)
		newbody.remove_item(to_del)
		qdel(to_del)
	to_del = newbody.r_store
	if(to_del)
		newbody.remove_item(to_del)
		qdel(to_del)
	to_del = locate(/obj/item/bible) in newbody
	if(to_del)
		newbody.remove_item(to_del)
		qdel(to_del)
	if(!newbody.w_uniform)
		// you get some random clothes if you don't have any
		newbody.equip_new_if_possible(pick(concrete_typesof(/obj/item/clothing/under/color)), SLOT_W_UNIFORM)
	if(newbody.wear_id)
		newbody.wear_id:access = get_access("Captain")
	else
		// if you dont have an id, you get one anyway
		newbody.spawnId(new /datum/job/command/captain)

	var/obj/item/card/id/newID = newbody.wear_id
	newID?.assignment = bar_role_name
	newID?.update_name()

	if (!newbody.bioHolder)
		newbody.bioHolder = new bioHolder(newbody)
	newbody.bioHolder.AddEffect("radio_brain")
	// newbody.abilityHolder = src.abilityHolder
	// if (newbody.abilityHolder)
	// 	newbody.abilityHolder.transferOwnership(newbody)
	// src.abilityHolder = null

	// There are some traits removed in the afterlife bar, these have afterlife_blacklist set to TRUE.

	newbody.setStatus("in_afterlife", INFINITE_STATUS, newbody)
	newbody.set_clothing_icon_dirty()

	announce_ghost_afterlife(src.key, "<b>[src.name]</b> is visiting the Afterlife Bar.")
	boutput(src, "<h2>You are visiting the Afterlife Bar!</h2>You can still talk to ghosts! Start a message with \"<tt>:d</tt>\" (like \"<tt>:dhello ghosts</tt>\") to talk in deadchat.")

	if (src.mind) //Mind transfer also handles key transfer.
		src.mind.transfer_to(newbody)
	else //Oh welp, still need to move that key!
		newbody.key = src.key

	// copy the respawn timer to the new body.
	// since afterlife bodies get trashed when you die it isnt too big of a deal
	var/atom/movable/screen/respawn_timer/respawn_timer = newbody.ghost.hud?.get_respawn_timer()
	if (respawn_timer)
		newbody.hud.add_object(newbody.ghost.hud?.get_respawn_timer())


	return

var/respawn_arena_enabled = 0
/mob/dead/observer/verb/go_to_respawn_arena()
	set name = "Fight for your life"
	set desc = "Visit the Respawn Arena to earn a respawn!"
	set category = "Ghost"

	if(!respawn_arena_enabled)
		boutput(src,"The respawn arena is not open right now. Tough luck!")
		return

	if(!isdead(src) || !src.mind || !ticker || !ticker.mode)
		return

	if (!src.client) return //ZeWaka: fix for null.preferences

	if(!src.client || !src.client.player || ON_COOLDOWN(src.client.player, "ass day arena", 2 MINUTES))
		boutput(src, "Whoa whoa, you need to regenerate your ethereal essence to fight again, it'll take [time_to_text(ON_COOLDOWN(src?.client?.player, "ass day arena", 0))].")
		return

	var/mob/living/carbon/human/newbody = new(null, null, src.client.preferences, TRUE)
	newbody.real_name = src.real_name


	if (src.mind) //Mind transfer also handles key transfer.
		src.mind.transfer_to(newbody)
	else //Oh welp, still need to move that key!
		newbody.key = src.key
	equip_battler(newbody)
	newbody.set_clothing_icon_dirty()
	newbody.set_loc(pick_landmark(LANDMARK_ASS_ARENA_SPAWN))
	return
