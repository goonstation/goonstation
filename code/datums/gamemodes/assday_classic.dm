/*
*
*       Warc's first babbo gamemode, copied wholesale from Traitor. h
*
*/
/datum/game_mode/assday
	name = "Everyone-Is-A-Traitor Mode"
	config_tag = "everyone-is-a-traitor"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list("traitor","changeling","wraith")

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/const/traitors_possible = 169

/datum/game_mode/assday/announce()
	boutput(world, "<B>The current game mode is - ASS DAY!</B>")
	boutput(world, "<B>The entire crew of [station_or_ship()] has defected. Beware of dog.</B>")


/datum/game_mode/assday/pre_setup()

	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue
		if (player.ready)
			num_players++

	var/num_traitors = 1
	var/num_wraiths = 1
	var/token_wraith = 0

	if(traitor_scaling)
		num_traitors = max(1, num_players) // How many? all of em.

	if(prob(10))
		num_traitors -=1
		num_wraiths += 1


	var/list/possible_traitors = get_possible_traitors(num_traitors)

	if (!possible_traitors.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		if (num_wraiths && !(token_wraith))
			token_wraith = 1 // only allow 1 wraith to spawn
			var/datum/mind/twraith = pick(token_players) //Randomly pick from the token list so the first person to ready up doesn't always get it.
			traitors += twraith
			token_players.Remove(twraith)
			twraith.special_role = "wraith"
		else
			traitors += tplayer
			token_players.Remove(tplayer)
		logTheThing("admin", tplayer.current, null, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")
		/*num_traitors--
		num_traitors = max(num_traitors, 0)*/

	var/list/chosen_traitors = antagWeighter.choose(pool = possible_traitors, role = "traitor", amount = num_traitors, recordChosen = 1)
	traitors |= chosen_traitors
	for (var/datum/mind/traitor in traitors)
		traitor.special_role = "traitor"
		possible_traitors.Remove(traitor)

	if(num_wraiths)
		var/list/possible_wraiths = get_possible_wraiths(num_wraiths)
		var/list/chosen_wraiths = antagWeighter.choose(pool = possible_wraiths, role = "wraith", amount = num_wraiths, recordChosen = 1)
		for (var/datum/mind/wraith in chosen_wraiths)
			traitors += wraith
			wraith.special_role = "wraith"
			possible_wraiths.Remove(wraith)

	return 1

/datum/game_mode/assday/post_setup()
	var/objective_set_path = null
	for(var/datum/mind/traitor in traitors)
		objective_set_path = null // Gotta reset this.
		switch(traitor.special_role)
			if("traitor")
			#ifdef RP_MODE
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			#else
				objective_set_path = pick(typesof(/datum/objective_set/traitor))
			#endif

				new objective_set_path(traitor)

				var/obj_count = 1
				for(var/datum/objective/objective in traitor.objectives)
					boutput(traitor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
					obj_count++
				SHOW_TRAITOR_HARDMODE_TIPS(traitor.current)

			if ("wraith")
				generate_wraith_objectives(traitor)

	SPAWN_DBG (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/assday/proc/get_possible_traitors(minimum_traitors=1)
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (ishellbanned(player)) continue //No treason for you
		if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
			if(player.client.preferences.be_traitor)
				candidates += player.mind

	if(candidates.len < minimum_traitors)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Only [candidates.len] players with be_traitor set to yes were ready. We need [minimum_traitors] traitors so including players who don't want to be traitors in the pool.")
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue

			if (ishellbanned(player)) continue //No treason for you
			if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind

				if ((minimum_traitors > 1) && (candidates.len >= minimum_traitors))
					break

	if(candidates.len < 1)
		return list()
	else
		return candidates

/datum/game_mode/assday/proc/get_possible_wraiths(minimum_traitors=1)
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (ishellbanned(player)) continue //No treason for you
		if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
			if(player.client.preferences.be_wraith)
				candidates += player.mind

	if(candidates.len < minimum_traitors)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Only [candidates.len] players with be_wraith set to yes were ready. We need [minimum_traitors] wraiths so including players who don't want to be wraiths in the pool.")
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue

			if (ishellbanned(player)) continue //No treason for you
			if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind

				if ((minimum_traitors > 1) && (candidates.len >= minimum_traitors))
					break

	if(candidates.len < 1)
		return list()
	else
		return candidates

/datum/game_mode/assday/send_intercept()
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
		intercepttext += i_text.build(A, pick(traitors))
/*
	for (var/obj/machinery/computer/communications/comm as anything in machine_registry[MACHINES_COMMSCONSOLES])
		if (!(comm.status & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/paper/intercept = new /obj/item/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)
*/

	for_by_tcl(C, /obj/machinery/communications_dish)
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")


/datum/game_mode/assday/declare_completion()
	return // don't call parent because we don't want to spam objectives of 80 traitors, thanks

/datum/game_mode/assday/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	boutput(killer, "<b>Your laws have been changed!</b>")
	killer:set_zeroth_law(law)
	boutput(killer, "New law: 0. [law]")

/datum/game_mode/assday/proc/get_mob_list()
	var/list/mobs = list()

	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue
		mobs += player
	return mobs

/datum/game_mode/assday/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue

		if (player.real_name != excluded_name)
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)
