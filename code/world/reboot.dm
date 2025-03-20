var/reboot_file_path = "data/restarting"

/proc/Create_reboot_file()
	file(reboot_file_path) << ""

/proc/Remove_reboot_file()
	if (fexists(reboot_file_path))
		fdel(reboot_file_path)

/world/Reboot()
	TgsReboot()
	shutdown_logging()
	shutdown_byond_tracy()
	disable_auxtools_debugger()
	Create_reboot_file()
	return ..()

/proc/Shutdown_server()
	Create_reboot_file()
	shutdown()

/proc/Reboot_server(var/retry)
	//ohno the map switcher is in the midst of compiling a new map, we gotta wait for that to finish
	if (mapSwitcher.locked)
		//we're already holding and in the reboot retry loop, do nothing
		if (mapSwitcher.holdingReboot && !retry) return

		boutput(world, "<span class='bold notice'>Attempted to reboot but the server is currently switching maps. Please wait. (Attempt [mapSwitcher.currentRebootAttempt + 1]/[mapSwitcher.rebootLimit])</span>")
		message_admins("Reboot interrupted by a map-switch compile to [mapSwitcher.next]. Retrying in [mapSwitcher.rebootRetryDelay / 10] seconds.")

		mapSwitcher.holdingReboot = 1
		SPAWN(mapSwitcher.rebootRetryDelay)
			mapSwitcher.attemptReboot()

		return

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
	save_intraround_eggs()
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
	Shutdown_server()
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

	var/doShutdown = FALSE

	if (world.installUpdate())
		ehjax.sendAll(clients, "browseroutput", "updaterestart")
		#ifdef LIVE_SERVER
		logTheThing(LOG_DIARY, null, "Updates found, triggering shutdown", "debug")
		doShutdown = TRUE
		#endif

	if (!doShutdown)
		//if the server has a hard-reboot file, we trigger a shutdown (server supervisor process will restart the server after)
		//this is to avoid memory leaks from leaving the server running for long periods
		if (fexists(global.hardRebootFilePath))
			//Tell client browserOutput that we're hard rebooting, so it can handle manual auto-reconnection
			ehjax.sendAll(clients, "browseroutput", "hardrestart")
			logTheThing(LOG_DIARY, null, "Hard reboot file detected, triggering shutdown instead of reboot.", "debug")
			message_admins("Hard reboot file detected, triggering shutdown instead of reboot. (The server will auto-restart don't worry)")
			doShutdown = TRUE
		else
			//Tell client browserOutput that a restart is happening RIGHT NOW
			ehjax.sendAll(clients, "browseroutput", "roundrestart")

	if (doShutdown)
		Shutdown_server()
	else
		world.Reboot()


/world/proc/installUpdate()
	if (!config.update_check_enabled) return FALSE
	#ifdef LIVE_SERVER
	// On live servers, supervisor process will install updates on game boot
	if (length(flist("update/")))
		return TRUE
	#else

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

		if (world.system_type == UNIX && shell())
			shell("find ./tools -type f -name '*.sh' -o -name 'dc' -exec chmod +x {} \\;")

		logTheThing(LOG_DIARY, null, "Update complete.", "admin")
		return TRUE
	else
		logTheThing(LOG_DIARY, null, "No update found. Skipping update process.", "admin")

	#endif
	return FALSE


/// EXPERIMENTAL STUFF

/world/Del()
	shutdown_byond_tracy()
	disable_auxtools_debugger()
	. = ..()
