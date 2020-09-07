/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list("changeling")

	var/const/changelings_possible = 4

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/changeling/announce()
	boutput(world, "<B>The current game mode is - Changeling!</B>")
	boutput(world, "<B>There is a <span class='alert'>CHANGELING</span> on the station. Be on your guard! Trust no one!</B>")

/datum/game_mode/changeling/pre_setup()
	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if(player.ready)
			num_players++

	var/i = rand(5)
	var/num_changelings = max(1, min(round((num_players + i) / 15), changelings_possible))

	var/list/possible_changelings = get_possible_changelings(num_changelings)

	if (!possible_changelings.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		src.traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing("admin", tplayer.current, null, "successfully redeems an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeems an antag token.")
		//num_changelings = max(0, num_changelings - 1)

	var/list/chosen_changelings = antagWeighter.choose(pool = possible_changelings, role = "changeling", amount = num_changelings, recordChosen = 1)
	traitors |= chosen_changelings
	for (var/datum/mind/changeling in traitors)
		changeling.special_role = "changeling"
		possible_changelings.Remove(changeling)

	return 1

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in src.traitors)
		if(istype(changeling))
			changeling.current.make_changeling()
			bestow_objective(changeling,/datum/objective/specialist/absorb)
			bestow_objective(changeling,/datum/objective/escape)

			//HRRFM horror form stuff goes here
			boutput(changeling.current, "<B><span class='alert'>You feel... HUNGRY!</span></B><br>")

			// Moved antag help pop-up to changeling.dm (Convair880).

			var/obj_count = 1
			for(var/datum/objective/objective in changeling.objectives)
				boutput(changeling.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
				obj_count++

	SPAWN_DBG (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/changeling/proc/get_possible_changelings(num_changelings=1)
	var/list/candidates = list()

	for(var/mob/new_player/player in mobs)
		if (ishellbanned(player)) continue //No treason for you
		if ((player.client) && (player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
			if(player.client.preferences.be_changeling)
				candidates += player.mind

	if(candidates.len < num_changelings)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Only [candidates.len] players with be_changeling set to yes were ready. We need [num_changelings], so including players who don't want to be changelings in the pool.")
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue

			if (ishellbanned(player)) continue //No treason for you
			if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind

	if(candidates.len < 1)
		return list()
	else
		return candidates

/datum/game_mode/changeling/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested staus information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "changeling")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(src.traitors))
/*
	for (var/obj/machinery/computer/communications/comm in machine_registry[MACHINES_COMMSCONSOLES])
		if (!(comm.status & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/paper/intercept = new /obj/item/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)
*/

	for (var/obj/machinery/communications_dish/C in by_type[/obj/machinery/communications_dish])
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")

/datum/game_mode/changeling/declare_completion()
	..()

/datum/game_mode/changeling/proc/get_mob_list()
	var/list/mobs = list()

	for(var/client/C)
		var/mob/living/carbon/player = C.mob
		if (!istype(player)) continue
		mobs += player

	return mobs

/datum/game_mode/changeling/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		var/mob/living/carbon/player = C.mob
		if (!istype(player)) continue

		if ((player.real_name != excluded_name))
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)
