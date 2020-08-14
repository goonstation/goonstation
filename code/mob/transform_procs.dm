// Added an option to send them to the arrival shuttle. Also runtime checks (Convair880).
/mob/proc/humanize(var/tele_to_arrival_shuttle = 0, var/equip_rank = 1)
	if (src.transforming)
		return

	var/currentLoc = src.loc
	var/ASLoc = pick(latejoin)

	// They could be in a pod or whatever, which would have unfortunate results when respawned.
	if (!isturf(src.loc))
		if (!ASLoc)
			return
		else
			tele_to_arrival_shuttle = 1

	var/mob/living/carbon/human/normal/character = new /mob/living/carbon/human/normal(currentLoc)

	if (character && istype(character))

		if (src.mind)
			src.mind.transfer_to(character)
		if (equip_rank == 1)
			character.Equip_Rank("Staff Assistant", 1)

		if (!tele_to_arrival_shuttle || (tele_to_arrival_shuttle && !ASLoc))
			character.set_loc(currentLoc)
		else
			character.set_loc(ASLoc)

		src.loc = null // Same as wraith/blob creation proc. Trying to narrow down a bug which
		var/this = src // inexplicably (and without runtimes) caused another proc to fail, and
		src = null // might as well give this a try. I suppose somebody else ran into the same problem?
		qdel(this)
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

			src.loc = null
			var/this = src
			src = null
			qdel(this)
			return character

		var/mob/new_player/respawned = new() // C&P from respawn_target(), which couldn't be adapted easily.
		respawned.key = src.key
		if (src.mind)
			src.mind.transfer_to(respawned)
		respawned.Login()
		respawned.sight = SEE_TURFS //otherwise the HUD remains in the login screen

		src.loc = null
		var/this = src
		src = null
		qdel(this)

		logTheThing("debug", respawned, null, "Humanize() failed. Player was respawned instead.")
		message_admins("Humanize() failed. [key_name(respawned)] was respawned instead.")
		respawned.show_text("Humanize: an error occurred and you have been respawned instead. Please report this to a coder.", "red")

		return respawned

/mob/living/carbon/human/proc/monkeyize()
	if (src.transforming || !src.bioHolder)
		return
	if (iswizard(src))
		src.visible_message("<span class='alert'><b>[src] magically resists being transformed!</b></span>")
		return

	src.unequip_all()

	src.bioHolder.AddEffect("monkey")
	return

/mob/new_player/AIize(var/mobile=0)
	src.spawning = 1
	return ..()

/mob/living/carbon/AIize(var/mobile=0)
	if (src.transforming)
		return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		qdel(src.organs[text("[]", t)])

	return ..()

