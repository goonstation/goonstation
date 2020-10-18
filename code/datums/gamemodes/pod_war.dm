/datum/game_mode/pod_war
	name = "pod war"

	votable = 1
	probability = 0 // Overridden by the server config. If you don't have access to that repo, keep it 0.
	crew_shortage_enabled = 1

	shuttle_available = 0 // 0: Won't dock. | 1: Normal. | 2: Won't dock if called too early.
	list/latejoin_antag_roles = list() // Unrecognized roles default to traitor in mob/new_player/proc/makebad().
	do_antag_random_spawns = 0
	var/list/frequencies_used = list()

	var/list/commanders = list()

	var/datum/pod_war_team/team_NT
	var/datum/pod_war_team/team_SY



/datum/game_mode/pod_war/announce()
	boutput(world, "<B>The current game mode is - Pod War!</B>")
	boutput(world, "<B>Two starships of similar technology and crew compliment warped into the same asteroid field!</B>")
	boutput(world, "<B>Mine materials, build pods, kill enemies, destroy the enemy mothership!</B>")

//setup teams and commanders
/datum/game_mode/pod_war/pre_setup()
	if (!setup_teams())
		return 0


	return 1



/datum/game_mode/pod_war/proc/setup_teams()
	if (!islist(commanders) || commanders.len != 2)
		return 0
	team_NT = new/datum/pod_war_team(mode = src, team = 1)
	team_SY = new/datum/pod_war_team(mode = src, team = 2)

	//get all ready players and split em into two equal teams,
	var/list/readied_minds = list()
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue
		if (player.ready && player.mind)
			readied_minds += player.mind

	if (islist(readied_minds))
		var/length = length(readied_minds)
		shuffle_list(readied_minds)
		if (length < 2)
			if (prob(50))
				team_NT.accept_players(readied_minds)
			else
				team_SY.accept_players(readied_minds)

		else
			var/half = round(length/2)
			team_NT.accept_players(readied_minds.Copy(1, half))
			team_SY.accept_players(readied_minds.Copy(half+1, length))





/datum/game_mode/pod_war/post_setup()
	// for (var/datum/mind/leaderMind in commanders)
	// 	if (!leaderMind.current)
	// 		continue

	// 	create_team(leaderMind)
	// 	bestow_objective(leaderMind,/datum/objective/specialist/pod_war)
	// 	boutput(leaderMind.current, "<h1><font color=red>You are the Commander of your starship! Organize your crew fight for survival!</font></h1>")
	// 	equip_commander(leaderMind.current)

	//Create teams
	//Setup critical systems for each starship.

	return 1

//Give em their special jacket. and their visible hud icon
/datum/game_mode/gang/proc/equip_commander(mob/living/carbon/human/leader)
	if(leader.ears != null && istype(leader.ears,/obj/item/device/radio/headset))
		// var/obj/item/device/radio/headset/H = leader.ears
		// H.set_secure_frequency("g",leader.mind.gang.comms_frequency)
		// H.secure_classes["g"] = RADIOCL_SYNDICATE
		boutput(leader, "Your headset has been tuned to your crew's frequency. Prefix a message with :g to communicate on this channel.")

	return

/datum/game_mode/pod_war/check_finished()


 return 0

/datum/game_mode/pod_war/process()
	..()

/datum/game_mode/pod_war/declare_completion()

	// var/text = ""

	boutput(world, "<FONT size = 2><B>The ship commanders were: </B></FONT><br>")
	// for(var/datum/mind/leader_mind in commanders)

	..() // Admin-assigned antagonists or whatever.


#define TEAM_NANOTRASEN 1
#define TEAM_SYNDICATE 2
/datum/pod_war_team
	var/name = "NanoTrasen Crew"
	var/comms_frequency = 0
	var/area/base = null		//base ship area
	var/datum/mind/commander = null
	var/list/members = list()
	var/team_num = 0

	var/points = 50
	var/list/mcguffins

	New(var/datum/game_mode/pod_war/mode, team)
		src.team_num = team
		if (team_num == TEAM_NANOTRASEN)
			name = "NanoTrasen Crew"
			base = null //area south crew
		else if (team_num == TEAM_SYNDICATE)
			name = "Syndicate Crew"
			base = null //area north crew

		set_comms(mode)



		//stolen from gang, works well enough, I don't care to make better. - kyle
	proc/set_comms(var/datum/game_mode/pod_war/mode)
		comms_frequency = rand(1360,1420)

		while(comms_frequency in mode.frequencies_used)
			comms_frequency = rand(1360,1420)

		mode.frequencies_used += comms_frequency


	proc/accept_players(var/list/players)
		members = players
		select_commander()

		for (var/datum/mind/M in players)
			equip_player(M)
			//commander gets a couple extra things...
			if (M == commander)
				equip_commander(M)

	proc/select_commander()
		var/list/possible_commanders = get_possible_commanders()
		if (isnull(possible_commanders) || !possible_commanders.len)
			return 0

		var/datum/mind/commander = pick(possible_commanders)
		commander.special_role = "commander"

