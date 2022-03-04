/datum/configuration
	var/server_key = null				// unique numeric identifier (e.g. 1, 2, 3) used by some backend services. NOT REQUIRED.
										//	if set, the global serverKey will be set to this, if not, it will be based on the world.port number

	var/server_id = "local"				// unique server identifier (e.g. main, rp, dev) used primarily by backend services
	var/server_name = null				// server name (for world name / status)
	var/server_suffix = 0				// generate numeric suffix based on server port
	var/server_region = null

	var/server_specific_configs = 0		// load extra config files (by port)

	var/update_check_enabled = 0				// Server will call world.Reboot after checking for update if this is on
	var/dmb_filename = "coolstation"

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

	var/allow_admin_jump = 1			// allows admin jumping
	var/allow_admin_sounds = 1			// allows admin sound playing
	var/allow_admin_spawning = 1		// allows admin item spawning
	var/allow_admin_rev = 1				// allows admin revives

	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/list/play_antag_rates = list()  // % of rounds players should get to play as X antag
	var/allow_ai = 1					// allow ai job
	var/respawn = 1
	var/require_job_exp = 0

	// opengoon Parser
	var/opengoon_parser_url = "localhost"
	var/opengoon_parser_key = "foo"

	// MySQL
	var/sql_enabled = 0
	var/sql_hostname = "localhost"
	var/sql_port = 3306
	var/sql_username = null
	var/sql_password = null
	var/sql_database = null

	// Server list for cross-bans and other stuff
	var/list/servers = list()
	var/crossbans = 0
	var/crossban_password = null

	//IRC Bot stuff
	var/irclog_url = null
	var/ircbot_api = null
	var/ircbot_ip = null

	// Comms stuff
	var/comms_key = null
	var/comms_name = null

	//External server configuration (for central bans etc)
	var/opengoon_api_version = 0
	var/opengoon_api_endpoint = null
	var/opengoon_api_secure_endpoint = null
	var/opengoon_api_ip = null
	var/opengoon_api_token = null

	var/youtube_enabled = 0

	var/weblog_viewer_url = null
	var/tutorial_url = null

	var/gitreports = null
	var/github_repo_url = null
	var/wiki_url = null
	var/rules_url = null
	var/forums_url = null
	var/map_webview_url = null

	var/enable_serverhop = null
	var/list/serverhop_servers = list()

	//banning panel routes.
	var/banpanel_base = null
	var/banpanel_get = null
	var/banpanel_prev = null

	//opengoon2 server
	var/opengoon2_hostname = null

	//Environment
	var/env = "dev"
	var/cdn = ""
	var/disableResourceCache = 0

	//Map switching stuff
	var/allow_map_switching = 0

	//Round min players
	var/blob_min_players = 0
	var/rev_min_players = 0
	var/spy_theft_min_players = 0

	//Rotating full logs saved to disk
	var/allowRotatingFullLogs = 0

	//Are we limiting connected players to certain ckeys?
	var/whitelistEnabled = 0
	var/whitelist_path = "config/whitelist.txt"

	var/enable_chat_filter = 0
	var/static/regex/filter_regex_ooc
	var/static/regex/filter_regex_ic

	var/midround_ooc = 0

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

		t = trim(t)
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

			if ("require_job_exp")
				config.require_job_exp = 1

			if ("serverkey")
				config.server_key = text2num(value)

			if ("serverid")
				config.server_id = trim(value)

			if ("servername")
				config.server_name = value

			if ("serversuffix")
				config.server_suffix = 1

			if ("serverregion")
				config.server_region = value

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

			if ("play_antag")
				var/rate_pos = findtext(value, " ")
				var/antag_name = null
				var/antag_rate = null

				if (rate_pos)
					antag_name = lowertext(copytext(value, 1, rate_pos))
					antag_rate = copytext(value, rate_pos + 1)
					config.play_antag_rates[antag_name] = text2num(antag_rate)
				else
					logDiary("Incorrect antag rate configuration definition: [antag_name]  [antag_rate].")

			if ("use_mysql")
				config.sql_enabled = 1

			if ("mysql_hostname")
				config.sql_hostname = trim(value)

			if ("mysql_port")
				config.sql_port = text2num(value)

			if ("mysql_username")
				config.sql_username = trim(value)

			if ("mysql_password")
				config.sql_password = trim(value)

			if ("mysql_database")
				config.sql_database = trim(value)

			if ("server_specific_configs")
				config.server_specific_configs = 1

			if ("servers")
				for(var/sv in splittext(trim(value), " "))
					sv = trim(sv)
					if(sv)
						config.servers.Add(sv)

			if ("use_crossbans")
				config.crossbans = 1
			if ("crossban_password")
				config.crossban_password = trim(value)

			if ("irclog_url")
				config.irclog_url = trim(value)
			if ("ircbot_api")
				config.ircbot_api = trim(value)
			if ("ircbot_ip")
				config.ircbot_ip = trim(value)

			if ("ticklag")
				world.tick_lag = text2num(value)

			if ("opengoon_api_version")
				config.opengoon_api_version = text2num(value)
			if ("opengoon_api_endpoint")
				config.opengoon_api_endpoint = trim(value)
			if ("opengoon_api_secure_endpoint")
				config.opengoon_api_secure_endpoint = trim(value)
			if ("opengoon_api_ip")
				config.opengoon_api_ip = trim(value)
			if ("opengoon_api_token")
				config.opengoon_api_token = trim(value)

			if ("comms_key")
				config.comms_key = trim(value)
			if ("comms_name")
				config.comms_name = trim(value)

			if ("youtube_enabled")
				config.youtube_enabled = 1

			if ("opengoon2_hostname")
				config.opengoon2_hostname = trim(value)

			if ("update_check_enabled")
				config.update_check_enabled = 1
			if ("dmb_filename")
				config.dmb_filename = trim(value)
			if ("env")
				config.env = trim(value)
			if ("cdn")
				config.cdn = trim(value)
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
				config.whitelistEnabled = 1

			if("weblog_viewer_url")
				config.weblog_viewer_url = trim(value)
			if("tutorial_url")
				config.tutorial_url = trim(value)

			if("gitreports")
				config.gitreports = trim(value)
			if("github_repo_url")
				config.github_repo_url = trim(value)
			if("wiki_url")
				config.wiki_url = trim(value)
			if("rules_url")
				config.rules_url = trim(value)
			if("forums_url")
				config.forums_url = trim(value)
			if("map_webview_url")
				config.map_webview_url = trim(value)

			if("enable_serverhop")
				if(!fexists("config/alt_servers.txt"))
					logDiary("No 'config/alt_servers.txt' file found")
					continue
				config.enable_serverhop = 1
				var/file = file2text("config/alt_servers.txt")
				var/list/content = splittext(file, "\n")

				for (var/line in content)
					if (!line)
						continue
					line = trim(line)
					if (length(line) == 0)
						continue
					else if (copytext(line, 1, 2) == "#")
						continue
					var/list/entry = splittext(line, "=")
					serverhop_servers[entry[1]] = entry[2]

			if("enable_chat_filter")
				enable_chat_filter = 1
				load_filters()

			if("banpanel_base")
				banpanel_base = trim(value)
			if("banpanel_get")
				banpanel_get = trim(value)
			if("banpanel_prev")
				banpanel_prev = trim(value)


			if ("whitelist_path")
				config.whitelist_path = trim(value)

			if ("midround_ooc")
				config.midround_ooc = 1

			else
				logDiary("Unknown setting in configuration: '[name]'")

	if (config.env == "dev")
		config.cdn = ""
		config.disableResourceCache = 1