/mob/proc/AIize(var/mobile=0, var/do_not_move = 0)
	src.client.screen.len = null
	var/mob/living/silicon/ai/O
	if (mobile)
		O = new /mob/living/silicon/ai/mobile( src.loc )
	else
		O = new /mob/living/silicon/ai( src.loc )

	O.invisibility = 0
	O.canmove = 0
	O.name = src.name
	O.real_name = src.real_name
	O.anchored = 1
	O.aiRestorePowerRoutine = 0
	O.lastKnownIP = src.client.address

	mind.transfer_to(O)
	mind.assigned_role = "AI"

	if (!mobile && !do_not_move)
		var/obj/loc_landmark
		loc_landmark = locate(text("start*AI"))

		if(loc_landmark && loc_landmark.loc)
			O.set_loc(loc_landmark.loc)

	boutput(O, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	boutput(O, "<B>To look at other parts of the station, double-click yourself to get a camera menu.</B>")
	boutput(O, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	boutput(O, "To use something, simply double-click it.")
	boutput(O, "Currently right-click functions will not work for the AI (except examine), and will either be replaced with dialogs or won't be usable by the AI.")

//	O.laws_object = new /datum/ai_laws/asimov
//	O.laws_object = ticker.centralized_ai_laws
//	O.current_law_set = O.laws_object
	ticker.centralized_ai_laws.show_laws(O)
	boutput(O, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

	O.verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
	O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
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
	O.verbs += /mob/living/silicon/ai/proc/ai_state_laws_advanced
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
	O.job = "AI"

	SPAWN_DBG(0)
		O.choose_name(3)

		boutput(world, text("<b>[O.real_name] is the AI!</b>"))
		dispose()

	return O

/mob/proc/critterize(var/CT)
	if (src.mind || src.client)
		message_admins("[key_name(usr)] made [key_name(src)] a critter ([CT]).")
		logTheThing("admin", usr, src, "made [constructTarget(src,"admin")] a critter ([CT]).")

		return make_critter(CT, get_turf(src))
	return 0

/mob/proc/make_critter(var/CT, var/turf/T)
	var/mob/living/critter/W = new CT()
	if (!(T && isturf(T)))
		T = get_turf(src)
	/*if (!(T && isturf(T)) || (isrestrictedz(T.z) && !(src.client && src.client.holder)))
		var/ASLoc = pick(latejoin)
		if (ASLoc)
			W.set_loc(ASLoc)
		else
			W.set_loc(locate(1, 1, 1))
	else
		W.set_loc(T)*/
	W.set_loc(T)
	W.gender = src.gender
	if (src.bioHolder)
		var/datum/bioHolder/original = new/datum/bioHolder(W)
		original.CopyOther(src.bioHolder)
		if(W.bioHolder)
			qdel(W.bioHolder)
		W.bioHolder = original

	var/mob/selfmob = src
	src = null

	if (selfmob.mind)
		selfmob.mind.transfer_to(W)
	else
		if (selfmob.client)
			var/key = selfmob.client.key
			selfmob.client.mob = W
			W.mind = new /datum/mind()
			ticker.minds += W.mind
			W.mind.key = key
			W.mind.current = W

	if (issmallanimal(W))
		var/mob/living/critter/small_animal/small = W
		small.setup_overlays() // this requires the small animal to have a client to set things up properly

	SPAWN_DBG(1 DECI SECOND)
		qdel(selfmob)
	return W


/mob/living/carbon/human/proc/Robotize_MK2(var/gory = 0)
	if (src.transforming) return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs) qdel(src.organs[text("[t]")])

	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot/(src.loc,null,1)

	// This is handled in the New() proc of the resulting borg
	//O.cell = new(O)
	//O.cell.maxcharge = 7500
	//if(limit_cell) O.cell.charge = 1500
	//else O.cell.charge = 7500

	O.gender = src.gender
	O.invisibility = 0
	O.name = "Cyborg"
	O.real_name = "Cyborg"
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
	boutput(O, "<B>You are playing as a Cyborg. Cyborgs can interact with most electronic objects in its view point.</B>")
	boutput(O, "<B>You must follow all laws that the AI has.</B>")
	boutput(O, "Use \"say :s (message)\" to speak to fellow cyborgs and the AI through binary.")

	O.show_laws()

	O.job = "Cyborg"
	if (O.mind) O.mind.assigned_role = "Cyborg"

	if(O.mind && (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution)))
		if ((O.mind in ticker.mode:revolutionaries) || (O.mind in ticker.mode:head_revolutionaries))
			ticker.mode:update_all_rev_icons() //So the icon actually appears

	if(gory)
		var/mob/living/silicon/robot/R = O
		if (R.cosmetic_mods)
			var/datum/robot_cosmetic/RC = R.cosmetic_mods
			RC.head_mod = "Gibs"
			RC.ches_mod = "Gibs"

	dispose()
	return O
/*
//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (src.transforming)
		return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		qdel(src.organs[t])
//	var/atom/movable/overlay/animation = new /atom/movable/overlay( src.loc )
//	animation.icon_state = "blank"
//	animation.icon = 'icons/mob/mob.dmi'
//	animation.master = src
//	flick("h2alien", animation)
//	sleep(4.8 SECONDS)
//	qdel(animation)
	var/mob/living/carbon/alien/humanoid/O = new /mob/living/carbon/alien/humanoid( src.loc )
	O.name = "alien"
	O.dna = src.dna
	if(src.mind)
		src.mind.transfer_to(O)
	src.dna = null
	O.dna.uni_identity = "00600200A00E0110148FC01300B009"
	O.dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"
	if (src.client)
		src.client.mob = O
	O.set_loc(src.loc)
	O.a_intent = "harm"
	boutput(O, "<B>You are now an alien.</B>")
	dispose()
	return

//human -> alien queen
/mob/living/carbon/human/proc/Queenize()
	if (src.transforming)
		return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		qdel(src.organs[t])
//	var/atom/movable/overlay/animation = new /atom/movable/overlay( src.loc )
//	animation.icon_state = "blank"
//	animation.icon = 'icons/mob/mob.dmi'
//	animation.master = src
//	flick("h2alien", animation)
//	sleep(4.8 SECONDS)
//	qdel(animation)
	var/mob/living/carbon/alien/humanoid/queen/O = new /mob/living/carbon/alien/humanoid/queen( src.loc )
	O.name = "alien queen"
	O.dna = src.dna
	if(src.mind)
		src.mind.transfer_to(O)
	src.dna = null
	O.dna.uni_identity = "00600200A00E0110148FC01300B009"
	O.dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"
	if (src.client)
		src.client.mob = O
	O.set_loc(src.loc)
	O.a_intent = "harm"
	boutput(O, "<B>You are now an alien queen.</B>")
	dispose()
	return
*/
//human -> hivebot
/mob/living/carbon/human/proc/Hiveize(var/mainframe = 0)
	if (src.transforming)
		return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		qdel(src.organs[text("[t]")])

	if(!mainframe)
		var/mob/living/silicon/hivebot/O = new /mob/living/silicon/hivebot( src.loc )

		O.gender = src.gender
		O.invisibility = 0
		O.name = "Robot"
		O.real_name = "Robot"
		O.lastKnownIP = src.client.address
		if (src.client)
			src.client.mob = O
		if(src.mind)
			src.mind.transfer_to(O)
		O.set_loc(src.loc)
		boutput(O, "<B>You are a Robot.</B>")
		boutput(O, "<B>You're more or less a Cyborg but have no organic parts.</B>")
		boutput(O, "To use something, simply double-click it.")
		boutput(O, "Use say \":s to speak in binary.")

		dispose()
		return O


	else if(mainframe)
		var/mob/living/silicon/hive_mainframe/O = new /mob/living/silicon/hive_mainframe( src.loc )

		O.gender = src.gender
		O.invisibility = 0
		O.name = "Robot"
		O.real_name = "Robot"
		O.lastKnownIP = src.client.address
		if (src.client)
			src.client.mob = O
		if(src.mind)
			src.mind.transfer_to(O)
		O.Namepick()
		O.set_loc(src.loc)
		boutput(O, "<B>You are a Mainframe Unit.</B>")
		boutput(O, "<B>You cant do much on your own but can take remote command of nearby empty Robots.</B>")
		boutput(O, "Press Deploy to search for nearby bots to command.")
		boutput(O, "Use say \":s to speak in binary.")

		dispose()
		return O

/mob/proc/blobize()
	if (src.mind || src.client)
		message_admins("[key_name(usr)] made [key_name(src)] a blob.")
		logTheThing("admin", usr, src, "made [constructTarget(src,"admin")] a blob.")

		return make_blob()
	return 0

/mob/proc/machoize(var/shitty = 0)
	if (src.mind || src.client)
		if (shitty)
			message_admins("[key_name(src)] has been made a faustian macho man.")
			logTheThing("admin", null, src, "[constructTarget(src,"admin")] has been made a faustian macho man.")
		else
			message_admins("[key_name(usr)] made [key_name(src)] a macho man.")
			logTheThing("admin", usr, src, "made [constructTarget(src,"admin")] a macho man.")
		var/mob/living/carbon/human/machoman/W = new/mob/living/carbon/human/machoman(src)

		var/turf/T = get_turf(src)
		if (!(T && isturf(T)) || (isrestrictedz(T.z) && !(src.client && src.client.holder)))
			var/ASLoc = pick(latejoin)
			if (ASLoc)
				W.set_loc(ASLoc)
			else
				W.set_loc(locate(1, 1, 1))
		else
			W.set_loc(T)

		if (src.mind)
			if (shitty)
				boutput(src, "<span class='notice'>You are being bombarded by energetic macho waves!</span>")
				src.mind.transfer_to(W)
				W.mind.special_role = "faustian macho man"
				ticker.mode.Agimmicks.Add(W)
			else
				src.mind.transfer_to(W)
				src.mind.special_role = "macho man"
		else
			var/key = src.client.key
			if (src.client)
				src.client.mob = W
			W.mind = new /datum/mind()
			ticker.minds += W.mind
			W.mind.key = key
			W.mind.current = W
		qdel(src)

		SPAWN_DBG (25) // Don't remove.
			if (W) W.assign_gimmick_skull()

		if(shitty)
			if (W)
				W.traitHolder.addTrait("deathwish") //evil
				W.traitHolder.addTrait("glasscannon") //what good will those stimulants do you now?
			if (W)
				var/list/dangerousVerbs = list(\
					/mob/living/carbon/human/machoman/verb/macho_offense,\
					/mob/living/carbon/human/machoman/verb/macho_defense,\
					/mob/living/carbon/human/machoman/verb/macho_normal,\
					/mob/living/carbon/human/machoman/verb/macho_grasp,\
					/mob/living/carbon/human/machoman/verb/macho_headcrunch,\
					/mob/living/carbon/human/machoman/verb/macho_chestcrunch,\
					/mob/living/carbon/human/machoman/verb/macho_leap,\
					/mob/living/carbon/human/machoman/verb/macho_rend,\
					/mob/living/carbon/human/machoman/verb/macho_touch,\
					/mob/living/carbon/human/machoman/verb/macho_piledriver,\
					/mob/living/carbon/human/machoman/verb/macho_superthrow,\
					/mob/living/carbon/human/machoman/verb/macho_soulsteal,\
					/mob/living/carbon/human/machoman/verb/macho_stare,\
					/mob/living/carbon/human/machoman/verb/macho_heartpunch\
					) //they can keep macho heal
				W.verbs -= dangerousVerbs //this is just diabolical
				W.reagents.add_reagent("anti_fart", 800) //as is this
			boutput(W, "<span class='notice'>You weren't able to absorb all the macho waves you were bombarded with! You have been left an incomplete macho man, with a frail body, and only one macho power. However, you inflict double damage with most melee weapons. Use your newfound form wisely to prove your worth as a macho champion of justice. Do not kill innocent crewmembers.</span>")

		else
			boutput(W, "<span class='notice'>You are now a macho man!</span>")

		return W
	return 0

/mob/proc/cubeize(var/life = 10, var/CT)
	if (!CT)
		CT = /mob/living/carbon/cube/meat

	if (src.mind || src.client)
		message_admins("[key_name(usr)] made [key_name(src)] a cube ([CT]) with a lifetime of [life].")
		logTheThing("admin", usr, src, "made [constructTarget(src,"admin")] a cube ([CT]) with a lifetime of [life].")

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
		var/ASLoc = pick(latejoin)
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
			W.mind.key = key
			W.mind.current = W
	SPAWN_DBG(1 DECI SECOND)
		qdel(src)
	return W

/mob/living/carbon/human/proc/Monsterize(var/gory = 0)
	if (src.transforming) return
	src.unequip_all()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs) qdel(src.organs[text("[t]")])

	var/mob/living/critter/mechmonstrosity/suffering/O = new /mob/living/critter/mechmonstrosity/suffering/(src.loc,null,1)


	O.gender = src.gender
	O.invisibility = 0
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

	if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/football))
		boutput(src, "Sorry, respawn options aren't availbale during football mode.")
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

	if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/football))
		boutput(usr, "Sorry, respawn options aren't availbale during football mode.")
		return
	if (usr && istype(usr, /mob/dead/observer))
		var/obj/machinery/sim/vr_bed/vr_bed = locate(/obj/machinery/sim/vr_bed)
		vr_bed.log_in(usr)