//Really stolen from gang, But this basically just picks everyone who is ready and not hellbanned or jobbanned from Command or Captain
	proc/get_possible_commanders()
		var/list/candidates = list()
		for(var/datum/mind/mind in members)
			var/mob/new_player/M = mind.current
			if (!istype(M)) continue
			if (ishellbanned(M)) continue
			if(jobban_isbanned(M, "Captain")) continue //If you can't captain a Space Station, you probably can't command a starship either...
			if ((M.ready) && !candidates.Find(M.mind))
				candidates += M.mind

		if(candidates.len < 1)
			return null
		else
			return candidates

	proc/equip_commander(var/datum/mind/mind)
		var/mob/living/carbon/human/H = mind.current
		if (team_num == TEAM_NANOTRASEN)
			H.equip_if_possible(new /obj/item/clothing/head/centhat(H), H.slot_l_store)
			// H.equip_if_possible(new /obj/item/clothing/head/centhat(H), H.slot_r_store)
		if (team_num == TEAM_SYNDICATE)
			H.equip_if_possible(new /obj/item/clothing/head/bighat/syndicate(H), H.slot_l_store)
			// H.equip_if_possible(new /obj/item/clothing/head/bighat/syndicate(H), H.slot_r_store)


	proc/equip_player(var/datum/mind/mind)
		var/mob/living/carbon/human/H = mind.current

		if (istype(mind.current, /mob/new_player))
			var/mob/new_player/N = mind.current
			N.mind.assigned_role = name
			H = N.create_character(new /datum/job/pod_pilot)

		if (!ishuman(H))
			boutput(H, "something went wrong. Horribly wrong.")
			return

		// SHOW_TIPS(H)

		H.mind.special_role = name

		H.equip_if_possible(new /obj/item/device/radio/headset(H), H.slot_ears)

		var/obj/item/card/id/captains_spare/I = new /obj/item/card/id/captains_spare(H) // for whatever reason, this is neccessary
		I.registered = "[H.name]"
		I.icon = 'icons/obj/items/card.dmi'
		I.icon_state = "fingerprint0"
		I.desc = "An ID card to help open doors and identify your body."

		if (team_num == TEAM_NANOTRASEN)
			I.name = "NT Pilot"
			I.assignment = "NT Pilot"
			I.color = "#0000ff"
			H.equip_if_possible(new /obj/item/clothing/under/misc/turds(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/gloves/swat/NT(H), H.slot_gloves)
			H.equip_if_possible(new /obj/item/clothing/mask/breath(H), H.slot_wear_mask)
			H.equip_if_possible(new /obj/item/clothing/head/helmet/space/ntso(H), H.slot_head)
			H.equip_if_possible(new /obj/item/storage/backpack/NT(H), H.slot_back)
			H.equip_if_possible(new /obj/item/device/radio/headset(H), H.slot_ears)


		else if (team_num == TEAM_SYNDICATE)
			I.name = "Syndicate Pilot"
			I.assignment = "Syndicate Pilot"
			I.color = "#ff0000"
			H.equip_if_possible(new /obj/item/clothing/under/misc/syndicate(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/gloves/swat(H), H.slot_gloves)
			H.equip_if_possible(new /obj/item/clothing/mask/breath(H), H.slot_wear_mask)
			H.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/specialist(H), H.slot_head)
			H.equip_if_possible(new /obj/item/storage/backpack/syndie(H), H.slot_back)
			H.equip_if_possible(new /obj/item/device/radio/headset(H), H.slot_ears)

		H.equip_if_possible(new /obj/item/clothing/shoes/swat(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/gun/energy/phaser_gun/self_charging(H), H.slot_belt)

		H.equip_if_possible(I, H.slot_wear_id)
		H.set_clothing_icon_dirty()
		// H.set_loc(pick(pod_pilot_spawns[team_num]))
		boutput(H, "You're in the [name] faction! Mine materials, build pods, defend your space station, destroy the enemy space station!")