/datum/configuration/proc/load_filters()
	var/list/filter_ooc = list()
	var/list/filter_ic = list()

	if(!fexists("config/chat_filter_ooc.txt")) //The IC filter is populated with OOC's words too, so it's fine if it doesn't exist
		logDiary("chat_filter_ooc.txt doesn't exist")
		return

	for(var/line in splittext(trim(rustg_file_read("config/chat_filter_ooc.txt")), "\n"))
		if(!line || findtextEx(line,"#",1,2))
			continue
		filter_ooc += REGEX_QUOTE(line)
		filter_ic += REGEX_QUOTE(line)

	filter_regex_ooc = filter_ooc.len ? regex("\\b([jointext(filter_ooc, "|")])\\b", "i") : null

	if(fexists("config/chat_filter_ic.txt"))
		for(var/line in splittext(trim(rustg_file_read("config/chat_filter_ic.txt")), "\n"))
			if(!line || findtextEx(line,"#",1,2))
				continue
			filter_ic += REGEX_QUOTE(line)

	filter_regex_ic = filter_ic.len ? regex("\\b([jointext(filter_ic, "|")])\\b", "i") : null

/datum/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for (var/T in childrentypesof(/datum/game_mode))
		var/datum/game_mode/M = new T()
		if (M.config_tag && M.config_tag == mode_name && getSpecialModeCase(mode_name))
			return M
		qdel(M)

	return new /datum/game_mode/extended // Let's fall back to extended! Better than erroring and having to manually restart.

/datum/configuration/proc/pick_random_mode()
	var/total = 0
	var/list/accum = list()
	var/list/avail_modes = list()

	for(var/M in src.modes)
		if (src.probabilities[M] && getSpecialModeCase(M))
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
		boutput(world, "Failed to pick a random game mode.")
		return null // This essentially will never happen (you'd have to not be able to choose any mode in secret), so it's okay to leave it null, I think

	//boutput(world, "Returning mode [mode_name]")
	message_admins("[mode_name] was chosen as the random game mode!")

	return src.pick_mode(mode_name)

/datum/configuration/proc/get_used_mode_names()
	var/list/names = list()

	for (var/M in src.modes)
		if (src.probabilities[M] > 0)
			names += src.mode_names[M]

	return names

//return 0 to block the mode from being chosen for whatever reason
/datum/configuration/proc/getSpecialModeCase(mode)
	switch (mode)
		if ("blob")
			if (src.blob_min_players > 0)
				var/players = 0
				for (var/mob/new_player/player in mobs)
					if (player.ready)
						players++

				if (players < src.blob_min_players)
					return 0

		if ("revolution")
			if (src.rev_min_players > 0)
				var/players = 0
				for (var/mob/new_player/player in mobs)
					if (player.ready)
						players++

				if (players < src.rev_min_players)
					return 0

		if ("spy_theft")
			if (src.spy_theft_min_players > 0)
				var/players = 0
				for (var/mob/new_player/player in mobs)
					if (player.ready)
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
	if(server_authorized.len == 0) return 1//TODO: Remove this?
	if(server_authorized.Find( ckey )) return 1
	return 0