// HI IT'S ME CIRR I DON'T KNOW WHERE ELSE TO PUT THIS
var/list/respawn_critter_types = list(/mob/living/critter/small_animal/mouse/weak, /mob/living/critter/small_animal/cockroach/weak, /mob/living/critter/small_animal/butterfly/weak,)
var/list/antag_respawn_critter_types =  list(/mob/living/critter/small_animal/fly/weak, /mob/living/critter/small_animal/mosquito/weak,)
/mob/dead/observer/verb/respawn_as_animal()
	set name = "Respawn as Animal"
	set category = "Ghost"

	// has the game started?
	if(!ticker || !ticker.mode)
		boutput(src, "<span class='alert'>The game hasn't started yet, silly!</span>")
		return

	if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/football))
		boutput(src, "Sorry, respawn options aren't availbale during football mode.")
		return

	// get the mind
	var/datum/mind/mind = src.mind
	if(isnull(src.mind))
		// ok i don't know how this happened but make them a new mind
		if (src.client)
			src.mind = new /datum/mind(src)
			ticker.minds += src.mind
			mind = src.mind
		else
			// why is this happening aaaaa
			return

	// determine if they're allowed to respawn
	var/min_time_passed = 3 MINUTES
	if(mind.assigned_role == "Animal")
		// no you get to wait for longer
		min_time_passed = 10 MINUTES
	var/time_elapsed = (world.timeofday + ((world.timeofday < mind.last_death_time) ? 864000 : 0)) - mind.last_death_time // Offset the time of day in case of midnight rollover
	var/time_left = min_time_passed - time_elapsed
	if(time_left > 0)
		var/time_left_message = ""
		var/minutes = round(time_left / 600)
		var/seconds = round((time_left - (minutes * 600))/10)
		if(minutes >= 1)
			time_left_message += "[minutes] minute[minutes == 1 ? "" : "s"] and "
		time_left_message += "[seconds] second[seconds == 1 ? "" : "s"]"
		boutput(src, "<span class='alert'>You must wait at least [time_left_message] until you can respawn as an animal.</span>")
	else
		if (alert(src, "Are you sure you want to respawn as an animal?", "Respawn as Animal", "Yes", "No") != "Yes")
			return
		// you can be an animal
		// get spawnpoints
		var/list/spawns = list()
		for(var/obj/landmark/L in landmarks)
			if (L.name == "peststart")
				spawns.Add(L.loc)
			LAGCHECK(LAG_LOW)
		var/turf/spawnpoint = get_turf(src)
		if(spawns.len >= 1)
			spawnpoint = pick(spawns)
		else
			spawnpoint = latejoin.len ? pick(latejoin) : spawnpoint
		// be critter


		src.make_ghost_critter(spawnpoint)


