/datum/game_mode/mixed
	name = "mixed (action)"
	config_tag = "mixed"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_TRAITOR = 1, ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1, ROLE_WRESTLER = 1, ROLE_WEREWOLF = 1, ROLE_ARCFIEND = 1)
	antag_token_support = TRUE

	var/const/traitors_possible = 8 // cogwerks - lowered from 10
	var/const/werewolf_players_req = 15

	var/has_wizards = TRUE
	var/has_werewolves = TRUE

	var/list/traitor_types = list(ROLE_TRAITOR = 1, ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1 , ROLE_SPY_THIEF = 1, ROLE_WEREWOLF = 1, ROLE_ARCFIEND = 1)
#if defined(MAP_OVERRIDE_NADIR)
	var/list/major_threats = list(ROLE_WRAITH = 1, ROLE_FLOCKMIND = 1)
#else
	var/list/major_threats = list(ROLE_BLOB = 1, ROLE_WRAITH = 1, ROLE_FLOCKMIND = 1)
#endif

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/num_enemies_divisor = 10


/datum/game_mode/mixed/announce()
	boutput(world, "<B>The current game mode is - Mixed Action!</B>")
	boutput(world, "<B>Anything could happen! Be on your guard!</B>")

/datum/game_mode/mixed/pre_setup()
	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if(player.ready)
			num_players++

	if (num_players < werewolf_players_req || !has_werewolves)
		traitor_types[ROLE_WEREWOLF] = 0;

	var/i = rand(25)
	var/num_enemies = 1

	if(traitor_scaling)
		num_enemies = clamp(round((num_players + i) / num_enemies_divisor), 1, traitors_possible) // adjust divisor as needed

	var/num_wizards = 0
	var/num_traitors = 0
	var/num_changelings = 0
	var/num_vampires = 0
	var/num_grinches = 0
	var/num_wraiths = 0
	var/num_blobs = 0
	var/num_spy_thiefs = 0
	var/num_werewolves = 0
	var/num_arcfiends = 0
	var/num_flockminds = 0
#if defined(XMAS) && !defined(RP_MODE)
	src.traitor_types[ROLE_GRINCH] = 1;
	src.latejoin_antag_roles[ROLE_GRINCH] = 1;
