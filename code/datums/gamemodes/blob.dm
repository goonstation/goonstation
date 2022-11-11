/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"
	shuttle_available = 2
	shuttle_available_threshold = 12000 // 20 min

	antag_token_support = TRUE
	var/const/blobs_minimum = 2
	var/const/blobs_possible = 4
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/finish_counter = 0
	escape_possible = 0

/datum/game_mode/blob/announce()
	boutput(world, "<B>The current game mode is - <font color='green'>Blob</font>!</B>")
	boutput(world, "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>")
	boutput(world, "You must kill it all while minimizing the damage to the station.")

/datum/game_mode/blob/pre_setup()
	..()
	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if(player.ready)
			num_players++

	var/i = rand(-5, 0)
	var/num_blobs = clamp(round((num_players + i) / 18), blobs_minimum, blobs_possible)

	var/list/possible_blobs = get_possible_enemies(ROLE_BLOB, num_blobs)

	if (!possible_blobs || !islist(possible_blobs) || !possible_blobs.len || possible_blobs.len < blobs_minimum)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeems an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeems an antag token.")
		//num_blobs = max(0, num_blobs - 1)

	var/list/chosen_blobs = antagWeighter.choose(pool = possible_blobs, role = ROLE_BLOB, amount = num_blobs, recordChosen = 1)
	traitors |= chosen_blobs
	for (var/datum/mind/blob in traitors)
		blob.special_role = ROLE_BLOB
		blob.assigned_role = "MODE"
		possible_blobs.Remove(blob)

	return 1

/datum/game_mode/blob/post_setup()
	..()
	emergency_shuttle.disabled = SHUTTLE_CALL_ENABLED
	for (var/datum/mind/blob in traitors)
		if (istype(blob))
			bestow_objective(blob,/datum/objective/specialist/blob)

			SPAWN(0)
				var/newname = input(blob.current, "You are a Blob. Please choose a name for yourself, it will show in the form: <name> the Blob", "Name change") as text

				if (newname)
					phrase_log.log_phrase("name-blob", newname, no_duplicates=TRUE)
					if (length(newname) >= 26) newname = copytext(newname, 1, 26)
					newname = strip_html(newname) + " the Blob"
					blob.current.real_name = newname
					blob.current.name = newname

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/blob/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested status information:<BR>"
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
		intercepttext += i_text.build(A, pick(ticker.minds))

	for_by_tcl(C, /obj/machinery/communications_dish)
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")

/datum/game_mode/blob/check_finished()
	if (..())
		return 1
	if (no_automatic_ending)
		return 0
	var/blobcount = 0
	var/tilecount = 0
	for (var/datum/mind/M in traitors)
		if (!M)
			continue
		if (M.special_role != ROLE_BLOB)
			continue
		if (isblob(M.current))
			var/mob/living/intangible/blob_overmind/O = M.current
			blobcount += 1
			tilecount += O.blobs.len
	for (var/datum/mind/M in Agimmicks)
		if (!M)
			continue
		if (M.special_role != ROLE_BLOB)
			continue
		if (isblob(M.current))
			var/mob/living/intangible/blob_overmind/O = M.current
			blobcount += 1
			tilecount += O.blobs.len
	if(tilecount < 500*blobcount)
		return 0
	return 1

/datum/game_mode/blob/victory_msg()
	var/list/blobs = list()
	for (var/datum/mind/M in traitors)
		if (!M)
			continue
		if (isblob(M.current))
			blobs += M.current
	for (var/datum/mind/M in Agimmicks)
		if (!M)
			continue
		if (isblob(M.current))
			blobs += M.current
	if (!blobs.len)
		return "<span style='font-size:20px'><b>Station victory!</b> - All blobs have been exterminated!</span>"
	else
		return "<span style='font-size:20px'><b>Blob victory!</b> - The crew has failed to stop the overmind! The station is lost to the blob!</span>"

/datum/game_mode/blob/declare_completion()
	boutput(world, src.victory_msg())
	..()