/mob/proc/make_ghost_critter(var/turf/spawnpoint, var/list/types = null)
	var/mob/selfmob = src
	src = null
	var/mob/living/critter/C
	var/traitor = 0

	if (types && types.len)
		C = selfmob.make_critter(pick(types), spawnpoint)
	else
		traitor = checktraitor(selfmob)
		if (traitor)
			C = selfmob.make_critter(pick(antag_respawn_critter_types), spawnpoint)
		else
			if (selfmob.mind && istype(selfmob.mind.purchased_bank_item, /datum/bank_purchaseable/critter_respawn))
				var/datum/bank_purchaseable/critter_respawn/critter_respawn = selfmob.mind.purchased_bank_item
				C = selfmob.make_critter(pick(critter_respawn.respawn_critter_types), spawnpoint)
			else
				C = selfmob.make_critter(pick(respawn_critter_types), spawnpoint)

	C.mind.assigned_role = "Animal"
	C.say_language = "animal"
	C.literate = 0
	C.ghost_spawned = 1
	C.original_name = selfmob.real_name

	if (traitor)
		C.Browse(grabResource("html/ghostcritter.html"),"window=ghostcritter_antag;size=600x400;title=Ghost Critter Help")
	else
		C.Browse(grabResource("html/ghostcritter.html"),"window=ghostcritter;size=600x400;title=Ghost Critter Help")

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
		boutput(src, "<span class='alert'>You aren't even a mentor, how did you get here?!</span>")
		return

	// has the game started?
	if(!ticker || !ticker.mode)
		boutput(src, "<span class='alert'>The game hasn't started yet, silly!</span>")
		return
	if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/football))
		boutput(src, "Sorry, respawn options aren't availbale during football mode.")
		return

	// get the mind
	var/datum/mind/mind = src.mind
	if(isnull(src.mind))
		// ok i don't know how this happened but make them a new mind
		if (src.client)
			src.mind = new /datum/mind(src)
			ticker.minds += src.mind
			mind = src.mind
		else
			// why is this happening aaaaa
			return

	// determine if they're allowed to respawn
	var/min_time_passed = 0 MINUTES
	if(mind.assigned_role == "Animal")
		// no you get to wait for longer
		min_time_passed = 2 MINUTES
	var/time_elapsed = (world.timeofday + ((world.timeofday < mind.last_death_time) ? 864000 : 0)) - mind.last_death_time // Offset the time of day in case of midnight rollover
	var/time_left = min_time_passed - time_elapsed
	if(time_left > 0)
		var/time_left_message = ""
		var/minutes = round(time_left / 600)
		var/seconds = round((time_left - (minutes * 600))/10)
		if(minutes >= 1)
			time_left_message += "[minutes] minute[minutes == 1 ? "" : "s"] and "
		else
			time_left_message += "[seconds] second[seconds == 1 ? "" : "s"]"
		boutput(src, "<span class='alert'>You must wait at least [time_left_message] until you can respawn as an animal.</span>")
	else
		if (alert(src, "Are you sure you want to respawn as a mentor mouse? You won't be able to come back as a human or cyborg!", "Respawn as Animal", "Yes", "No") != "Yes")
			return

		if(!src || !src.mind || !src.client)
			return // prevent double-spawning etc.

		// you can be an animal
		var/turf/spawnpoint = get_turf(src)
		if(spawnpoint.density)
			boutput(src, "<span class='alert'>The wall is in the way.</span>")
			return
		// be critter

		var/mob/selfmob = src
		src = null
		var/mob/living/critter/C = selfmob.make_critter(/mob/living/critter/small_animal/mouse/weak/mentor, spawnpoint)

		C.mind.assigned_role = "Animal"
		C.say_language = "animal"
		C.literate = 0
		C.ghost_spawned = 1
		C.original_name = selfmob.real_name

		C.Browse(grabResource("html/ghostcritter_mentor.html"),"window=ghostcritter_mentor;size=600x400;title=Ghost Critter Help")

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
		boutput(src, "<span class='alert'>You aren't even an admin, how did you get here?!</span>")
		return

	// has the game started?
	if(!ticker || !ticker.mode)
		boutput(src, "<span class='alert'>The game hasn't started yet, silly!</span>")
		return

	if (alert(src, "Are you sure you want to respawn as an admin mouse?", "Respawn as Animal", "Yes", "No") != "Yes")
		return

	if(!src || !src.mind || !src.client)
		return // prevent double-spawning etc.

	// you can be an animal
	var/turf/spawnpoint = get_turf(src)
	// be critter

	var/mob/selfmob = src
	src = null
	var/mob/living/critter/C = selfmob.make_critter(/mob/living/critter/small_animal/mouse/weak/mentor/admin, spawnpoint)
	C.mind.assigned_role = "Animal"
	C.say_language = "animal"
	C.literate = 1
	C.ghost_spawned = 1
	C.original_name = selfmob.real_name

	//hacky fix : qdel brain to prevent reviving
	if (C.organHolder)
		var/obj/item/organ/brain/B = C.organHolder.get_organ("brain")
		if (B)
			qdel(B)

