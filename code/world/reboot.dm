/world/Reboot()
	TgsReboot()
	shutdown_logging()
	return ..()

/proc/Reboot_server(var/retry)
#if defined(SERVER_SIDE_PROFILING) && (defined(SERVER_SIDE_PROFILING_FULL_ROUND) || defined(SERVER_SIDE_PROFILING_INGAME_ONLY))
#if defined(SERVER_SIDE_PROFILING_INGAME_ONLY) || !defined(SERVER_SIDE_PROFILING_PREGAME)
	// This is a profiler dump of only the in-game part of the round
	// b/c either it was reset (_INGAME_ONLY) or was never started (_PREGAME)
#warn Profiler output at end of game (ingame)
	var/profile_out = file("data/profile/[time2text(world.realtime, "YYYY-MM-DD hh-mm-ss")]-ingame.log")
#else
	// Full round profile
#warn Profiler enabled at end of game (full)
	var/profile_out = file("data/profile/[time2text(world.realtime, "YYYY-MM-DD hh-mm-ss")]-full.log")
#endif
	profile_out << world.Profile(PROFILE_START | PROFILE_AVERAGE, "sendmaps", "json")
	world.log << "Dumped profiler data."
	// not gonna need this again
	world.Profile(PROFILE_STOP | PROFILE_AVERAGE, "sendmaps", "json")
#endif

	lagcheck_enabled = 0
	processScheduler.stop()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_REBOOT)
	save_intraround_jars()
	logTheThing(LOG_ADMIN, null, "Gamelogger stats BANDAID. [json_encode(game_stats.stats)]")
	var/list/spacemas_ornaments = get_spacemas_ornaments(only_if_loaded=TRUE)
	if(spacemas_ornaments) world.save_intra_round_value("tree_ornaments_[BUILD_TIME_YEAR]", spacemas_ornaments)
	global.save_noticeboards()
	for_by_tcl(canvas, /obj/item/canvas/big_persistent)
		canvas.save()
	global.phrase_log.save()
	for_by_tcl(P, /datum/player)
		P.on_round_end()
	save_tetris_highscores()
	if (current_state < GAME_STATE_FINISHED)
		current_state = GAME_STATE_FINISHED
	eventRecorder.process() // Ensure any remaining events are processed
#if defined(CI_RUNTIME_CHECKING) || defined(UNIT_TESTS)
	for (var/client/C in clients)
		ehjax.send(C, "browseroutput", "hardrestart")

	logTheThing(LOG_DIARY, null, "Shutting down after testing for runtimes.", "admin")
	if (isnull(runtimeDetails))
		text2file("Runtime checking failed due to missing runtimeDetails global list", "errors.log")
	else if (length(runtimeDetails) > 0)
		text2file("[length(runtimeDetails)] runtimes generated:", "errors.log")
		for (var/idx in runtimeDetails)
			var/list/details = runtimeDetails[idx]
			var/timestamp = details["seen"]
			var/file = details["file"]
			var/line = details["line"]
			var/name = details["name"]
			text2file("\[[timestamp]\] [file],[line]: [name]", "errors.log")
#if !(defined(PREFAB_CHECKING) || defined(RANDOM_ROOM_CHECKING))
	var/apc_error_str = debug_map_apc_count("\n", zlim=Z_LEVEL_STATION)
	if (!is_blank_string(apc_error_str))
		text2file(apc_error_str, "errors.log")
#endif
	shutdown()
#endif

	SPAWN(world.tick_lag)
		var/sound/round_end_sound = null
		if (prob(40))
			round_end_sound = sound(pick('sound/misc/NewRound2.ogg', 'sound/misc/NewRound3.ogg', 'sound/misc/NewRound4.ogg', 'sound/misc/TimeForANewRound.ogg'))
		else
			round_end_sound = sound('sound/misc/NewRound.ogg')
		for (var/client/C)
			C << round_end_sound

#ifdef DATALOGGER
	SPAWN(world.tick_lag*2)
		var/playercount = 0
		var/admincount = 0
		for(var/client/C in clients)
			if(C.mob)
				if(C.holder)
					admincount++
				playercount++
		game_stats.SetValue("players", playercount)
		game_stats.SetValue("admins", admincount)
		//game_stats.WriteToFile("data/game_stats.txt")
#endif

	sleep(5 SECONDS) // wait for sound to play
	if(config.update_check_enabled)
		world.installUpdate()

	//if the server has a hard-reboot file, we trigger a shutdown (server supervisor process will restart the server after)
	//this is to avoid memory leaks from leaving the server running for long periods
	if (fexists("data/hard-reboot"))
		//Tell client browserOutput that we're hard rebooting, so it can handle manual auto-reconnection
		for (var/client/C in clients)
			ehjax.send(C, "browseroutput", "hardrestart")

		logTheThing(LOG_DIARY, null, "Hard reboot file detected, triggering shutdown instead of reboot.", "debug")
		message_admins("Hard reboot file detected, triggering shutdown instead of reboot. (The server will auto-restart don't worry)")

		fdel("data/hard-reboot")
		shutdown()
	else
		//Tell client browserOutput that a restart is happening RIGHT NOW
		for (var/client/C in clients)
			ehjax.send(C, "browseroutput", "roundrestart")

		world.Reboot()


/world/proc/installUpdate()
	// Simple check to see if a new dmb exists in the update folder
	logTheThing(LOG_DIARY, null, "Checking for updated [config.dmb_filename].dmb...", "admin")
	if(fexists("update/[config.dmb_filename].dmb"))
		logTheThing(LOG_DIARY, null, "Updated [config.dmb_filename].dmb found. Updating...", "admin")
		for(var/f in flist("update/"))
			if (IS_DIR_FNAME("update/[f]"))
				logTheThing(LOG_DIARY, null, "\tClearing [f]...", "admin")
				fdel(f)

			logTheThing(LOG_DIARY, null, "\tMoving [f]...", "admin")
			fcopy("update/[f]", "[f]")
			fdel("update/[f]")

		// Delete .dyn.rsc so that stupid shit doesn't happen
		fdel("[config.dmb_filename].dyn.rsc")

		logTheThing(LOG_DIARY, null, "Update complete.", "admin")
	else
		logTheThing(LOG_DIARY, null, "No update found. Skipping update process.", "admin")


/// EXPERIMENTAL STUFF

/world/Del()
	disable_auxtools_debugger()
	. = ..()
