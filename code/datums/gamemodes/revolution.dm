// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

//uncomment to disable safety checks and win conditions to allow for local testing
//#define THE_REVOLUTION_WILL_NOT_BE_TELEVISED 1

#ifdef THE_REVOLUTION_WILL_NOT_BE_TELEVISED
#warn Revolution debug mode enabled. IF YOU COMMIT THIS TO LIVE EVERYTHING WILL BREAK AND YOUR KNEECAPS WILL BE FORFEIT!!1
#endif
/datum/game_mode/revolution
	name = "Revolution"
	config_tag = "revolution"
	shuttle_available = SHUTTLE_AVAILABLE_DISABLED
	regular = FALSE
	antag_token_support = TRUE

	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()
	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/const/TrackerTime_min = 27 MINUTES //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/TrackerTime_max = 30 MINUTES //upper bound on time before intercept arrives (in tenths of seconds)
	var/const/min_revheads = 3
	var/const/max_revheads = 5
	var/const/pop_divisor = 15
	var/win_check_freq = 30 SECONDS //frequency of checks on the win conditions
	var/round_limit = 40 MINUTES //see post_setup
	var/endthisshit = 0
	var/gibwave_started = FALSE
	do_antag_random_spawns = 0
	escape_possible = 0

/datum/game_mode/revolution/extended //Does not end prematurely
	name = "Revolution (no time limit)"
	config_tag = "revolution_extended"
	regular = FALSE

/datum/game_mode/revolution/announce()
	boutput(world, "<B>The current game mode is - Revolution!</B>")
	boutput(world, "<B>Some crewmembers are attempting to start a revolution!<BR><br>Revolutionaries - Kill the heads of staff. Convert other crewmembers (excluding synthetics and security) to your cause by flashing them. Protect your leaders.<BR><br>Personnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by using an electropack, electric chair or beating them in the head).</B>")

/datum/game_mode/revolution/pre_setup()

	var/list/revs_possible = get_possible_enemies(ROLE_HEAD_REVOLUTIONARY, 1)
	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if(player.ready)
			num_players++

	if (!revs_possible.len)
		return 0

	var/rev_number = 0
	var/ideal_rev_number = clamp(round(num_players / pop_divisor), min_revheads, max_revheads)

	if(revs_possible.len >= ideal_rev_number)
		rev_number = ideal_rev_number
	else
		rev_number = length(revs_possible)

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		head_revolutionaries += tplayer
		token_players.Remove(tplayer)
		rev_number--
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeems an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeems an antag token.")

	var/list/chosen_revolutionaries = antagWeighter.choose(pool = revs_possible, role = ROLE_HEAD_REVOLUTIONARY, amount = rev_number, recordChosen = 1)
	head_revolutionaries |= chosen_revolutionaries
	for (var/datum/mind/rev in head_revolutionaries)
		rev.special_role = ROLE_HEAD_REVOLUTIONARY
		revs_possible.Remove(rev)

	return 1

/datum/game_mode/revolution/post_setup()
#ifndef THE_REVOLUTION_WILL_NOT_BE_TELEVISED
	var/list/heads = get_living_heads()
	if(!head_revolutionaries || !heads)
		boutput(world, "<B><span class='alert'>Not enough players for revolution game mode. Restarting world in 5 seconds.</span></B>")
		sleep(5 SECONDS)
		Reboot_server()
		return
#endif

	for(var/datum/mind/rev_mind in head_revolutionaries)
		rev_mind.add_antagonist(ROLE_HEAD_REVOLUTIONARY)

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()
	SPAWN(rand(TrackerTime_min, TrackerTime_max))
		send_tracker()

/datum/game_mode/revolution/send_intercept()
	..(src.head_revolutionaries)

/datum/game_mode/revolution/proc/send_tracker()
	command_alert("Foreign mutiny located [station_or_ship()]wide, a program to track revolutionary leaders have been sent to all crew member PDA's.", "Central Command Security Alert", 'sound/misc/announcement_1.ogg', alert_origin = "Watchful Eye Sensor Array Update")
	command_alert("Relevant biometric signatures of Command have been identified. To aid with the ongoing revolution, station command can now be tracked through the transmitted PDA program.", "Unregistered Signal Insertion", alert_origin = "Egeria Providence Array Broadcast")
	var/datum/signal/signal1 = get_free_signal()
	signal1.data_file = (new /datum/computer/file/pda_program/revheadtracker)
	signal1.data = list("command"="file_send", "file_name" = "Revolutionary Leader Locater", "file_ext" = "PPROG", "file_size" = "1", "tag" = "auto_fileshare", "sender_name"="Central Command Distribution Line", "sender"="00000000")
	radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal1)
	var/datum/signal/signal2 = get_free_signal()
	signal2.data_file = (new /datum/computer/file/pda_program/headtracker)
	signal2.data = list("command"="file_send", "file_name" = "Nanotrasen Command Tracker", "file_ext" = "PPROG", "file_size" = "1", "tag" = "auto_fileshare", "sender"="00000000")
	radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal2)