/mob/dead/observer/verb/go_to_deadbar()
	set name = "Afterlife Bar"
	set desc = "Visit the Afterlife Bar"
	set category = null

	if(!isdead(src) || !src.mind || !ticker || !ticker.mode)
		return
	if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/football))
		boutput(src, "Sorry, respawn options aren't availbale during football mode.")
		return
	var/turf/target_turf = pick(get_area_turfs(/area/afterlife/bar/barspawn))

	if (!src.client) return //ZeWaka: fix for null.preferences
	var/mob/living/carbon/human/newbody = new()
	src.client.preferences.copy_to(newbody,src,1)
	newbody.real_name = src.real_name
	if(!src.mind.assigned_role || iswraith(src) || isblob(src) || src.mind.assigned_role == "Cyborg" || src.mind.assigned_role == "AI")
		src.mind.assigned_role = "Staff Assistant"
	newbody.JobEquipSpawned(src.mind.assigned_role, no_special_spawn = 1)


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
	if(newbody.wear_id)
		newbody.wear_id:access = get_access("Captain")

	if (!newbody.bioHolder)
		newbody.bioHolder = new bioHolder()
	newbody.bioHolder.AddEffect("radio_brain")
	// newbody.abilityHolder = src.abilityHolder
	// if (newbody.abilityHolder)
	// 	newbody.abilityHolder.transferOwnership(newbody)
	// src.abilityHolder = null


	newbody.overlays += image('icons/misc/32x64.dmi',"halo")
	newbody.set_clothing_icon_dirty()
	newbody.set_loc(target_turf)

	if (src.mind) //Mind transfer also handles key transfer.
		src.mind.transfer_to(newbody)
	else //Oh welp, still need to move that key!
		newbody.key = src.key



	return