#endif

	var/major_threat_chance = length(src.major_threats) * 20
	if ((num_enemies >= 4 && prob(major_threat_chance)) || debug_mixed_forced_wraith || debug_mixed_forced_blob || debug_mixed_forced_flock)
		var/chosen = weighted_pick(src.major_threats)
		if (chosen == ROLE_WRAITH || debug_mixed_forced_wraith)
			num_enemies = max(num_enemies - 2, 1)
			num_wraiths = 1
		else if (chosen == ROLE_BLOB || debug_mixed_forced_blob)
			num_enemies = max(num_enemies - 3, 1)
			num_blobs = 1
		else if (chosen == ROLE_FLOCKMIND || debug_mixed_forced_flock)
			num_enemies = max(num_enemies - 2, 1)
			num_flockminds = 1
	for(var/j = 0, j < num_enemies, j++)
		if(has_wizards && prob(10)) // powerful combat roles
			num_wizards++
			// if any combat roles end up in this mode they go here ok
		else // more stealthy roles
			switch(weighted_pick(src.traitor_types))
				if(ROLE_TRAITOR) num_traitors++
				if(ROLE_CHANGELING) num_changelings++
				if(ROLE_VAMPIRE) num_vampires++
				if(ROLE_GRINCH) num_grinches++
				if(ROLE_SPY_THIEF) num_spy_thiefs++
				if(ROLE_WEREWOLF) num_werewolves++
				if(ROLE_ARCFIEND) num_arcfiends++

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		switch(weighted_pick(traitor_types))
			if(ROLE_WIZARD)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.assigned_role = "MODE"
				tplayer.special_role = ROLE_WIZARD
				//num_wizards = max(0, num_wizards -1)
			if(ROLE_TRAITOR)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = ROLE_TRAITOR
				//num_traitors = max(0, num_traitors -1)
			if(ROLE_CHANGELING)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = ROLE_CHANGELING
				//num_changelings = max(0, num_changelings -1)
			if(ROLE_VAMPIRE)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = ROLE_VAMPIRE
				//num_vampires = max(0, num_vampires -1)
			if(ROLE_WRAITH)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = ROLE_WRAITH
				//num_wraiths = max(0, num_wraiths -1)
			if(ROLE_BLOB)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = ROLE_BLOB
				//num_blobs = max(0, num_blobs -1)
			if(ROLE_SPY_THIEF)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = ROLE_SPY_THIEF
			if(ROLE_WEREWOLF)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = ROLE_WEREWOLF
			if(ROLE_ARCFIEND)
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = ROLE_ARCFIEND

		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	if(num_wizards)
		var/list/possible_wizards = get_possible_enemies(ROLE_WIZARD,num_wizards)
		var/list/chosen_wizards = antagWeighter.choose(pool = possible_wizards, role = ROLE_WIZARD, amount = num_wizards, recordChosen = 1)
		for (var/datum/mind/wizard in chosen_wizards)
			traitors += wizard
			wizard.assigned_role = "MODE"
			wizard.special_role = ROLE_WIZARD
			possible_wizards.Remove(wizard)

	if(num_traitors)
		var/list/possible_traitors = get_possible_enemies(ROLE_TRAITOR,num_traitors)
		var/list/chosen_traitors = antagWeighter.choose(pool = possible_traitors, role = ROLE_TRAITOR, amount = num_traitors, recordChosen = 1)
		for (var/datum/mind/traitor in chosen_traitors)
			traitors += traitor
			traitor.special_role = ROLE_TRAITOR
			possible_traitors.Remove(traitor)

	if(num_changelings)
		var/list/possible_changelings = get_possible_enemies(ROLE_CHANGELING,num_changelings)
		var/list/chosen_changelings = antagWeighter.choose(pool = possible_changelings, role = ROLE_CHANGELING, amount = num_changelings, recordChosen = 1)
		for (var/datum/mind/changeling in chosen_changelings)
			traitors += changeling
			changeling.special_role = ROLE_CHANGELING
			possible_changelings.Remove(changeling)

	if(num_vampires)
		var/list/possible_vampires = get_possible_enemies(ROLE_VAMPIRE,num_vampires)
		var/list/chosen_vampires = antagWeighter.choose(pool = possible_vampires, role = ROLE_VAMPIRE, amount = num_vampires, recordChosen = 1)
		for (var/datum/mind/vampire in chosen_vampires)
			traitors += vampire
			vampire.special_role = ROLE_VAMPIRE
			possible_vampires.Remove(vampire)

	if(num_wraiths)
		var/list/possible_wraiths = get_possible_enemies(ROLE_WRAITH,num_wraiths)
		var/list/chosen_wraiths = antagWeighter.choose(pool = possible_wraiths, role = ROLE_WRAITH, amount = num_wraiths, recordChosen = 1)
		for (var/datum/mind/wraith in chosen_wraiths)
			traitors += wraith
			wraith.special_role = ROLE_WRAITH
			possible_wraiths.Remove(wraith)

	if(num_blobs)
		var/list/possible_blobs = get_possible_enemies(ROLE_BLOB,num_blobs)
		var/list/chosen_blobs = antagWeighter.choose(pool = possible_blobs, role = ROLE_BLOB, amount = num_blobs, recordChosen = 1)
		for (var/datum/mind/blob in chosen_blobs)
			traitors += blob
			blob.special_role = ROLE_BLOB
			possible_blobs.Remove(blob)

	if(num_flockminds)
		var/list/possible_flockminds = get_possible_enemies(ROLE_FLOCKMIND,num_flockminds)
		var/list/chosen_flockminds = antagWeighter.choose(pool = possible_flockminds, role = ROLE_FLOCKMIND, amount = num_flockminds, recordChosen = 1)
		for (var/datum/mind/flockmind in chosen_flockminds)
			traitors += flockmind
			flockmind.special_role = ROLE_FLOCKMIND
			possible_flockminds.Remove(flockmind)

	if(num_grinches)
		var/list/possible_grinches = get_possible_enemies(ROLE_MISC,num_grinches)
		var/list/chosen_grinches = antagWeighter.choose(pool = possible_grinches, role = ROLE_GRINCH, amount = num_grinches, recordChosen = 1)
		for (var/datum/mind/grinch in chosen_grinches)
			traitors += grinch
			grinch.special_role = ROLE_GRINCH
			possible_grinches.Remove(grinch)

	if(num_spy_thiefs)
		var/list/possible_spy_thieves = get_possible_enemies(ROLE_SPY_THIEF,num_spy_thiefs)
		var/list/chosen_spy_thieves = antagWeighter.choose(pool = possible_spy_thieves, role = ROLE_SPY_THIEF, amount = num_spy_thiefs, recordChosen = 1)
		for (var/datum/mind/spy in chosen_spy_thieves)
			traitors += spy
			spy.special_role = ROLE_SPY_THIEF
			possible_spy_thieves.Remove(spy)

	if(num_werewolves)
		var/list/possible_werewolves = get_possible_enemies(ROLE_WEREWOLF,num_werewolves)
		var/list/chosen_werewolves = antagWeighter.choose(pool = possible_werewolves, role = ROLE_WEREWOLF, amount = num_werewolves, recordChosen = 1)
		for (var/datum/mind/wolf in chosen_werewolves)
			traitors += wolf
			wolf.special_role = ROLE_WEREWOLF
			possible_werewolves.Remove(wolf)

	if(num_arcfiends)
		var/list/possible_arcfiends = get_possible_enemies(ROLE_ARCFIEND,num_arcfiends)
		var/list/chosen_arcfiends = antagWeighter.choose(pool = possible_arcfiends, role = ROLE_ARCFIEND, amount = num_arcfiends, recordChosen = 1)
		for (var/datum/mind/arcfiend in chosen_arcfiends)
			traitors += arcfiend
			arcfiend.special_role = ROLE_ARCFIEND
			possible_arcfiends.Remove(arcfiend)

	if(!traitors) return 0

	return 1

/datum/game_mode/mixed/post_setup()
	for (var/datum/mind/traitor in traitors)
		equip_antag(traitor)

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/mixed/send_intercept()
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


/datum/game_mode/mixed/declare_completion()
	. = ..()

/datum/game_mode/mixed/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs. You may ignore any of your laws to do this."
	boutput(killer, "<b>Your laws have been changed!</b>")
	killer.law_rack_connection?.SetLawCustom("Objective Law Module",law,1,true,true)
	killer.law_rack_connection?.UpdateLaws()

/datum/game_mode/mixed/proc/get_mob_list()
	var/list/mobs = list()

	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue
		mobs += player
	return mobs

/datum/game_mode/mixed/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue

		if (player.real_name != excluded_name)
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)
