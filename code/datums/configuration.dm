/datum/configuration
	var/server_key = null				// unique numeric identifier (e.g. 1, 2, 3) used by some backend services. NOT REQUIRED.
										//	if set, the global serverKey will be set to this, if not, it will be based on the world.port number

	var/server_id = "local"				// unique server identifier (e.g. main, rp, dev) used primarily by backend services
	var/server_name = null				// server name (for world name / status)
	var/server_suffix = 0				// generate numeric suffix based on server port
	var/server_region = null
	var/server_on_hub = TRUE

	var/server_specific_configs = 0		// load extra config files (by port)

	var/update_check_enabled = 0				// Server will call world.Reboot after checking for update if this is on
	var/dmb_filename = "goonstation"

	var/medal_hub = null				// medal hub name
	var/medal_password = null			// medal hub password

	//Note: All logging configs are for logging to the diary out of game. Does not affect in-game logs!
	var/log_ooc = 0						// log OOC channel
	var/log_access = 0					// log login/logout
	var/log_say = 0						// log client say
	var/log_admin = 0					// log admin actions
	var/log_game = 0					// log game events
	var/log_whisper = 0					// log client whisper
	var/log_ahelp = 0					// log admin helps
	var/log_mhelp = 0					// log mentor helps
	var/log_combat = 0					// log combat events
	var/log_station = 0					// log station events (includes legacy build)
	var/log_telepathy = 0				// log telepathy events
	var/log_debug = 0					// log debug events
	var/log_vehicles = 0					//I feel like this is a better place for listing who entered what, than the admin log.
	var/log_gamemode = 0				// log gamemode events

	var/allow_admin_jump = 1			// allows admin jumping
	var/allow_admin_sounds = 1			// allows admin sound playing
	var/allow_admin_spawning = 1		// allows admin item spawning
	var/allow_admin_rev = 1				// allows admin revives

	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/allow_ai = 1					// allow ai job
	var/respawn = 1

	// MySQL
	var/sql_enabled = 0
	var/sql_hostname = "localhost"
	var/sql_port = 3306
	var/sql_username = null
	var/sql_password = null
	var/sql_database = null

	//IRC Bot stuff
	var/irclog_url = null
	var/ircbot_api = null
	var/ircbot_ip = null

	//External server configuration (for central bans etc)
	var/goonhub_url = "https://goonhub.com"
	var/goonhub_api_endpoint = null
	var/goonhub_api_ip = null
	var/goonhub_api_token = null

	var/goonhub_events_endpoint = null
	var/goonhub_events_port = null
	var/goonhub_events_channel = null
	var/goonhub_events_password = null

	//Environment
	var/env = "dev"
	var/cdn = ""
	var/rsc = null
	var/disableResourceCache = 0

	//Map switching stuff
	var/allow_map_switching = 0

	//Round min players
	var/blob_min_players = 0
	var/rev_min_players = 0
	var/spy_theft_min_players = 0

	//Rotating full logs saved to disk
	var/allowRotatingFullLogs = 0

	//Maximum number of 1kb TGUI chunks for large payloads
	var/tgui_max_chunk_count = 64

	/// Are we limiting connected players to certain ckeys?
	var/whitelistEnabled = 0
	var/baseWhitelistEnabled = 0 //! The config value of whitelistEnabled (actual value might be modified mid-round)
	var/roundsLeftWithoutWhitelist = -1 //! How many rounds are left without the whitelist being enabled
	var/whitelist_path = "config/whitelist.txt"

	//Which server can ghosts join by clicking on an on-screen link
	var/server_buddy_id = null

	var/already_loaded_once = FALSE