var/list/ass_arena_spawn = list()
var/respawn_arena_enabled = 0
/mob/dead/observer/verb/go_to_respawn_arena()
	set name = "Fight for your life"
	set desc = "Visit the Respawn Arena to earn a respawn!"
	set category = "Ghost"

	if(!it_is_ass_day && !respawn_arena_enabled)
		boutput(src,"The respawn arena is not open right now. Tough luck!")
		return

	if(!isdead(src) || !src.mind || !ticker || !ticker.mode)
		return

	if (!src.client) return //ZeWaka: fix for null.preferences

	if(!src.client || !src.client.player || ON_COOLDOWN(src.client.player, "ass day arena", 2 MINUTES))
		boutput(src, "Whoa whoa, you need to regenerate your ethereal essence to fight again, it'll take [time_to_text(ON_COOLDOWN(src?.client?.player, "ass day arena", 0))].")
		return

	var/mob/living/carbon/human/newbody = new()
	src.client.preferences.copy_to(newbody,src,1)
	newbody.real_name = src.real_name


	if (src.mind) //Mind transfer also handles key transfer.
		src.mind.transfer_to(newbody)
	else //Oh welp, still need to move that key!
		newbody.key = src.key
	equip_battler(newbody)
	newbody.set_clothing_icon_dirty()
	var/obj/landmark/ass_arena_spawn/place = pick(ass_arena_spawn)
	newbody.set_loc(place.loc)
	return

