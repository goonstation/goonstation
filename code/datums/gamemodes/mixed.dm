/datum/game_mode/mixed
	name = "mixed (action)"
	config_tag = "mixed"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list("traitor", "changeling", "vampire", "wrestler", "werewolf")

	var/const/traitors_possible = 8 // cogwerks - lowered from 10
	var/const/werewolf_players_req = 15

	var/has_wizards = 1
	var/has_werewolves = 1
	var/has_blobs = 1

	var/list/traitor_types = list("traitor","changeling","vampire", "spy_thief", "werewolf")

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
		traitor_types -= "werewolf"

	var/i = rand(25)
	var/num_enemies = 1

	if(traitor_scaling)
		num_enemies = max(1, min(round((num_players + i) / num_enemies_divisor), traitors_possible)) // adjust divisor as needed

	var/num_wizards = 0
	var/num_traitors = 0
	var/num_changelings = 0
	var/num_vampires = 0
	var/num_grinches = 0
	var/num_wraiths = 0
	var/num_blobs = 0
	var/num_spy_thiefs = 0
	var/num_werewolves = 0
#ifdef XMAS
	src.traitor_types += "grinch"
	src.latejoin_antag_roles += "grinch"
#endif

	if ((num_enemies >= 4 && prob(20)) || debug_mixed_forced_wraith || debug_mixed_forced_blob)
		if (prob(50) || debug_mixed_forced_wraith)
			num_enemies = max(num_enemies - 4, 1)
			num_wraiths = 1
		else if (has_blobs)
			num_enemies = max(num_enemies - 4, 1)
			num_blobs = 1
	for(var/j = 0, j < num_enemies, j++)
		if(has_wizards && prob(10)) // powerful combat roles
			num_wizards++
			// if any combat roles end up in this mode they go here ok
		else // more stealthy roles
			switch(pick(src.traitor_types))
				if("traitor") num_traitors++
				if("changeling") num_changelings++
				if("vampire") num_vampires++
				if("grinch") num_grinches++
				if("spy_thief") num_spy_thiefs++
				if("werewolf") num_werewolves++

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		switch(pick(traitor_types))
			if("wizard")
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.assigned_role = "MODE"
				tplayer.special_role = "wizard"
				//num_wizards = max(0, num_wizards -1)
			if("traitor")
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = "traitor"
				//num_traitors = max(0, num_traitors -1)
			if("changeling")
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = "changeling"
				//num_changelings = max(0, num_changelings -1)
			if("vampire")
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = "vampire"
				//num_vampires = max(0, num_vampires -1)
			if("wraith")
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = "wraith"
				//num_wraiths = max(0, num_wraiths -1)
			if("blob")
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = "blob"
				//num_blobs = max(0, num_blobs -1)
			if("spy_thief")
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = "spy_thief"
			if("werewolf")
				traitors += tplayer
				token_players.Remove(tplayer)
				tplayer.special_role = "werewolf"

		logTheThing("admin", tplayer.current, null, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	if(num_wizards)
		var/list/possible_wizards = get_possible_enemies("wizard",num_wizards)
		var/list/chosen_wizards = antagWeighter.choose(pool = possible_wizards, role = "wizard", amount = num_wizards, recordChosen = 1)
		for (var/datum/mind/wizard in chosen_wizards)
			traitors += wizard
			wizard.assigned_role = "MODE"
			wizard.special_role = "wizard"
			possible_wizards.Remove(wizard)

	if(num_traitors)
		var/list/possible_traitors = get_possible_enemies("traitor",num_traitors)
		var/list/chosen_traitors = antagWeighter.choose(pool = possible_traitors, role = "traitor", amount = num_traitors, recordChosen = 1)
		for (var/datum/mind/traitor in chosen_traitors)
			traitors += traitor
			traitor.special_role = "traitor"
			possible_traitors.Remove(traitor)

	if(num_changelings)
		var/list/possible_changelings = get_possible_enemies("changeling",num_changelings)
		var/list/chosen_changelings = antagWeighter.choose(pool = possible_changelings, role = "changeling", amount = num_changelings, recordChosen = 1)
		for (var/datum/mind/changeling in chosen_changelings)
			traitors += changeling
			changeling.special_role = "changeling"
			possible_changelings.Remove(changeling)

	if(num_vampires)
		var/list/possible_vampires = get_possible_enemies("vampire",num_vampires)
		var/list/chosen_vampires = antagWeighter.choose(pool = possible_vampires, role = "vampire", amount = num_vampires, recordChosen = 1)
		for (var/datum/mind/vampire in chosen_vampires)
			traitors += vampire
			vampire.special_role = "vampire"
			possible_vampires.Remove(vampire)

	if(num_wraiths)
		var/list/possible_wraiths = get_possible_enemies("wraith",num_wraiths)
		var/list/chosen_wraiths = antagWeighter.choose(pool = possible_wraiths, role = "wraith", amount = num_wraiths, recordChosen = 1)
		for (var/datum/mind/wraith in chosen_wraiths)
			traitors += wraith
			wraith.special_role = "wraith"
			possible_wraiths.Remove(wraith)

	if(num_blobs)
		var/list/possible_blobs = get_possible_enemies("blob",num_blobs)
		var/list/chosen_blobs = antagWeighter.choose(pool = possible_blobs, role = "blob", amount = num_blobs, recordChosen = 1)
		for (var/datum/mind/blob in chosen_blobs)
			traitors += blob
			blob.special_role = "blob"
			possible_blobs.Remove(blob)

	if(num_grinches)
		var/list/possible_grinches = get_possible_enemies("grinch",num_grinches)
		var/list/chosen_grinches = antagWeighter.choose(pool = possible_grinches, role = "grinch", amount = num_grinches, recordChosen = 1)
		for (var/datum/mind/grinch in chosen_grinches)
			traitors += grinch
			grinch.special_role = "grinch"
			possible_grinches.Remove(grinch)

	if(num_spy_thiefs)
		var/list/possible_spy_thieves = get_possible_enemies("spy_thief",num_spy_thiefs)
		var/list/chosen_spy_thieves = antagWeighter.choose(pool = possible_spy_thieves, role = "spy_thief", amount = num_spy_thiefs, recordChosen = 1)
		for (var/datum/mind/spy in chosen_spy_thieves)
			traitors += spy
			spy.special_role = "spy_thief"
			possible_spy_thieves.Remove(spy)

	if(num_werewolves)
		var/list/possible_werewolves = get_possible_enemies("werewolf",num_werewolves)
		var/list/chosen_werewolves = antagWeighter.choose(pool = possible_werewolves, role = "werewolf", amount = num_werewolves, recordChosen = 1)
		for (var/datum/mind/wolf in chosen_werewolves)
			traitors += wolf
			wolf.special_role = "werewolf"
			possible_werewolves.Remove(wolf)

	if(!traitors) return 0

	return 1

/datum/game_mode/mixed/post_setup()
	var/objective_set_path = null

	for (var/datum/mind/traitor in traitors)
		objective_set_path = null // Gotta reset this.

		if (traitor.assigned_role == "Chaplain" && traitor.special_role == "vampire")
			// vamp will burn in the chapel before he can react
			if (prob(50))
				traitor.special_role = "traitor"
			else
				traitor.special_role = "changeling"

		switch (traitor.special_role)
			if ("traitor")
			#ifdef RP_MODE
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			#else
				objective_set_path = pick(typesof(/datum/objective_set/traitor))
			#endif
				equip_traitor(traitor.current)

			if ("changeling")
				objective_set_path = /datum/objective_set/changeling
				traitor.current.make_changeling()

			if ("wizard")
				objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
				traitor.current.unequip_all(1)

				if (!job_start_locations["wizard"])
					boutput(traitor.current, "<B><span class='alert'>A starting location for you could not be found, please report this bug!</span></B>")
				else
					traitor.current.set_loc(pick(job_start_locations["wizard"]))

				equip_wizard(traitor.current)

				var/randomname
				if (traitor.current.gender == "female")
					randomname = pick_string_autokey("names/wizard_female.txt")
				else
					randomname = pick_string_autokey("names/wizard_male.txt")

				SPAWN_DBG (0)
					var/newname = input(traitor.current,"You are a Wizard. Would you like to change your name to something else?", "Name change",randomname)

					if (length(ckey(newname)) == 0)
						newname = randomname

					if (newname)
						if (length(newname) >= 26) newname = copytext(newname, 1, 26)
						newname = strip_html(newname)
						traitor.current.real_name = newname
						traitor.current.name = newname

			if ("wraith")
				generate_wraith_objectives(traitor)

			if ("vampire")
				objective_set_path = /datum/objective_set/vampire
				traitor.current.make_vampire()

			if ("hunter")
				objective_set_path = /datum/objective_set/hunter
				traitor.current.show_text("<h2><font color=red><B>You are a hunter!</B></font></h2>", "red")
				traitor.current.make_hunter()

			if ("grinch")
				objective_set_path = /datum/objective_set/grinch
				boutput(traitor.current, "<h2><font color=red><B>You are a grinch!</B></font></h2>")
				traitor.current.make_grinch()

			if ("blob")
				objective_set_path = /datum/objective_set/blob
				SPAWN_DBG (0)
					var/newname = input(traitor.current, "You are a Blob. Please choose a name for yourself, it will show in the form: <name> the Blob", "Name change") as text

					if (newname)
						if (length(newname) >= 26) newname = copytext(newname, 1, 26)
						newname = strip_html(newname) + " the Blob"
						traitor.current.real_name = newname
						traitor.current.name = newname

			if ("spy_thief")
				objective_set_path = /datum/objective_set/spy_theft
				SPAWN_DBG(1 SECOND) //dumb delay to avoid race condition where spy assignment bugs
					equip_spy_theft(traitor.current)

				if (!src.spy_market)
					src.spy_market = new /datum/game_mode/spy_theft
					SPAWN_DBG(5 SECONDS) //Some possible bounty items (like organs) need some time to get set up properly and be assigned names
						src.spy_market.build_bounty_list()
						src.spy_market.update_bounty_readouts()

			if ("werewolf")
				objective_set_path = /datum/objective_set/werewolf
				traitor.current.make_werewolf()

		if (!isnull(objective_set_path)) // Cannot create objects of type null. [wraiths use a special proc]
			new objective_set_path(traitor)
		var/obj_count = 1
		for (var/datum/objective/objective in traitor.objectives)
			boutput(traitor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

	SPAWN_DBG (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/mixed/proc/get_possible_enemies(type,number)
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (ishellbanned(player)) continue //No treason for you
		if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
			switch(type)
				if("wizard")
					if(player.client.preferences.be_wizard) candidates += player.mind
				if("traitor")
					if(player.client.preferences.be_traitor) candidates += player.mind
				if("changeling")
					if(player.client.preferences.be_changeling) candidates += player.mind
				if("vampire")
					if(player.client.preferences.be_vampire) candidates += player.mind
				if("wraith")
					if(player.client.preferences.be_wraith) candidates += player.mind
				if("blob")
					if(player.client.preferences.be_blob) candidates += player.mind
				if("spy_thief")
					if(player.client.preferences.be_spy) candidates += player.mind
				if("werewolf")
					if(player.client.preferences.be_werewolf) candidates += player.mind
				else
					if(player.client.preferences.be_misc) candidates += player.mind

	if(candidates.len < number)
		if(type in list("wizard","traitor","changeling", "wraith", "blob", "werewolf"))
			logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Only [candidates.len] players with be_[type] set to yes were ready. We need [number] so including players who don't want to be [type]s in the pool.")
		else
			logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Not enough players with be_misc set to yes, including players who don't want to be misc enemies in the pool for [type] assignment.")

		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue

			if (ishellbanned(player)) continue //No treason for you
			if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind
				if ((number > 1) && (candidates.len >= number))
					break

	if(candidates.len < 1)
		return list()
	else
		return candidates

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


/datum/game_mode/mixed/declare_completion()
	. = ..()

/datum/game_mode/mixed/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs. You may ignore any of your laws to do this."
	boutput(killer, "<b>Your laws have been changed!</b>")
	killer:set_zeroth_law(law)
	boutput(killer, "New law: 0. [law]")

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