#ifndef THE_REVOLUTION_WILL_NOT_BE_TELEVISED
/datum/game_mode/revolution/process()
	..()
	if (!istype(ticker.mode, /datum/game_mode/revolution/extended) && ticker.round_elapsed_ticks >= round_limit && !gibwave_started)
		gibwave_started = TRUE
		start_gibwave()
	if (world.time > win_check_freq)
		win_check_freq += win_check_freq
		check_win()
#endif

/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	else if(check_centcom_victory())
		finished = 3
	return

/datum/game_mode/revolution/check_finished()
	if(finished != 0)
		return 1
	else
		return 0

/datum/game_mode/revolution/proc/start_gibwave()
	command_alert("A revolution is still ongoing aboard [station_name(1)]. All loyal members of the crew are to ensure the revolution is quelled.","Emergency Riot Update") // first warning 40 minutes in
	sleep(10 MINUTES) // 10 minutes to clean up shop
	command_alert("The Revolutionary heads' biometric signatures have been confirmed. Please stand by for hostile employee termination.", "Emergency Riot Update")
	sleep(5 MINUTES) // 5 minutes until everyone dies
	command_alert("You may feel a slight burning sensation.", "Emergency Riot Update")
	sleep(10 SECONDS) // welp
	for(var/mob/living/carbon/M in mobs)
		M.gib()
	endthisshit = 1

/datum/game_mode/revolution/proc/update_all_rev_icons()
	var/list/update_me = list()
	update_me.Add(src.head_revolutionaries)
	update_me.Add(src.revolutionaries)

	for (var/datum/mind/M in update_me)
		if (M.current)
			M.current.antagonist_overlay_refresh(1, 0)

	return

/datum/game_mode/revolution/proc/update_rev_icons_added(datum/mind/rev_mind)
	var/list/update_me = list()
	update_me.Add(src.head_revolutionaries)
	update_me.Add(src.revolutionaries) // Includes rev_mind.

	for (var/datum/mind/M in update_me)
		if (M.current)
			M.current.antagonist_overlay_refresh(1, 0)

	return

/datum/game_mode/revolution/proc/update_rev_icons_removed(datum/mind/rev_mind)
	if (rev_mind && istype(rev_mind) && rev_mind.current)
		rev_mind.current.antagonist_overlay_refresh(1, 1)

	var/list/update_me = list()
	update_me.Add(src.head_revolutionaries)
	update_me.Add(src.revolutionaries)

	for (var/datum/mind/M in update_me)
		if (M.current)
			M.current.antagonist_overlay_refresh(1, 0)

	return

/datum/game_mode/proc/get_living_heads()
	var/list/heads = list()

	for(var/mob/living/carbon/human/player in mobs)
		if(player.mind && !isdead(player))
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Medical Director","Communications Officer"))
				heads += player.mind

	if(heads.len < 1)
		return null
	else
		return heads


/datum/game_mode/revolution/proc/get_all_heads()
	var/list/heads = list()

	for(var/mob/player in mobs)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Medical Director","Communications Officer"))
				heads += player.mind

	return heads

/datum/game_mode/revolution/proc/check_rev_victory()
	var/list/head_check = get_all_heads()

	if(endthisshit == 1) // don't count gibbed dudes on centcom win
		return 0

	// Run through all the heads
	for(var/datum/mind/head_mind in head_check)
		// If they exist, have a mob and aren't dead
		if(head_mind?.current && !isdead(head_mind.current))

			// Check to see if they're a robot
			if(issilicon(head_mind.current))
				// If they're a robot don't count them
				continue

			if(isghostcritter(head_mind.current) || isVRghost(head_mind.current))
				continue

			if(istype(head_mind.current.loc, /obj/cryotron))
				continue

			// Check if they're on the current z-level
			var/turf/T = get_turf(head_mind.current)
			if(T.z != 1)
				continue
			// If they are then don't end the round
			// This return means that they're alive and on the first z level and are not a robot
			return 0
	return 1
/*
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/objective in rev_mind.objectives)
			#ifdef CREW_OBJECTIVES
			if (istype(objective, /datum/objective/crew)) continue
			#endif
			if(!(objective.check_completion()))
				return 0

		return 1
*/