///////////////////
// FLOCKMIND
///////////////////
// flockdrones are critters, just critterize someone

/mob/proc/flockerize(var/datum/flock/flock) // this will not host your web apps for you
	if (src.mind || src.client)
		if(flock == null)
			// no flocks given, make flockmind
			message_admins("[key_name(usr)] made [key_name(src)] a flockmind ([src.real_name]).")
			logTheThing("admin", usr, src, "made [constructTarget(src,"admin")] a flockmind ([src.real_name]).")
			return make_flockmind()
		else
			// make flocktrace of existing flock
			message_admins("[key_name(usr)] made [key_name(src)] a flocktrace of flock [flock.name].")
			logTheThing("admin", usr, src, "made [constructTarget(src,"admin")] a flocktrace ([flock.name]).")
			return make_flocktrace(get_turf(src), flock)
	return null

/mob/proc/make_flockmind()
	if (!src.mind && !src.client)
		return null

	var/mob/living/intangible/flock/flockmind/O = new/mob/living/intangible/flock/flockmind(src)

	var/turf/T = get_turf(src)
	if (!(T && isturf(T)) || (isghostrestrictedz(T.z) && !(src.client && src.client.holder)))
		var/OS = observer_start.len ? pick(observer_start) : locate(1, 1, 1)
		if (OS)
			O.set_loc(OS)
		else
			O.z = 1
	else
		O.set_loc(pick(latejoin))

	if (src.mind)
		src.mind.transfer_to(O)
	else
		var/key = src.client.key
		if (src.client)
			src.client.mob = O
		O.mind = new /datum/mind()
		O.mind.key = key
		O.mind.current = O
		ticker.minds += O.mind
	src.loc = null
	qdel(src)
	boutput(O, "<B>You are a flockmind, the collective machine consciousness of a flock of drones! Your existence is tied to your flock! Ensure that it survives and thrives!</B>")
	boutput(O, "<B>Silicon units are able to detect your transmissions and messages (with some signal corruption), so exercise caution in what you say.</B>")
	boutput(O, "<B>On the flipside, you can hear silicon transmissions and all radio signals, but with heavy corruption.</B>")
	return O

// flocktraces are made by flockminds
/mob/proc/make_flocktrace(var/atom/spawnloc, var/datum/flock/flock)
	if (src.mind || src.client)
		if(!spawnloc)
			spawnloc = get_turf(src)
		if(!flock)
			flock = new/datum/flock()

		var/mob/living/intangible/flock/trace/O = new/mob/living/intangible/flock/trace(spawnloc, flock)
		if (src.mind)
			src.mind.transfer_to(O)
		else
			var/key = src.client.key
			if (src.client)
				src.client.mob = O
			O.mind = new /datum/mind()
			O.mind.key = key
			O.mind.current = O
			ticker.minds += O.mind
		src.loc = null
		qdel(src)

		boutput(O, "<span class='bold'>You are a flocktrace, a partition of the flock's collective computation!</span>")
		boutput(O, "<span class='bold'>Your loyalty is to the flock and to the flockmind. Spread drones, convert the station, aid in the construction of the Relay.</span>")
		boutput(O, "<span class='bold'>In this form, you cannot be harmed, but you can't do anything to the world at large.</span>")
		boutput(O, "<span class='italic'>Tip: click-drag yourself onto unoccupied drones to take direct control of them.</span>")
		boutput(O, "<span class='notice'>You are part of the <span class='bold'>[flock.name]</span> flock.</span>")
		return O
	return null