/datum/configuration/New()
	..()
	var/list/L = childrentypesof(/datum/game_mode)
	for (var/T in L)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if (M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				logDiary("Adding game mode [M.name] ([M.config_tag]) to configuration.")
				src.modes += M.config_tag
				src.mode_names[M.config_tag] = M.name
				src.probabilities[M.config_tag] = M.probability
				if (M.votable)
					src.votable_modes += M.config_tag
		qdel(M)

/datum/configuration/proc/load(filename)
	var/text = file2text(filename)

	if (!text)
		logDiary("No '[filename]' file found, setting defaults")
		src = new /datum/configuration()
		return

	logDiary("Reading configuration file '[filename]'")

	var/list/CL = splittext(text, "\n")

	for (var/t in CL)
		if (!t)
			continue

		t = trimtext(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if ("log_ooc")
				config.log_ooc = 1

			if ("log_access")
				config.log_access = 1

			if ("log_say")
				config.log_say = 1

			if ("log_admin")
				config.log_admin = 1

			if ("log_game")
				config.log_game = 1

			if ("log_whisper")
				config.log_whisper = 1

			if ("log_ahelp")
				config.log_ahelp = 1

			if ("log_mhelp")
				config.log_mhelp = 1

			if ("log_combat")
				config.log_combat = 1

			if ("log_station")
				config.log_station = 1

			if ("log_telepathy")
				config.log_telepathy = 1

			if ("log_debug")
				config.log_debug = 1

			if ("log_vehicles")
				config.log_vehicles = 1

			if ("log_gamemode")
				config.log_gamemode = 1

			if ("allow_admin_jump")
				config.allow_admin_jump = 1

			if ("allow_admin_sound")
				config.allow_admin_sounds = 1

			if ("allow_admin_rev")
				config.allow_admin_rev = 1

			if ("allow_admin_spawning")
				config.allow_admin_spawning = 1

			if ("allow_ai")
				config.allow_ai = 1

			if ("norespawn")
				config.respawn = 0

			if ("serverkey")
				config.server_key = text2num(value)

			if ("serverid")
				config.server_id = trimtext(value)

			if ("servername")
				config.server_name = value

			if ("serversuffix")
				config.server_suffix = 1

			if ("serverregion")
				config.server_region = value

			if ("server_on_hub")
				config.server_on_hub = text2num(value)
				world.visibility = config.server_on_hub

			if ("medalhub")
				config.medal_hub = value

			if ("medalpass")
				config.medal_password = value

			if ("probability")
				var/prob_pos = findtext(value, " ")
				var/prob_name = null
				var/prob_value = null

				if (prob_pos)
					prob_name = lowertext(copytext(value, 1, prob_pos))
					prob_value = copytext(value, prob_pos + 1)
					if (prob_name in config.modes)
						config.probabilities[prob_name] = text2num(prob_value)
					else
						logDiary("Unknown game mode probability configuration definition: [prob_name].")
				else
					logDiary("Incorrect probability configuration definition: [prob_name]  [prob_value].")

			if ("use_mysql")
				config.sql_enabled = 1

			if ("mysql_hostname")
				config.sql_hostname = trimtext(value)

			if ("mysql_port")
				config.sql_port = text2num(value)

			if ("mysql_username")
				config.sql_username = trimtext(value)

			if ("mysql_password")
				config.sql_password = trimtext(value)

			if ("mysql_database")
				config.sql_database = trimtext(value)

			if ("server_specific_configs")
				config.server_specific_configs = 1

			if ("irclog_url")
				config.irclog_url = trimtext(value)
			if ("ircbot_api")
				config.ircbot_api = trimtext(value)
			if ("ircbot_ip")
				config.ircbot_ip = trimtext(value)

			if ("ticklag")
				world.tick_lag = text2num(value)

			if ("goonhub_url")
				config.goonhub_url = trimtext(value)
			if ("goonhub_api_endpoint")
				config.goonhub_api_endpoint = trimtext(value)
			if ("goonhub_api_ip")
				config.goonhub_api_ip = trimtext(value)
			if ("goonhub_api_token")
				config.goonhub_api_token = trimtext(value)

			if ("goonhub_events_endpoint")
				config.goonhub_events_endpoint = trimtext(value)
			if ("goonhub_events_port")
				config.goonhub_events_port = trimtext(value)
			if ("goonhub_events_channel")
				config.goonhub_events_channel = trimtext(value)
			if ("goonhub_events_password")
				config.goonhub_events_password = trimtext(value)

			if ("update_check_enabled")
				config.update_check_enabled = 1
			if ("dmb_filename")
				config.dmb_filename = trimtext(value)
			if ("env")
				config.env = trimtext(value)
			if ("cdn")
				config.cdn = trimtext(value)
			if ("rsc")
				config.rsc = trimtext(value)
			if ("disable_resource_cache")
				config.disableResourceCache = 1

			//map switching
			if ("allow_map_switching")
				config.allow_map_switching = 1

			if ("blob_min_players")
				config.blob_min_players = text2num(value)

			if ("rev_min_players")
				config.rev_min_players = text2num(value)

			if ("spy_theft_min_players")
				config.spy_theft_min_players = text2num(value)

			if ("rotating_full_logs")
				config.allowRotatingFullLogs = 1

			if ("whitelist_enabled")
				config.whitelistEnabled = TRUE
				config.baseWhitelistEnabled = TRUE

			if ("whitelist_path")
				config.whitelist_path = trimtext(value)

			if ("server_buddy_id")
				config.server_buddy_id = trimtext(value)

			if ("tgui_max_chunk_count")
				config.tgui_max_chunk_count = text2num(value)

			else
				logDiary("Unknown setting in configuration: '[name]'")

	if (config.env == "dev")
		config.cdn = ""
		config.disableResourceCache = 1

	if(!already_loaded_once)
		roundsLeftWithoutWhitelist = world.load_intra_round_value("whitelist_disabled")
		if(roundsLeftWithoutWhitelist >= 0)
			roundsLeftWithoutWhitelist--
			world.save_intra_round_value("whitelist_disabled", roundsLeftWithoutWhitelist)

	if(roundsLeftWithoutWhitelist >= 0)
		config.whitelistEnabled = FALSE

	already_loaded_once = TRUE


/datum/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for (var/T in childrentypesof(/datum/game_mode))
		var/datum/game_mode/M = new T()
		if (M.config_tag && M.config_tag == mode_name && getSpecialModeCase(mode_name))
			return M
		qdel(M)

	return new /datum/game_mode/extended // Let's fall back to extended! Better than erroring and having to manually restart.

/datum/configuration/proc/pick_random_mode(list/exclusions = list())
	var/total = 0
	var/list/accum = list()
	var/list/avail_modes = list()

	for(var/M in src.modes)
		if (!exclusions.Find(M) && src.probabilities[M] && getSpecialModeCase(M))
			total += src.probabilities[M]
			avail_modes += M
			accum[M] = total

	var/r = total - (rand() * total)

	var/mode_name = null
	for (var/M in avail_modes)
		if (accum[M] >= r)
			mode_name = M
			break

	if (!mode_name)
		boutput(world, "<h1 class='alert>Failed to pick a random game mode.</h1>")
		return null // This essentially will never happen (you'd have to not be able to choose any mode in secret), so it's okay to leave it null, I think

	//boutput(world, "Returning mode [mode_name]")

	return src.pick_mode(mode_name)

/datum/configuration/proc/get_used_mode_names()
	. = list()
	for (var/M in src.modes)
		if (src.probabilities[M] > 0)
			. += src.mode_names[M]

//return 0 to block the mode from being chosen for whatever reason
/datum/configuration/proc/getSpecialModeCase(mode)
	switch (mode)
		if ("blob")
			if (map_setting == "NADIR")
				return 0

			if (src.blob_min_players > 0)
				var/players = 0
				for (var/mob/new_player/player in mobs)
					if (player.ready_play)
						players++

				if (players < src.blob_min_players)
					return 0

		if ("revolution")
			if (src.rev_min_players > 0)
				var/players = 0
				for (var/mob/new_player/player in mobs)
					if (player.ready_play)
						players++

				if (players < src.rev_min_players)
					return 0

		if ("spy_theft")
			if (src.spy_theft_min_players > 0)
				var/players = 0
				for (var/mob/new_player/player in mobs)
					if (player.ready_play)
						players++

				if (players < src.spy_theft_min_players)
					return 0

	return 1

//Hands off!
//Much love!
var/list/server_authorized = null
/client/proc/IsSecureAuthorized()
	if(!address) return 1//GO! BWAAAAH!!!
	if(!server_authorized)
		if(!fexists( "../authorized_keys.txt" )) return 1// oh no!
		server_authorized = splittext( file2text("../authorized_keys.txt"), ";" )
	if(length(server_authorized) == 0) return 1//TODO: Remove this?
	if(server_authorized.Find( ckey )) return 1
	return 0