/datum/game_mode/revolution/proc/check_heads_victory()
	if(endthisshit == 1)
		return 0

	for(var/datum/mind/rev_mind in head_revolutionaries)
		if(rev_mind?.current && !isdead(rev_mind.current))

			// Check to see if they're a robot
			if(issilicon(rev_mind.current))
				// If they're a robot don't count them
				continue

			var/area/area = get_area(rev_mind.current)
			if(istype(area, /area/afterlife))
				continue

			if(isghostcritter(rev_mind.current) || isVRghost(rev_mind.current))
				continue

			if(ismobcritter(rev_mind.current))
				//mob critters can't revolt because they don't work here.
				continue

			var/turf/T = get_turf(rev_mind.current)
			if(T.z != 1)
				continue

			if(istype(T.loc, /area/station/security/brig) && !rev_mind.current.canmove)
				continue

			if(istype(rev_mind.current.loc, /obj/cryotron))
				continue

			return 0
	return 1

/datum/game_mode/revolution/proc/check_centcom_victory()

	if (!endthisshit)
		return 0
	return 1

/datum/game_mode/revolution/victory_msg()
	switch (finished)
		if(1)
			return "<span class='alert'><FONT size = 3><B> The heads of staff were killed or abandoned the [station_or_ship()]! The revolutionaries win!</B></FONT></span>"
		if(2)
			return "<span class='alert'><FONT size = 3><B> The heads of staff managed to stop the revolution!</B></FONT></span>"
		if(3)
			return "<span class='alert'><FONT size = 3><B> Everyone was terminated! CentCom wins!</B></FONT></span>"

/datum/game_mode/revolution/declare_completion()

	var/text = ""
	if(finished == 1)
		boutput(world, "<span class='alert'><FONT size = 3><B> The heads of staff were killed or abandoned the [station_or_ship()]! The revolutionaries win!</B></FONT></span>")
	else if(finished == 2)
		boutput(world, "<span class='alert'><FONT size = 3><B> The heads of staff managed to stop the revolution!</B></FONT></span>")
	else if(finished == 3)
		boutput(world, "<span class='alert'><FONT size = 3><B> Everyone was terminated! CentCom wins!</B></FONT></span>")

#ifdef DATALOGGER
	switch(finished)
		if(1)
			game_stats.Increment("traitorwin")
		if(2)
			game_stats.Increment("traitorloss")
#endif

	boutput(world, "<FONT size = 2><B>The head revolutionaries were: </B></FONT>")
	for(var/datum/mind/rev_mind in head_revolutionaries)
		text = ""
		if(rev_mind.current)
			text += "[rev_mind.current.real_name]"
			var/turf/T = get_turf(rev_mind.current)
			if(isdead(rev_mind.current))
				text += " (Dead)"
			else if(T.z == 2)
				text += " (Imprisoned!)"
			else if(T.z != 1)
				text += " (Abandoned the cause!)"
			else
				text += " (Survived!)"
		else
			text += "[rev_mind.key] (character destroyed)"

		boutput(world, text)

	text = ""
	boutput(world, "<FONT size = 2><B>The converted revolutionaries were: </B></FONT>")
	for(var/datum/mind/rev_nh_mind in revolutionaries)
		if(rev_nh_mind.current)
			text += "[rev_nh_mind.current.real_name]"
			var/turf/T = get_turf(rev_nh_mind.current)
			if(T.z == 2)
				text += " (Imprisoned!)"
			else if(isdead(rev_nh_mind.current))
				text += " (Dead)"
			else if(T.z != 1)
				text += " (Abandoned the cause!)"
			else
				text += " (Survived!)"
		else
			text += "[rev_nh_mind.key] (character destroyed)"
		text += ", "

	boutput(world, text)

	boutput(world, "<FONT size = 2><B>The heads of staff were: </B></FONT>")
	var/list/heads = list()
	heads = get_all_heads()
	for(var/datum/mind/head_mind in heads)
		text = ""
		if(head_mind.current)
			text += "[head_mind.current.real_name]"
			if(isdead(head_mind.current))
				text += " (Dead)"
			else
				var/turf/T = get_turf(head_mind.current)
				if(T.z != 1)
					text += " (Abandoned the [station_or_ship()]!)"
				else
					text += " (Survived!)"
		else
			text += "[head_mind.key] (character destroyed)"

		boutput(world, text)

	..() // Admin-assigned antagonists or whatever.

	if (finished == 1)
		for(var/datum/mind/rev_mind as anything in head_revolutionaries)
			if(rev_mind.current && !isdead(rev_mind.current))
				rev_mind.current.unlock_medal("This station is ours!", TRUE)
