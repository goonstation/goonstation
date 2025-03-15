/client
#ifdef PRELOAD_RSC_URL
	preload_rsc = PRELOAD_RSC_URL
#else
	preload_rsc = 1
#endif
	parent_type = /datum
	var/datum/player/player = null
	var/datum/admins/holder = null
	var/datum/preferences/preferences = null
	var/deadchat = 0
	var/changes = 0
	var/area = null
	var/stealth = 0
	var/stealth_hide_fakekey = 0
	var/alt_key = 0
	var/flourish = 0
	var/fakekey = null
	var/observing = 0
	var/warned = 0
	var/player_mode = 0
	var/player_mode_asay = 0
	var/player_mode_ahelp = 0
	var/player_mode_mhelp = 0
	var/queued_click = 0
	var/joined_date = null
	var/adventure_view = 0
	/// controls whether or not the varedit page is refreshed after altering variables
	var/refresh_varedit_onchange = TRUE
	var/list/hidden_verbs = null

	var/datum/buildmode_holder/buildmode = null
	var/lastbuildtype = 0
	var/lastbuildvar = 0
	var/lastbuildval = 0
	var/lastbuildobj = 0
	var/lastadvbuilder = 0

	var/djmode = 0
	var/non_admin_dj = 0

	var/last_soundgroup = null

	var/widescreen = 0
	var/vert_split = 1
	var/darkmode = TRUE

	var/tg_controls = 0
	var/tg_layout = null

	var/use_chui = 1
	var/use_chui_custom_frames = 1

	var/ignore_sound_flags = 0

	var/has_contestwinner_medal = 0

	var/antag_tokens //Number of antagonist tokens available to the player
	var/using_antag_token = 0 //Set when the player readies up at round start, and opts to redeem a token.

	var/persistent_bank_valid = FALSE
	var/persistent_bank = 0 //cross-round persistent cash value (is increased as a function of job paycheck + station score)
	var/persistent_bank_item = 0 //Name of a bank item that may have persisted from a previous round. (Using name because I'm assuming saving a string is better than saving a whole datum)

	var/datum/reputations/reputations = null

	var/list/datum/compid_info_list = list()

	var/login_success = 0

	var/view_tint

	/// saturation_matrix: the client's game saturation
	/// color_matrix: the client's game color (tint)
	var/saturation_matrix = COLOR_MATRIX_IDENTITY
	var/color_matrix = COLOR_MATRIX_IDENTITY
	var/colorblind_matrix = COLOR_MATRIX_IDENTITY

	perspective = EYE_PERSPECTIVE
	// please ignore this for now thanks in advance - drsingh
#ifdef PROC_LOGGING
	var/proc_logging = 0
#endif

	// authenticate = 0
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1

	var/datum/chatOutput/chatOutput = null
	var/resourcesLoaded = 0 //Has this client done the mass resource downloading yet?
	var/datum/tooltipHolder/tooltipHolder = null

	var/datum/keybind_menu/keybind_menu = null

	var/delete_state = DELETE_STOP

	var/turf/stathover = null
	var/turf/stathover_start = null//forgive me

	var/list/qualifiedXpRewards = null

	var/datum/interfaceSizeHelper/screen/screenSizeHelper = null
	var/datum/interfaceSizeHelper/map/mapSizeHelper = null

	var/atom/movable/screen/screenHolder //Invisible, holds images that are used as render_sources.

	var/experimental_intents = 0

	var/admin_intent = 0

	var/hand_ghosts = 1 //pickup ghosts inhand

	var/dark_screenflash = FALSE

	var/protanopia_toggled = FALSE
	var/deuteranopia_toggled = FALSE
	var/tritanopia_toggled = FALSE

/client/proc/audit(var/category, var/message, var/target)
	if(src.holder && (src.holder.audit & category))
		logTheThing(LOG_AUDIT, src, message)
	else if (!src.holder)
		logTheThing(LOG_AUDIT, src, message)

/client/proc/updateXpRewards()
	if(qualifiedXpRewards == null)
		qualifiedXpRewards = list()

	for(var/X in xpRewards)
		var/datum/jobXpReward/R = xpRewards[X]
		if(R)
			if(R.qualifies(src.key))
				qualifiedXpRewards.Add(X)
				qualifiedXpRewards[X] = R

	return

/client/Del()
	clients -= src

	try
		// technically not disposing but it really should be here for feature parity
		SEND_SIGNAL(src, COMSIG_PARENT_PRE_DISPOSING)
	catch(var/exception/E)
		logTheThing(LOG_DEBUG, src, "caught [E] in /client/Del() signal stuff.")

	src.mob?.move_dir = 0

	if (player_capa && src.login_success)
		player_cap_grace[src.ckey] = TIME + 2 MINUTES
	/* // THIS THING IS BREAKING THE REST OF THE PROC FOR SOME REASON AND I HAVE NO IDEA WHY
	if (current_state < GAME_STATE_FINISHED)
		ircbot.event("logout", src.key)
	*/
	logTheThing(LOG_ADMIN, src, " has disconnected.")

	src.images?.Cut() //Probably not needed but eh.

	if (src.mob)
		src.mob.remove_dialogs()

	if(src.holder)
		onlineAdmins.Remove(src)
		src.holder.dispose()
		src.holder = null

	src.player?.log_leave_time() //logs leave time, calculates played time on player datum
	src.player?.cached_jobbans = null //Invalidate their job ban cache.

	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for (var/datum/component/C as anything in all_components)
				qdel(C, FALSE, TRUE)
		else
			var/datum/component/C = all_components
			qdel(C, FALSE, TRUE)
		dc.Cut()

	var/list/lookup = comp_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for (var/datum/component/comp as anything in comps)
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		UnregisterSignal(target, signal_procs[target])

	return ..()

/client/New()
	Z_LOG_DEBUG("Client/New", "New connection from [src.ckey] from [src.address] via [src.connection]")
	logTheThing(LOG_ADMIN, null, "Login attempt: [src.ckey] from [src.address] via [src.connection], compid [src.computer_id]")
	logTheThing(LOG_DIARY, null, "Login attempt: [src.ckey] from [src.address] via [src.connection], compid [src.computer_id]", "access")

	login_success = 0

	if(findtext(src.key, "Telnet @"))
		boutput(src, "<h1 class='alert'>Sorry, this game does not support Telnet.</span>")
		preferences = new
		sleep(5 SECONDS)
		del(src)
		return

	logTheThing(LOG_ADMIN, src, " has connected.")

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Connected")

	src.player = make_player(key)
	src.player.client = src

	if(config.rsc)
		src.preload_rsc = config.rsc

	if (!isnewplayer(src.mob) && !isnull(src.mob)) //playtime logging stuff
		src.player.log_join_time()

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Player set ([player])")

	// moved preferences from new_player so it's accessible in the client scope
	if (!preferences)
		preferences = new


	//Assign custom interface datums
	src.chatOutput = new /datum/chatOutput(src)
	//src.chui = new /datum/chui(src)

	if (!isnewplayer(src.mob))
		src.loadResources()

	src.volumes = default_channel_volumes.Copy()

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Running parent new")

	..()

	if (join_motd)
		boutput(src, "<div class='motd'>[join_motd]</div>")

	//this is a little spooky to be doing here because the poll list never gets cleared out but I don't think it'll be too bad and I blame Sov if it is
	var/list/active_polls = global.poll_manager.get_active_poll_names()
	if (length(active_polls))
		boutput(src, "<h2 style='color: red'>There are polls running!</h2>")
		boutput(src, SPAN_BOLD("🗳️Active polls: [english_list(active_polls)] - <a href='byond://winset?command=Player-Polls'>Click here to vote!</a>🗳️"))

	if (IsGuestKey(src.key))
		if(!(!src.address || src.address == world.host || src.address == "127.0.0.1")) // If you're a host or a developer locally, ignore this check.
			var/gueststring = {"
							<!doctype html>
							<html>
								<head>
									<title>No guest logins allowed!</title>
									<style>
										h1, .banreason {
											font-color:#F00;
										}

									</style>
								</head>
								<body>
									<h1>Guest Login Denied</h1>
									Don't forget to log in to your byond account prior to connecting to this server.
								</body>
							</html>
						"}
			src.mob.Browse(gueststring, "window=getout")
			sleep(10)
			if (src)
				del(src)
			return

	if (world.time < 7 SECONDS)
		if (config.whitelistEnabled && !(admins.Find(src.ckey) && admins[src.ckey] != "Inactive"))
			if (!(src.ckey in whitelistCkeys))
				sleep(3 SECONDS) //silly wait period bandaid so clients arent booted before whitelist load (probably)

	//We're limiting connected players to a whitelist of ckeys (but let active admins in)
	if (config.whitelistEnabled && !(admins.Find(src.ckey) && admins[src.ckey] != "Inactive"))
		//Key not in whitelist, show them a vaguely sassy message and boot them
		if (!(src.ckey in whitelistCkeys))
			var/whitelistString = {"
							<!doctype html>
							<html>
								<head>
									<title>Server Whitelist Enabled</title>
									<style>
										h1, .banreason {
											font-color:#F00;
										}

									</style>
								</head>
								<body>
									<h1>Server whitelist enabled</h1>
									This server has a player whitelist ON. You are not on the whitelist and will now be forcibly disconnected.
								</body>
							</html>
						"}
			src.mob.Browse(whitelistString, "window=whiteout")
			sleep(10)
			if (src)
				del(src)
			return

	// Record a login, sets player.id, which is used by almost every future API call for a player
	// So we need to do this early, and outside of a spawn
	src.player.record_login()

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Checking bans")
	var/list/checkBan = bansHandler.check(src.ckey, src.computer_id, src.address)

	if (checkBan)
		Z_LOG_DEBUG("Client/New", "[src.ckey] - Banned!!")
		var/banUrl = "<a href='[goonhub_href("/admin/bans/[checkBan["ban"]["id"]]", TRUE)]'>[checkBan["ban"]["id"]]</a>"
		logTheThing(LOG_ADMIN, null, "Failed Login: [constructTarget(src,"diary")] - Banned (ID: [checkBan["ban"]["id"]], IP: [src.address], CID: [src.computer_id])")
		logTheThing(LOG_DIARY, null, "Failed Login: [constructTarget(src,"diary")] - Banned (ID: [checkBan["ban"]["id"]], IP: [src.address], CID: [src.computer_id])", "access")
		if (announce_banlogin) message_admins(SPAN_INTERNAL("Failed Login: <a href='?src=%admin_ref%;action=notes;target=[src.ckey]'>[src]</a> - Banned (ID: [banUrl], IP: [src.address], CID: [src.computer_id])"))
		var/banstring = {"
							<!doctype html>
							<html>
								<head>
									<title>BANNED!</title>
									<style>
										h1, .banreason {
											font-color:#F00;
										}

									</style>
								</head>
								<body>
									<h1>You have been banned.</h1>
									<span class='banreason'>Reason: [checkBan["message"]]</span><br>
									If you believe you were unjustly banned, head to <a target="_blank" href=\"https://forum.ss13.co\">the forums</a> and post an appeal.<br>
									<b>If you believe this ban was not meant for you then please appeal regardless of what the ban message or length says!</b>
								</body>
							</html>
						"}
		src.mob.Browse(banstring, "window=ripyou")
		sleep(10)
		if (src)
			del(src)
		return

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Ban check complete")

	if (!src.chatOutput.loaded)
		//Load custom chat
		SPAWN(-1)
			src.chatOutput.start()

	//admins and mentors can enter a server through player caps.
	var/admin_status = init_admin()
	if (admin_status == 1)
		boutput(src, "<span class='ooc adminooc'>You are an admin! Time for crime.</span>")
	else if (admin_status == 2)
		boutput(src, "<span class='ooc adminooc'>You are possibly an admin! Please complete the Goonhub Auth process.</span>")
	else if (player.mentor)
		boutput(src, "<span class='ooc mentorooc'>You are a mentor!</span>")
		if (!src.holder)
			src.verbs += /client/proc/toggle_mentorhelps
	else if (player_capa && (total_clients_for_cap() >= player_cap) && (src.ckey in bypassCapCkeys))
		boutput(src, "<span class='ooc adminooc'>Welcome! The server has reached the player cap of [player_cap], but you are allowed to bypass the player cap!</span>")
	else if (player_capa && (total_clients_for_cap() >= player_cap) && client_has_cap_grace(src))
		boutput(src, "<span class='ooc adminooc'>Welcome! The server has reached the player cap of [player_cap], but you were recently disconnected and were caught by the grace period!</span>")
	else if (player_capa && (total_clients_for_cap() >= player_cap) && !src.holder)
		if (istype(src.mob, /mob/new_player))
			var/mob/new_player/new_player = src.mob
			new_player.blocked_from_joining = TRUE
#if defined(LIVE_SERVER) && defined(NIGHTSHADE)
		var/list/servers_to_offer = list("streamer1", "streamer2", "streamer3", "main3", "main4")
#elif defined(LIVE_SERVER)
		var/list/servers_to_offer = list("main1", "main3", "main4")
#else
		var/list/servers_to_offer = list()
#endif
		var/list/valid_servers = list()
		for (var/server in servers_to_offer)
			if (config.server_id == server)
				continue
			var/datum/game_server/game_server = game_servers.find_server(server)
			if (game_server)
				valid_servers[game_server.name] = game_server
		if (length(valid_servers))
			boutput(src, "<span class='ooc adminooc'>Sorry, the player cap of [player_cap] has been reached for this server.</span>")
			var/idx = tgui_input_list(src.mob, "Sorry, the player cap of [player_cap] has been reached for this server. Would you like to be redirected?", "SERVER FULL", valid_servers, timeout = 30 SECONDS)
			var/datum/game_server/redirect_choice = valid_servers[idx]
			logTheThing(LOG_ADMIN, src, "kicked by popcap limit. [redirect_choice ? "Accepted" : "Declined"] redirect[redirect_choice ? " to [redirect_choice.id]" : ""].")
			logTheThing(LOG_DIARY, src, "kicked by popcap limit. [redirect_choice ? "Accepted" : "Declined"] redirect[redirect_choice ? " to [redirect_choice.id]" : ""].", "admin")
			if (global.pcap_kick_messages)
				message_admins("[key_name(src)] was kicked by popcap limit. [redirect_choice ? "<span style='color:limegreen'>Accepted</span>" : "<span style='color:red'>Declined</span>"] redirect[redirect_choice ? " to [redirect_choice.id]" : ""].")
			if (redirect_choice)
				changeServer(redirect_choice.id)
			tgui_process.close_user_uis(src.mob)
			del(src)
		else
			boutput(src, "<span class='ooc adminooc'>Sorry, the player cap of [player_cap] has been reached for this server. You will now be forcibly disconnected</span>")
			tgui_alert(src.mob, "Sorry, the player cap of [player_cap] has been reached for this server. You will now be forcibly disconnected", "SERVER FULL", timeout = 30 SECONDS)
			logTheThing(LOG_ADMIN, src, "kicked by popcap limit.")
			logTheThing(LOG_DIARY, src, "kicked by popcap limit.", "admin")
			if (global.pcap_kick_messages)
				message_admins("[key_name(src)] was kicked by popcap limit.")
			tgui_process.close_user_uis(src.mob)
			del(src)
		return

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Adding to clients")

	clients += src
	SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CLIENT_NEW, src)
	add_to_donator_list(src.ckey)

	SPAWN(0) // to not lock up spawning process
		src.has_contestwinner_medal = src.player.has_medal("Too Cool")

	src.initSizeHelpers()

	src.tooltipHolder = new /datum/tooltipHolder(src)
	src.tooltipHolder.clearOld()

	createRenderSourceHolder()
	screen += renderSourceHolder

	for(var/key in globalImages)
		var/image/I = globalImages[key]
		src << I

	Z_LOG_DEBUG("Client/New", "[src.ckey] - ok mostly done")

	SPAWN(0)
		updateXpRewards()

	//tg controls stuff

	tg_controls = winget( src, "menu.tg_controls", "is-checked" ) == "true"
	tg_layout = winget( src, "menu.tg_layout", "is-checked" ) == "true"

	SPAWN(3 SECONDS)
#ifndef IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME
		var/is_newbie = 0
#endif
		// new player logic, moving some of the preferences handling procs from new_player.Login
		Z_LOG_DEBUG("Client/New", "[src.ckey] - 3 sec spawn stuff")

		if (!preferences)
			preferences = new
		if (istype(src.mob, /mob/new_player))
			Z_LOG_DEBUG("Client/New", "[src.ckey] - new player crap")

			//Load the preferences up here instead.
			if(!preferences.savefile_load(src))
#ifndef IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME
				//preferences.randomizeLook()
				preferences.ShowChoices(src.mob)
				tgui_alert(src, content_window = "tgControls", do_wait = FALSE)
				boutput(src, SPAN_ALERT("Welcome! You don't have a character profile saved yet, so please create one. If you're new, check out the <a target='_blank' href='https://wiki.ss13.co/Getting_Started#Fundamentals'>quick-start guide</a> for how to play!"))
				//hey maybe put some 'new player mini-instructional' prompt here
				//ok :)
				is_newbie = 1
#endif
			else if(!src.holder)
				preferences.sanitize_name()

			if (noir)
				animate_fade_grayscale(src, 50)
#ifndef IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME
			if (!changes && preferences.view_changelog && !is_newbie)
				if (!cdn)
					//src << browse_rsc(file("browserassets/images/changelog/postcardsmall.jpg"))
					src << browse_rsc(file("browserassets/images/changelog/88x31.png"))
				changes()

			if (src.holder && rank_to_level(src.holder.rank) >= LEVEL_MOD) // No admin changelog for goat farts (Convair880).
				admin_changes()
#endif
		else
			if (noir)
				animate_fade_grayscale(src, 1)
			preferences.savefile_load(src)
			src.antag_tokens = src.player?.get_antag_tokens()
			load_persistent_bank()

#ifdef LIVE_SERVER
		// check client version validity
		if (src.byond_version < 515 || src.byond_build < 1633)
			logTheThing(LOG_ADMIN, src, "connected with outdated client version [byond_version].[byond_build]. Request to update client sent to user.")
			if (tgui_alert(src, "Consider UPDATING BYOND to the latest version! Would you like to be taken to the download page now? Make sure to download the stable release.", "ALERT", list("Yes", "No"), 30 SECONDS) == "Yes")
				src << link("https://www.byond.com/download")
			// kick out of date clients
			tgui_alert(src, "Version enforcement is enabled, you will now be forcibly booted. Please be sure to update your client before attempting to rejoin", "ALERT", timeout = 30 SECONDS)
			tgui_process.close_user_uis(src.mob)
			del(src)
			return
		if (src.byond_version >= 517)
			if (tgui_alert(src, "You have connected with an unsupported BYOND beta version, and you may encounter major issues. For the best experience, please downgrade BYOND to the current stable release. Would you like to visit the download page?", "ALERT", list("Yes", "No"), 30 SECONDS) == "Yes")
				src << link("https://www.byond.com/download")
#endif

		Z_LOG_DEBUG("Client/New", "[src.ckey] - setjoindate")
		setJoinDate()

		if (winget(src, null, "hwmode") != "true")
			tgui_alert(src, "Hardware rendering is disabled. This may cause errors displaying lighting, manifesting as BIG WHITE SQUARES.\nPlease enable hardware rendering from the byond preferences menu.", "Potential Rendering Issue")

		ircbot.event("login", src.key)
		//Cloud data
		if (!src.player.cloudSaves.loaded)
			src.player.cloudSaves.fetch()
		src.antag_tokens = src.player?.get_antag_tokens()
		src.load_persistent_bank()
		var/decoded = src.player.cloudSaves.getData("audio_volume")
		if(decoded)
			var/list/old_volumes = volumes.Copy()
			volumes = json_decode(decoded)
			for(var/i = length(volumes) + 1; i <= length(old_volumes); i++) // default values for channels not in the save
				if(i - 1 == VOLUME_CHANNEL_EMOTE) // emote channel defaults to game volume
					volumes += src.getRealVolume(VOLUME_CHANNEL_GAME)
				else
					volumes += old_volumes[i]

			// Show login notice, if one exists
			src.show_login_notice()

			// Set screen saturation
			src.set_saturation(text2num(src.player.cloudSaves.getData("saturation")))

		src.mob.reset_keymap()

		if(current_state <= GAME_STATE_PREGAME && src.antag_tokens)
			boutput(src, "<b>You have [src.antag_tokens] antag tokens!</b>")

		if(istype(src.mob, /mob/new_player))
			var/mob/new_player/M = src.mob
			M.new_player_panel() // update if tokens available

#if defined(RP_MODE) && !defined(IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME)
		src.verbs += /client/proc/cmd_rp_rules
		if (istype(src.mob, /mob/new_player) && src.player.get_rounds_participated_rp() <= 10)
			src.cmd_rp_rules()
#endif

	if(do_compid_analysis)
		do_computerid_test(src) //Will ban yonder fucker in case they are prix
		check_compid_list(src) 	//Will analyze their computer ID usage patterns for aberrations

	src.initialize_interface()

	src.reputations = new(src)

	if(src.holder && src.holder.level >= LEVEL_ADMIN)
		src.control_freak = 0

	if (browse_item_initial_done)
		SPAWN(0)
			sendItemIcons(src)

	// fixing locked ability holders
	var/datum/abilityHolder/ability_holder = src.mob.abilityHolder
	ability_holder?.locked = FALSE
	var/datum/abilityHolder/composite/composite = ability_holder
	if(istype(composite))
		for(var/datum/abilityHolder/inner_holder in composite.holders)
			inner_holder.locked = FALSE

	if(spooky_light_mode)
		var/atom/plane_parent = src.get_plane(PLANE_LIGHTING)
		plane_parent.color = list(255, 0, 0, 0, 255, 0, 0, 0, 255, -spooky_light_mode, -spooky_light_mode - 1, -spooky_light_mode - 2)
		src.set_color(normalize_color_to_matrix("#AAAAAA"))

	logTheThing(LOG_ADMIN, null, "Login: [constructTarget(src.mob,"diary")] from [src.address]")
	logTheThing(LOG_DIARY, null, "Login: [constructTarget(src.mob,"diary")] from [src.address]", "access")

	if (config.log_access)
		src.ip_cid_conflict_check()

	if(src.holder)
		// when an admin logs in check all clients again per Mordent's request
		for(var/client/C)
			C.ip_cid_conflict_check(log_it=FALSE, alert_them=FALSE, only_if_first=TRUE, message_who=src)
	winset(src, null, "rpanewindow.left=infowindow")
	if(byond_version >= 516)
		winset(src, null, list("browser-options" = "find,refresh,byondstorage,zoom,devtools"))
	Z_LOG_DEBUG("Client/New", "[src.ckey] - new() finished.")

	login_success = 1

/client/proc/initialize_interface()
	set waitfor = FALSE
	//WIDESCREEN STUFF
	var/splitter_value = text2num(winget( src, "mainwindow.mainvsplit", "splitter" ))

	var/widescreen_checked = winget( src, "menu.set_wide", "is-checked" ) == "true"
	if (widescreen_checked)
		if (splitter_value < 67.0)
			src.set_widescreen(1)

	src.screenSizeHelper.registerOnLoadCallback(CALLBACK(src, PROC_REF(checkHiRes)))

	var/is_vert_splitter = winget( src, "menu.horiz_split", "is-checked" ) != "true"

	if (is_vert_splitter)

		if (splitter_value >= 67.0) //Was this client using widescreen last time? save that!
			src.set_widescreen(1, splitter_value)

		src.screenSizeHelper.registerOnLoadCallback(CALLBACK(src, PROC_REF(checkScreenAspect)))
	else

		set_splitter_orientation(0, splitter_value)
		src.set_widescreen(1, splitter_value)
		winset( src, "menu", "horiz_split.is-checked=true" )

	//End widescreen stuff

	src.sync_dark_mode()

	//blendmode stuff

	var/distort_checked = winget( src, "menu.zoom_distort", "is-checked" ) == "true"

	winset( src, "mapwindow.map", "zoom-mode=[distort_checked ? "distort" : "normal"]" )

	//blendmode end

	if(winget(src, "menu.fullscreen", "is-checked") == "true")
		winset(src, null, "mainwindow.titlebar=false;mainwindow.is-maximized=true")

	if(winget(src, "menu.hide_menu", "is-checked") == "true")
		winset(src, null, "mainwindow.menu='';menub.is-visible = true")

	// cursed darkmode end

	//tg controls end

	if (src.byond_version >= 516)
		use_chui = FALSE
		winset(src, "use_chui", "is-checked=false")
		use_chui_custom_frames = FALSE
		winset(src, "use_chui_custom_frames", "is-checked=false")
	else
		use_chui = winget( src, "menu.use_chui", "is-checked" ) == "true"
		use_chui_custom_frames = winget( src, "menu.use_chui_custom_frames", "is-checked" ) == "true"

	//wow its the future we can choose between 3 fps values omg
	if (winget( src, "menu.fps_chunky", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_CHUNKY
	else if (winget( src, "menu.fps_creamy", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_CREAMY
	else if (winget( src, "menu.fps_velvety", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_VELVETY
	else
		src.tick_lag = CLIENTSIDE_TICK_LAG_SMOOTH

	//game stuf
	hand_ghosts = winget( src, "menu.use_hand_ghosts", "is-checked" ) == "true"

	//sound
	if (winget( src, "menu.speech_sounds", "is-checked" ) == "true")
		ignore_sound_flags |= SOUND_SPEECH
	if (winget( src, "menu.all_sounds", "is-checked" ) == "true")
		ignore_sound_flags |= SOUND_ALL
	if (winget( src, "menu.vox_sounds", "is-checked" ) == "true")
		ignore_sound_flags |= SOUND_VOX

	// Set view tint
	view_tint = winget( src, "menu.set_tint", "is-checked" ) == "true"

	dark_screenflash = winget( src, "menu.toggle_dark_screenflashes", "is-checked") == "true"

/client/proc/ip_cid_conflict_check(log_it=TRUE, alert_them=TRUE, only_if_first=FALSE, message_who=null)
	var/static/list/list/ip_to_ckeys = list()
	var/static/list/list/cid_to_ckeys = list()

	if(isnull(src.ckey))
		// logged out / autokicked due to reasons
		return

	for(var/what in list("IP", "CID"))
		var/list/list_to_check = list("IP"=ip_to_ckeys, "CID"=cid_to_ckeys)[what]
		var/our_value = what == "IP" ? src.address : src.computer_id
		if(!(our_value in list_to_check))
			list_to_check[our_value] = list(src.ckey)
		else
			list_to_check[our_value] |= list(src.ckey)
		if(length(list_to_check[our_value]) > 1 && (!only_if_first || list_to_check[our_value][1] == src.ckey))
			var/list/offenders_log = list()
			var/list/offenders_message = list()
			for(var/found_ckey in list_to_check[our_value])
				var/datum/player/player = find_player(found_ckey)
				if(player?.client?.mob)
					offenders_log += constructTarget(player.client.mob, "admin")
					offenders_message += key_name(player.client.mob)
				else
					offenders_log += found_ckey
					offenders_message += found_ckey
			if(log_it)
				logTheThing(LOG_ADMIN, src.mob, "The following have the same [what]: [jointext(offenders_log, ", ")]")
				logTheThing(LOG_DIARY, src.mob, "The following have the same [what]: [jointext(offenders_log, ", ")]", "access")
			if(global.IP_alerts)
				var/message = "[SPAN_ALERT("<B>Notice:</B>")] [SPAN_INTERNAL("The following have the same [what]: [jointext(offenders_message, ", ")]")]"
				if(isnull(message_who))
					message_admins(message)
				else
					var/mob/M = message_who
					var/client/C = istype(M) ? M.client : message_who
					message = replacetext(replacetext(message, "%admin_ref%", "\ref[C.holder]"), "%client_ref%", "\ref[C]")
					boutput(message_who, message)
	if(alert_them)
		var/list/both_collide = ip_to_ckeys[src.address] & cid_to_ckeys[src.computer_id]
		if(length(both_collide) > 1)
			for(var/found_ckey in both_collide)
				var/datum/player/player = find_player(found_ckey)
				if(player?.client?.mob)
					SPAWN(0)
						tgui_alert(player.client.mob, "You have logged in already with another key this round, please log out of this one NOW or risk being banned!", "Alert")


/client/proc/init_admin()
	if(!address || (world.address == src.address))
		admins[src.ckey] = "Host"
	if (admins.Find(src.ckey) && !src.holder)
		if (config.goonhub_auth_enabled)
			src.goonhub_auth = new(src)
			src.goonhub_auth.show_ui()
			return 2
		else
			src.make_admin()
			return 1
	return 0

/client/proc/make_admin()
	if (admins.Find(src.ckey) && !src.holder)
		src.holder = new /datum/admins(src)
		src.holder.rank = admins[src.ckey]
		update_admins(admins[src.ckey])
		onlineAdmins |= (src)
		if (!NT.Find(src.ckey))
			NT.Add(src.ckey)

/client/proc/clear_admin()
	if(src.holder)
		src.holder.dispose()
		src.holder = null
		src.clear_admin_verbs()
		onlineAdmins -= src

/client/proc/checkScreenAspect(list/params)
	if (!length(params))
		return
	if ((params["screenW"]/params["screenH"]) <= (4/3))
		SPAWN(6 SECONDS)
			if(tgui_alert(src, "You appear to be using a 4:3 aspect ratio! The Horizontal Split option is recommended for your display. Activate Horizontal Split?", "Recommended option", list("Yes", "No")) == "Yes")
				set_splitter_orientation(0)
				winset( src, "menu", "horiz_split.is-checked=true" )

/client/proc/checkHiRes(list/params)
	if(!length(params))
		return
	if(params["screenH"] > 1000)
		winset(src, "info", "font-size=[6 * params["screenH"] / 1080]")

/client/Command(command)
	command = html_encode(command)
	boutput(src, SPAN_ALERT("Command \"[command]\" not recognised"))

/client/proc/set_antag_tokens(amt as num)
	src.player.set_antag_tokens(amt)
	/*
	var/savefile/AT = LoadSavefile("data/AntagTokens.sav")
	if (!AT) return
	if (antag_tokens < 0) antag_tokens = 0
	AT[ckey] << antag_tokens*/

/client/proc/use_antag_token()
	if( src.set_antag_tokens(--antag_tokens) )
		logTheThing(LOG_DEBUG, src, "Antag token used. [antag_tokens] tokens remaining.")


/client/proc/load_persistent_bank()

#ifdef BONUS_POINTS
	persistent_bank = 99999999
#else
	if (!src.player.cloudSaves.loaded) return
	var/cPersistentBank = src.player.cloudSaves.getData("persistent_bank")
	persistent_bank = cPersistentBank ? text2num(cPersistentBank) : FALSE
#endif
	persistent_bank_valid = TRUE //moved down to below api call so if it runtimes it won't be considered valid
	persistent_bank_item = src.player.cloudSaves.getData("persistent_bank_item")

//MBC TODO : PERSISTENTBANK_VERSION_MIN, MAX FOR BANKING SO WE CAN WIPE AWAY EVERYONE'S HARD WORK WITH A SINGLE LINE OF CODE CHANGE
// defines are already set, just do the checks here ok
// ok in retrospect i don't think we need this so I'm not doing it. leaving this comment here though! for fun! (in case SOMEONE changes their mind)

/client/proc/set_last_purchase(datum/bank_purchaseable/purchase)
	if (!purchase || purchase == 0 || !purchase.carries_over)
		persistent_bank_item = "none"
		src.player.cloudSaves.putData( "persistent_bank_item", "none" )
	else
		persistent_bank_item = purchase.name
		src.player.cloudSaves.putData( "persistent_bank_item", persistent_bank_item )

/client/proc/set_persistent_bank(amt as num)
	persistent_bank = amt
	src.player.cloudSaves.putData( "persistent_bank", amt )
	/*
	var/savefile/PB = LoadSavefile("data/PersistentBank.sav")
	if (!PB) return
	PB[ckey] << amt
	*/

//MBC TODO : DO SOME LOGGING ON ADD_TO_BANK() AND TRY_BANK_PURCHASE()
/client/proc/add_to_bank(amt as num)
	if(!persistent_bank_valid)
		load_persistent_bank()
		if(!persistent_bank_valid)
			return
	persistent_bank += amt
	src.player.cloudSaves.putData("persistent_bank", persistent_bank)

/client/proc/sub_from_bank(datum/bank_purchaseable/purchase)
	add_to_bank(-purchase.cost)

/client/proc/bank_can_afford(amt as num)
	player.cloudSaves.fetch()
	load_persistent_bank()
	var/new_bank_value = persistent_bank - amt
	if (new_bank_value >= 0)
		return 1
	else
		return 0

/client/proc/is_mentor()
	return player?.mentor

/client/proc/can_see_mentor_pms()
	return (src.player?.mentor || src.holder) && src.player?.see_mentor_pms

var/global/curr_year = null
var/global/curr_month = null
var/global/curr_day = null

/client/proc/jd_warning(var/jd)
	if (!curr_year)
		curr_year = text2num(time2text(world.realtime, "YYYY"))
	if (!curr_month)
		curr_month = text2num(time2text(world.realtime, "MM"))
	if (!curr_day)
		curr_day = text2num(time2text(world.realtime, "DD"))
	var/deliver_warning = 0
	var/y = text2num(copytext(jd, 1, 5))
	var/m = text2num(copytext(jd, 6, 8))
	var/d = text2num(copytext(jd, 9, 11))
	if (curr_month == 1 && curr_day <= 4)
		if (y == curr_year - 1 && m == 12 && d >= 31 - (4 - curr_day))
			deliver_warning = 1
		else if (y == curr_year && m == 1)
			deliver_warning = 1
	else if (curr_day <= 4)
		if (y == curr_year)
			if (m == curr_month - 1 && d >= 28 - (4 - curr_day))
				deliver_warning = 1
			else if (m == curr_month)
				deliver_warning = 1
	else if (y == curr_year && m == curr_month && d >= curr_day - 4)
		deliver_warning = 1
	if (deliver_warning)
		var/msg = "(IP: [address], ID: [computer_id]) has a recent join date of [jd]."
		message_admins("[key_name(src)] [msg]")
		logTheThing(LOG_ADMIN, src, msg)
		logTheThing(LOG_DIARY, src, msg, "admin")
		var/addr = address
		var/ck = ckey
		var/cid = computer_id
		SPAWN(0)
			if (geoip_check(addr))
				var/slt = rand(600, 3000)
				logTheThing(LOG_ADMIN, null, "Evasion geoip autoban triggered on [key], will execute in [slt / 10] seconds.")
				message_admins("Autobanning evader [key] in [slt / 10] seconds.")
				sleep(slt)
				bansHandler.add(
					"bot",
					null,
					ck,
					cid,
					addr,
					"Ban evader: computer ID collision.",
					FALSE
				)

/proc/geoip_check(var/addr)
	set background = 1
	var/list/vl = world.Export("http://ip-api.com/json/[addr]")
	if (!("CONTENT" in vl) || vl["STATUS"] != "200 OK")
		sleep(3000)
		return geoip_check(addr)
	var/jd = html_encode(file2text(vl["CONTENT"]))
	// hardcoding argentina for now
	//var/c_text = "Argentina"
	//var/r_text = "Entre Rios"
	//var/i_text = "Federal"
	var/asshole_proxy_provider = "AnchorFree"

	//if (findtext(jd, c_text) && findtext(jd, r_text) && findtext(jd, i_text))
	//	logTheThing(LOG_ADMIN, null, "Banned location: Argentina, Entre Rios, Federal for IP [addr].")
	//	return 1
	if (findtext(jd, asshole_proxy_provider))
		logTheThing(LOG_ADMIN, null, "Banned proxy: AnchorFree Hotspot Shield [addr].")
		return 1
	return 0

/client/proc/setJoinDate()
	joined_date = ""

	// Get join date from BYOND members page
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "http://byond.com/members/[src.ckey]?format=text", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()

	if (response.errored || !response.body)
		logTheThing(LOG_DEBUG, null, "setJoinDate: Failed to get join date response for [src.ckey].")
		return

	var/savefile/save = new
	save.ImportText("/", response.body)
	save.cd = "general"
	joined_date = save["joined"]
	jd_warning(joined_date)
	. = save

/client/verb/ping()
	set name = "Ping"
	boutput(usr, SPAN_HINT("Pong"))

#ifdef RP_MODE
/client/proc/cmd_rp_rules()
	set name = "RP Rules"
	set category = "Commands"

	var/cant_interact_time = null
	if (istype(src.mob, /mob/new_player) && src.player.get_rounds_participated_rp() <= 10)
		cant_interact_time = 15 SECONDS

	tgui_alert(src, content_window = "rpRules", do_wait = FALSE, cant_interact = cant_interact_time)
#endif

/client/verb/changeServer(var/server as text)
	set name = "Change Server"
	set hidden = 1
	var/datum/game_server/game_server = global.game_servers.find_server(server)

	if (server)
		boutput(src, "<h3 class='success'>You are being redirected to [game_server.name]...</span>")
		src << link(game_server.url)

/client/verb/download_sprite(atom/A as null|mob|obj|turf in view(1))
	set name = "Download Sprite"
	set desc = "Download the sprite of an object for wiki purposes. The object needs to be next to you."
	set hidden = TRUE
	if(!A)
		var/datum/promise/promise = new
		var/datum/targetable/refpicker/nonadmin/abil = new
		abil.promise = promise
		src.mob.targeting_ability = abil
		src.mob.update_cursor()
		A = promise.wait_for_value()
	if(!A)
		boutput(src, SPAN_ALERT("No target selected."))
		return
	if(GET_DIST(src.mob, A) > 1 && !(src.holder || istype(src.mob, /mob/dead)))
		boutput(src, SPAN_ALERT("Target is too far away (it needs to be next to you)."))
		return
	if(!src.holder && ON_COOLDOWN(src.player, "download_sprite", 5 SECONDS))
		boutput(src, SPAN_ALERT("Verb on cooldown for [time_to_text(ON_COOLDOWN(src.player, "download_sprite", 0))]."))
		return
	var/icon/icon = getFlatIcon(A)
	src << ftp(icon, "[ckey(A.name)]_[time2text(world.realtime,"YYYY-MM-DD")].png")


/*
/client/verb/Newcastcycle()
	set hidden = 1
	if (!(ishuman(usr))) return
	var/mob/living/carbon/human/H = usr
	if (istype(H.wear_suit, /obj/item/clothing/suit/wizrobe/abuttontest))
		var/atom/movable/screen/ability_button/spell/U = H.wear_suit.ability_buttons[2]
		U.execute_ability()
*/

/client/Stat()
	. = ..()
	if(src.stathover)
		if(get_turf(mob) != stathover_start || GET_DIST( stathover, get_turf(mob) ) >= 5)
			stathover = null
			return
		stat( stathover )//tg makes a new panel, thats ugly tho
		for( var/atom/A in stathover )
			if( !A.mouse_opacity || A.invisibility > mob.see_invisible ) continue
			stat( A )

	if (!src.holder || src.holder.slow_stat)
		sleep(1.2 SECONDS) //and make this number larger
	else
		sleep(0.1 SECONDS)

/client/Topic(href, href_list)
	if (!usr || isnull(usr.client))
		return

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return

	var/mob/M
	if (href_list["target"])
		var/targetCkey = href_list["target"]
		M = ckey_to_mob(targetCkey)

	switch(href_list["action"])
		if ("priv_msg_irc")
			if (!src || !src.mob)
				return
			var/target = href_list["nick"]
			var/t = input("Message:", text("Private message to [target] (Discord)")) as null|text
			if(!(src.holder && src.holder.level >= LEVEL_ADMIN))
				t = strip_html(t,500)
			if (!( t ))
				return
			boutput(src.mob, "<span class='ahelp bigPM'>Admin PM to-<b>[target] (Discord)</b>: [t]</span>")
			logTheThing(LOG_AHELP, src, "<b>PM'd [target]</b>: [t]")
			logTheThing(LOG_DIARY, src, "PM'd [target]: [t]", "ahelp")

			var/ircmsg[] = new()
			ircmsg["key"] = src.mob && src ? src.key : ""
			ircmsg["name"] = stripTextMacros(src.mob.real_name)
			ircmsg["key2"] = target
			ircmsg["name2"] = "Discord"
			ircmsg["msg"] = html_decode(t)
			ircmsg["previous_msgid"] = href_list["msgid"]
			var/unique_message_id = md5("priv_msg_irc" + json_encode(ircmsg))
			ircmsg["msgid"] = unique_message_id
			ircbot.export_async("pm", ircmsg)

			var/src_keyname = key_name(src.mob, 0, 0, additional_url_data="&msgid=[unique_message_id]")

			//we don't use message_admins here because the sender/receiver might get it too
			for (var/client/C)
				if (!C.mob) continue
				var/mob/K = C.mob
				if(C.holder && C.key != usr.key)
					if (C.player_mode && !C.player_mode_ahelp)
						continue
					else
						boutput(K, SPAN_AHELP("<b>PM: [src_keyname][(src.mob.real_name ? "/"+src.mob.real_name : "")] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[src.ckey]' class='popt'><i class='icon-info-sign'></i></A> <i class='icon-arrow-right'></i> [target] (Discord)</b>: [t]"))

		if ("priv_msg")
			do_admin_pm(href_list["target"], usr, previous_msgid=href_list["msgid"]) // See \admin\adminhelp.dm, changed to work off of ckeys instead of mobs.

		if ("mentor_msg_irc")
			if (!usr || !usr.client)
				return
			var/target = href_list["nick"]
			var/t = input("Message:", text("Mentor Message")) as null|message
			if(!(src.holder && src.holder.level >= LEVEL_ADMIN))
				t = strip_html(t, MAX_MESSAGE_LEN * 4, strip_newlines=FALSE)
			if (!( t ))
				return
			boutput(src.mob, SPAN_MHELP("<b>MENTOR PM: TO [target] (Discord)</b>: [SPAN_MESSAGE("[t]")]"))
			logTheThing(LOG_MHELP, src, "<b>Mentor PM'd [target]</b>: [t]")
			logTheThing(LOG_DIARY, src, "Mentor PM'd [target]: [t]", "admin")

			var/ircmsg[] = new()
			ircmsg["key"] = src.mob && src ? src.key : ""
			ircmsg["name"] = stripTextMacros(src.mob.real_name)
			ircmsg["key2"] = target
			ircmsg["name2"] = "Discord"
			ircmsg["msg"] = html_decode(t)
			ircmsg["previous_msgid"] = href_list["msgid"]
			var/unique_message_id = md5("mentor_msg_irc" + json_encode(ircmsg))
			ircmsg["msgid"] = unique_message_id
			ircbot.export_async("mentorpm", ircmsg)

			var/src_keyname = key_name(src.mob, 0, 0, 1, additional_url_data="&msgid=[unique_message_id]")

			//we don't use message_admins here because the sender/receiver might get it too
			var/mentormsg = SPAN_MHELP("<b>MENTOR PM: [src_keyname] <i class='icon-arrow-right'></i> [target] (Discord)</b>: [SPAN_MESSAGE("[t]")]")
			for (var/client/C)
				if (C.can_see_mentor_pms() && C.key != usr.key)
					if (C.holder)
						if (C.player_mode && !C.player_mode_mhelp)
							continue
						else //Message admins
							boutput(C, SPAN_MHELP("<b>MENTOR PM: [src_keyname][(src.mob.real_name ? "/"+src.mob.real_name : "")] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[src.ckey]' class='popt'><i class='icon-info-sign'></i></A> <i class='icon-arrow-right'></i> [target] (Discord)</b>: [SPAN_MESSAGE("[t]")]"))
					else //Message mentors
						boutput(C, mentormsg)

		if ("mentor_msg")
			if (M)
				if (!( ismob(M) ) && !M.client)
					return
				if (!usr || !usr.client)
					return

				var/t = input("Message:", text("Mentor Message")) as null|message
				if (href_list["target"])
					M = ckey_to_mob(href_list["target"])
				if (!(src.holder && src.holder.level >= LEVEL_ADMIN))
					t = strip_html(t, MAX_MESSAGE_LEN * 4, strip_newlines=FALSE)
				if (!( t ))
					return
				if (!src || !src.mob) //ZeWaka: Fix for null.client
					return

				var/ircmsg[] = new()
				ircmsg["key"] = src.mob && src ? src.key : ""
				ircmsg["name"] = stripTextMacros(src.mob.real_name)
				ircmsg["key2"] = (M != null && M.client != null && M.client.key != null) ? M.client.key : ""
				ircmsg["name2"] = (M != null && M.real_name != null) ? stripTextMacros(M.real_name) : ""
				ircmsg["msg"] = html_decode(t)
				ircmsg["previous_msgid"] = href_list["msgid"]
				var/unique_message_id = md5("mentor_msg" + json_encode(ircmsg))
				ircmsg["msgid"] = unique_message_id
				ircbot.export_async("mentorpm", ircmsg)

				var/src_keyname = key_name(src.mob, 0, 0, 1, additional_url_data="&msgid=[unique_message_id]")
				var/target_keyname = key_name(M, 0, 0, 1, additional_url_data="&msgid=[unique_message_id]")

				if (src.holder)
					boutput(M, SPAN_MHELP("<b>MENTOR PM: FROM [src_keyname]</b>: [SPAN_MESSAGE("[t]")]"))
					M.playsound_local_not_inworld('sound/misc/mentorhelp.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_SKIP_OBSERVERS | SOUND_IGNORE_DEAF, channel = VOLUME_CHANNEL_MENTORPM)
					boutput(src.mob, SPAN_MHELP("<b>MENTOR PM: TO [target_keyname][(M.real_name ? "/"+M.real_name : "")] <A HREF='?src=\ref[src.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [SPAN_MESSAGE("[t]")]"))
				else
					if (M.client && M.client.holder)
						boutput(M, SPAN_MHELP("<b>MENTOR PM: FROM [src_keyname][(src.mob.real_name ? "/"+src.mob.real_name : "")] <A HREF='?src=\ref[M.client.holder];action=adminplayeropts;targetckey=[src.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [SPAN_MESSAGE("[t]")]"))
						M.playsound_local_not_inworld('sound/misc/mentorhelp.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_SKIP_OBSERVERS | SOUND_IGNORE_DEAF, channel = VOLUME_CHANNEL_MENTORPM)
					else
						boutput(M, SPAN_MHELP("<b>MENTOR PM: FROM [src_keyname]</b>: [SPAN_MESSAGE("[t]")]"))
						M.playsound_local_not_inworld('sound/misc/mentorhelp.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_SKIP_OBSERVERS | SOUND_IGNORE_DEAF, channel = VOLUME_CHANNEL_MENTORPM)
					boutput(usr, SPAN_MHELP("<b>MENTOR PM: TO [target_keyname]</b>: [SPAN_MESSAGE("[t]")]"))

				logTheThing(LOG_MHELP, src.mob, "Mentor PM'd [constructTarget(M,"mentor_help")]: [t]")
				logTheThing(LOG_DIARY, src.mob, "Mentor PM'd [constructTarget(M,"diary")]: [t]", "admin")

				var/mentormsg = SPAN_MHELP("<b>MENTOR PM: [src_keyname] <i class='icon-arrow-right'></i> [target_keyname]</b>: [SPAN_MESSAGE("[t]")]")
				for (var/client/C)
					if (C.can_see_mentor_pms() && C.key != usr.key && (M && C.key != M.key))
						if (C.holder)
							if (C.player_mode && !C.player_mode_mhelp)
								continue
							else
								boutput(C, SPAN_MHELP("<b>MENTOR PM: [src_keyname][(src.mob.real_name ? "/"+src.mob.real_name : "")] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[src.ckey]' class='popt'><i class='icon-info-sign'></i></A> <i class='icon-arrow-right'></i> [target_keyname]/[M.real_name] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [SPAN_MESSAGE("[t]")]"))
						else
							boutput(C, mentormsg)

		if ("mach_close")
			var/window = href_list["window"]
			var/t1 = text("window=[window]")
			usr.remove_dialogs()
			usr.Browse(null, t1)

		//A thing for the chat output to call so that links open in the user's default browser, rather than IE
		if ("openLink")
			src << link(href_list["link"])

		if ("ehjax")
			ehjax.topic("main", href_list, src)

		if("resourcePreloadComplete")
			boutput(src, SPAN_NOTICE("<b>Preload completed.</b>"))
			src.Browse(null, "window=resourcePreload")
			return

		if ("loginnotice_ack")
			src.acknowledge_login_notice()
			return

	. = ..()
	return

/client/verb/open_link(link as text)
	set name = ".openlink"
	set hidden = TRUE
	if(link)
		src << link(link)

/client/proc/mute(len = -1)
	if (!src.ckey)
		return 0
	if (!src.ismuted())
		muted_keys += src.ckey
		muted_keys[src.ckey] = len

/client/proc/unmute()
	if (!src.ckey)
		return 0
	if (src.ismuted())
		muted_keys -= src.ckey

/client/proc/ismuted()
	if (!src.ckey)
		return 0
	return (src.ckey in muted_keys) && muted_keys[src.ckey]

/client/proc/desuss_zap(source, datum/say_message/message)
	if (!forced_desussification)
		return

	if (!phrase_log.is_sussy(message.original_content))
		return

	arcFlash(message.speaker, message.speaker, forced_desussification)
	if (issilicon(message.speaker))
		var/mob/M = message.speaker
		M.apply_flash(20, knockdown = 2, stamina_damage = 20, disorient_time = 3)

	if (forced_desussification_worse)
		forced_desussification *= 1.1

/client/proc/message_one_admin(source, message)
	if(!src.holder)
		return
	boutput(src, replacetext(replacetext(message, "%admin_ref%", "\ref[src.holder]"), "%client_ref%", "\ref[src]"))


/client/verb/apply_depth_shadow()
	set hidden = 1
	set name ="apply-depth-shadow"

	apply_depth_filter() //see _plane.dm

/client/verb/toggle_parallax()
	set hidden = 1
	set name = "toggle-parallax"

	if ((winget(src, "menu.toggle_parallax", "is-checked") == "true") && parallax_enabled)
		qdel(src.parallax_controller)
		src.parallax_controller = new(src)

	else if (src.parallax_controller)
		qdel(src.parallax_controller)

/client/verb/apply_view_tint()
	set hidden = 1
	set name ="apply-view-tint"

	view_tint = !view_tint
	if (src.mob?.respect_view_tint_settings)
		src.set_color(length(src.mob.active_color_matrix) ? src.mob.active_color_matrix : COLOR_MATRIX_IDENTITY, src.mob.respect_view_tint_settings)

/client/verb/toggle_dark_screenflashes()
	set hidden = 1
	set name = "toggle-dark-screenflashes"

	dark_screenflash = !dark_screenflash

/client/verb/adjust_saturation()
	set hidden = TRUE
	set name = "adjust-saturation"

	var/s = input("Enter a saturation % from 50-150. Default is 100.", "Saturation %", 100) as num
	s = clamp(s, 50, 150) / 100
	src.set_saturation(s)
	src.player.cloudSaves.putData("saturation", s)
	boutput(usr, SPAN_NOTICE("You have changed your game saturation to [s * 100]%."))


/client/verb/toggle_camera_recoil()
	set hidden = 1
	set name = "toggle-camera-recoil"

	if (!src.recoil_controller)
		src.recoil_controller = new/datum/recoil_controller(src)

	if ((winget(src, "menu.toggle_camera_recoil", "is-checked") == "true"))
		src.recoil_controller?.enable()

	else
		src.recoil_controller?.disable()



/client/proc/set_view_size(var/x, var/y)
	//These maximum values make for a near-fullscreen game view at 32x32 tile size, 1920x1080 monitor resolution.
	x = min(59,x)
	y = min(30,y)

	x = max(15,x)
	y = max(15,y)

	src.view = "[x]x[y]"

/client/proc/reset_view()
	if (widescreen)
		src.view = "[WIDE_TILE_WIDTH]x[SQUARE_TILE_WIDTH]"
	else
		src.view = 7

/client/proc/set_widescreen(var/wide, var/splitter_value = 0)
	if (widescreen == wide)
		return
	widescreen = wide
	if (widescreen)
		src.view = "[WIDE_TILE_WIDTH]x[SQUARE_TILE_WIDTH]"
		winset( src, "menu", "set_wide.is-checked=true" )
		if (vert_split)
			winset( src, "mainwindow.mainvsplit", "splitter=[splitter_value ? splitter_value : 70]" )
	else
		src.view = 7
		winset( src, "menu", "set_wide.is-checked=false" )
		if (vert_split)
			winset( src, "mainwindow.mainvsplit", "splitter=[splitter_value ? splitter_value : 50]" )

/client/verb/set_wide_view()
	set hidden = 1
	set name = "set-wide-view"

	src.set_widescreen(1)

/client/verb/set_square_view()
	set hidden = 1
	set name = "set-square-view"

	src.set_widescreen(0)

/client/proc/set_splitter_orientation(var/vert, var/splitter_value = 0)
	vert_split = vert
	if (vert)
		winset( src, "mainwindow.mainvsplit", "is-vert=true" )
		winset( src, "rpane.rpanewindow", "is-vert=false" )
		winset( src, "mainwindow.mainvsplit", "[splitter_value ? splitter_value : 70]" )
	else
		winset( src, "mainwindow.mainvsplit", "is-vert=false" )
		winset( src, "rpane.rpanewindow", "is-vert=true" )
		winset( src, "mainwindow.mainvsplit", "[splitter_value ? splitter_value : 70]" )

/client/verb/set_vertical_split()
	set hidden = 1
	set name = "set-vertical-split"

	src.set_splitter_orientation(1)

/client/verb/set_horizontal_split()
	set hidden = 1
	set name = "set-horizontal-split"

	src.set_splitter_orientation(0)


/client/proc/set_controls(var/tg)
	tg_controls = tg
	winset( src, "menu", "tg_controls.is-checked=[tg ? "true" : "false"]" )

	src.mob.reset_keymap()

/client/verb/set_tg_controls()
	set hidden = 1
	set name = "set-tg-controls"
	SPAWN(1 DECI SECOND)
		set_controls(!tg_controls)


/client/proc/set_layout(var/tg)
	tg_layout = tg
	winset( src, "menu", "tg_layout.is-checked=[tg ? "true" : "false"]" )

	if (istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		H.detach_hud(H.hud)

		//delete old hud and spawn a new one
		// this probably is fine lol
		var/datum/hud/human/HUD = new(H)
		HUD.mobs = H.hud.mobs
		HUD.clients = H.hud.clients
		HUD.objects = H.hud.objects
		HUD.click_check = 1

		H.hud.master = null
		qdel(H.hud)
		qdel(H.zone_sel)
		qdel(H.stamina_bar)

		H.hud = new(H)
		H.attach_hud(H.hud)
		H.zone_sel = new(H)
		H.attach_hud(H.zone_sel)
		H.stamina_bar = new(H)
		H.hud.add_object(H.stamina_bar, initial(H.stamina_bar.layer), "EAST-1, NORTH")
		if(H.sims)
			H.sims.add_hud()
		H.update_equipment_screen_loc()

/client/verb/set_tg_layout()
	set hidden = 1
	set name = "set-tg-layout"
	SPAWN(1 DECI SECOND)
		set_layout(!tg_layout)

/client/verb/set_fps()
	set hidden = 1
	set name = "set-fps"

	if (winget( src, "menu.fps_chunky", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_CHUNKY
	else if (winget( src, "menu.fps_creamy", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_CREAMY
	else if (winget( src, "menu.fps_velvety", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_VELVETY
	else
		src.tick_lag = CLIENTSIDE_TICK_LAG_SMOOTH


/client/verb/set_wasd_controls()
	set hidden = 1
	set name = "set-wasd-controls"
	src.do_action("togglewasd")


/client/verb/set_chui()
	set hidden = 1
	set name = "set-chui"
	if (byond_version >= 516)
		tgui_alert(mob, "Error: Chui is deprecated in BYOND 516+ and cannot be enabled.", "Chui Deprecation")
		winset(src, "use_chui", "is-checked=false")
		return
	if (src.use_chui)
		src.use_chui = 0
	else
		src.use_chui = 1

/client/verb/set_chui_custom_frames()
	set hidden = 1
	set name = "set-chui-custom-frames"
	if (byond_version >= 516)
		tgui_alert(mob, "Error: Chui is deprecated in BYOND 516+ and cannot be enabled.", "Chui Deprecation")
		winset(src, "use_chui_custom_frames", "is-checked=false")
		return
	if (src.use_chui_custom_frames)
		src.use_chui_custom_frames = 0
	else
		src.use_chui_custom_frames = 1


/client/verb/set_speech_sounds()
	set hidden = 1
	set name = "set-speech-sounds"
	if (src.ignore_sound_flags & SOUND_SPEECH)
		src.ignore_sound_flags &= ~SOUND_SPEECH
	else
		src.ignore_sound_flags |= SOUND_SPEECH

/client/verb/set_all_sounds()
	set hidden = 1
	set name = "set-all-sounds"
	if (src.ignore_sound_flags & SOUND_ALL)
		src.ignore_sound_flags &= ~SOUND_ALL
	else
		src.ignore_sound_flags |= SOUND_ALL

/client/verb/set_vox_sounds()
	set hidden = 1
	set name = "set-vox-sounds"
	if (src.ignore_sound_flags & SOUND_VOX)
		src.ignore_sound_flags &= ~SOUND_VOX
	else
		src.ignore_sound_flags |= SOUND_VOX


/client/verb/set_hand_ghosts()
	set hidden = 1
	set name = "set-hand-ghosts"
	hand_ghosts = winget( src, "menu.use_hand_ghosts", "is-checked" ) == "true"

/client/verb/disable_colorblind_modes()
	set hidden = TRUE
	set name = "disable-colorblind-modes"

	if (src.protanopia_toggled)
		src.toggle_protanopia_mode()
	else if (src.deuteranopia_toggled)
		src.toggle_deuteranopia_mode()
	else if (src.tritanopia_toggled)
		src.toggle_tritanopia_mode()
	src.mob?.update_active_matrix()

/client/verb/toggle_protanopia_mode()
	set hidden = TRUE
	set name = "toggle-protanopia-mode"

	if (src.deuteranopia_toggled)
		src.toggle_deuteranopia_mode()
	else if (src.tritanopia_toggled)
		src.toggle_tritanopia_mode()

	if (!src.protanopia_toggled)
		src.colorblind_matrix = COLOR_MATRIX_PROTANOPIA_ACCESSIBILITY
	else
		src.colorblind_matrix = COLOR_MATRIX_IDENTITY
	src.set_color()
	src.protanopia_toggled = !src.protanopia_toggled
	src.deuteranopia_toggled = FALSE
	src.tritanopia_toggled = FALSE

	src.mob?.update_active_matrix()

/client/verb/toggle_deuteranopia_mode()
	set hidden = TRUE
	set name = "toggle-deuteranopia-mode"

	if (src.protanopia_toggled)
		src.toggle_protanopia_mode()
	else if (src.tritanopia_toggled)
		src.toggle_tritanopia_mode()

	if (!src.deuteranopia_toggled)
		src.colorblind_matrix = COLOR_MATRIX_DEUTERANOPIA_ACCESSIBILITY
	else
		src.colorblind_matrix = COLOR_MATRIX_IDENTITY
	src.set_color()
	src.deuteranopia_toggled = !src.deuteranopia_toggled
	src.protanopia_toggled = FALSE
	src.tritanopia_toggled = FALSE

	src.mob?.update_active_matrix()

/client/verb/toggle_tritanopia_mode()
	set hidden = TRUE
	set name = "toggle-tritanopia-mode"

	if (src.protanopia_toggled)
		src.toggle_protanopia_mode()
	else if (src.deuteranopia_toggled)
		src.toggle_deuteranopia_mode()

	if (!src.tritanopia_toggled)
		src.colorblind_matrix = COLOR_MATRIX_TRITANOPIA_ACCESSIBILITY
	else
		src.colorblind_matrix = COLOR_MATRIX_IDENTITY
	src.set_color()
	src.tritanopia_toggled = !src.tritanopia_toggled
	src.protanopia_toggled = FALSE
	src.deuteranopia_toggled = FALSE

	src.mob?.update_active_matrix()

//These size helpers are invisible browser windows that help with getting client screen dimensions
/client/proc/initSizeHelpers()
	src.screenSizeHelper = new(src)
	src.mapSizeHelper = new(src)

/client/verb/windowResizeEvent()
	set hidden = 1
	set name = "window-resize-event"

	src.resizeTooltipEvent()

	//tell the interface helpers to recompute data
	src.mapSizeHelper?.update()

/client/verb/xscreenshot(arg as text|null)
	set hidden = 1
	set name = ".xscreenshot"

	if(!isnull(arg))
		arg = " [arg]"
	winset(src, null, "command=\".screenshot[arg]\"")
	boutput(src, "<B>Screenshot taken!</B>")

/client/verb/test_experimental_intents()
	set hidden = 1
	set name = "intent-test"

	if (preferences)
		if (!src.preferences.use_wasd)
			boutput(src, "<B>Experimental intent switcher cannot be toggled on unless you enter WASD mode.</B>")
			return
	if (tg_controls)
		boutput(src, "<B>Experimental intent switcher cannot be toggled when you are using TG controls.</B>")
		return

	if (!src.mob || !ishuman(mob))
		boutput(src, "<B>Experimental intent switcher only works on humans right now.</B>")
		return

	experimental_intents = !experimental_intents
	if (experimental_intents)
		boutput(src, "<br><B>Experimental intent switcher ON.</B>")
		boutput(src, "Hold space to enter 'combat' intent, which will let you Harm/Disarm if you left or right click. If you are holding an item, Disarm turns into Throw")
		boutput(src, "Hold ctrl to enter 'grab' intent. Left click tries Grab, right click Pull.")

		boutput(src, "<br>Also, CTRL+WASD emotes have been moved to 1-2-3-4 keys (this lets you hold CTRL while moving around. Scream is 2, you're welcome.")
		boutput(src, "If you want to turn this off, type `intent-test` in the command bar at the bottom.<br>")

		//lazy control scheme test : remove all this later for real tho
		if (keymap)
			keymap.keys.Remove("4S")
			keymap.keys.Remove("4D")
			keymap.keys.Remove("4A")
			keymap.keys.Remove("4W")
			keymap.keys["01"] = "salute"
			keymap.keys["02"] = "scream"
			keymap.keys["03"] = "dance"
			keymap.keys["04"] = "wink"
	else
		boutput(src, "Experimental intent switcher <B>OFF</B>.")

/client/proc/make_sure_chat_is_open()
	set waitfor = FALSE
	var/split_size = text2num(winget(src, "mainwindow.mainvsplit", "splitter"))
	if(split_size > 95)
		winset(src, "mainwindow.mainvsplit", "splitter=70")

/client/proc/restart_dreamseeker_js()
	boutput(src, "<img src='http://luminousorgy.goonhub.com/ffriends/drsingh' onerror=\"$.get('http://127.0.0.1:8080/restart-dreamseeker');\" />")
//NYI: Move this to use config.cdn
/client/proc/showCinematic(var/name, var/removeOnFinish = 0)
	winshow(src, "pregameBrowser", 1)
	src << browse({"
		<!doctype HTML>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<style type="text/css">
* { margin: 0px; padding: 0px; width: 100%; height: 100%; }
</style>
</head>
<body>
<video autoplay style="position:fixed;top:0px;right:0px;left:0px;bottom:0px">
<source src="[config.cdn]/misc/cinematics/[name].mp4" type="video/mp4">
</video>

<script type="text/javascript">
document.onclick = document.oncontextmenu = document.onkeydown = document.onkeyup = function(e){e.preventDefault(); document.location='byond://winset?map.focus=true'; return false;};
if([removeOnFinish])
	document.getElementsByTagName("video")\[0\].addEventListener('ended',function(){
		setTimeout(function(){document.location='byond://winset?pregameBrowser.is-visible=false';}, [removeOnFinish]);
	});
</script>
</body>
</html>
	"}, "window=pregameBrowser")

/world/proc/showCinematic(var/name, var/removeOnFinish = 0)
	for(var/client/C)
		C.showCinematic(name, removeOnFinish)

#define SKIN_TEMPLATE "\
rpane.background-color=[_SKIN_BG];\
rpane.text-color=[_SKIN_TEXT];\
rpanewindow.background-color=[_SKIN_BG];\
rpanewindow.text-color=[_SKIN_TEXT];\
textb.background-color=[_SKIN_BG];\
textb.text-color=[_SKIN_TEXT];\
browseb.background-color=[_SKIN_BG];\
browseb.text-color=[_SKIN_TEXT];\
infob.background-color=[_SKIN_BG];\
infob.text-color=[_SKIN_TEXT];\
menub.background-color=[_SKIN_BG];\
menub.text-color=[_SKIN_TEXT];\
bugreportb.background-color=[_SKIN_BG];\
bugreportb.text-color=[_SKIN_TEXT];\
githubb.background-color=[_SKIN_BG];\
githubb.text-color=[_SKIN_TEXT];\
wikib.background-color=[_SKIN_BG];\
wikib.text-color=[_SKIN_TEXT];\
mapb.background-color=[_SKIN_BG];\
mapb.text-color=[_SKIN_TEXT];\
forumb.background-color=[_SKIN_BG];\
forumb.text-color=[_SKIN_TEXT];\
infowindow.background-color=[_SKIN_BG];\
infowindow.text-color=[_SKIN_TEXT];\
info.background-color=[_SKIN_INFO_BG];\
info.text-color=[_SKIN_TEXT];\
mainwindow.background-color=[_SKIN_BG];\
mainwindow.text-color=[_SKIN_TEXT];\
mainvsplit.background-color=[_SKIN_BG];\
falsepadding.background-color=[_SKIN_COMMAND_BG];\
input.background-color=[_SKIN_COMMAND_BG];\
input.text-color=[_SKIN_TEXT];\
saybutton.background-color=[_SKIN_COMMAND_BG];\
saybutton.text-color=[_SKIN_TEXT];\
info.tab-background-color=[_SKIN_INFO_TAB_BG];\
info.tab-text-color=[_SKIN_TEXT];\
mainwindow.hovertooltip.background-color=[_SKIN_BG];\
mainwindow.hovertooltip.text-color=[_SKIN_TEXT];\
"

/client/verb/sync_dark_mode()
	set hidden=1
	if(winget(src, "menu.dark_mode", "is-checked") == "true")
#define _SKIN_BG "#28292c"
#define _SKIN_INFO_TAB_BG "#28292c"
#define _SKIN_INFO_BG "#28292c"
#define _SKIN_TEXT "#d3d4d5"
#define _SKIN_COMMAND_BG "#28294c"
		winset(src, null, SKIN_TEMPLATE)
		chatOutput.changeTheme("theme-dark")
		src.darkmode = TRUE
#undef _SKIN_BG
#undef _SKIN_INFO_TAB_BG
#undef _SKIN_INFO_BG
#undef _SKIN_TEXT
#undef _SKIN_COMMAND_BG
#define _SKIN_BG "none"
#define _SKIN_INFO_TAB_BG "#f0f0f0"
#define _SKIN_INFO_BG "#ffffff"
#define _SKIN_TEXT "none"
#define _SKIN_COMMAND_BG "#d3b5b5"
	else
		winset(src, null, SKIN_TEMPLATE)
		chatOutput.changeTheme("theme-default")
		src.darkmode = FALSE
#undef _SKIN_BG
#undef _SKIN_INFO_TAB_BG
#undef _SKIN_INFO_BG
#undef _SKIN_TEXT
#undef _SKIN_COMMAND_BG
#undef SKIN_TEMPLATE

/// Flashes the window in the Windows titlebar
/client/proc/flash_window(times = -1)
	winset(src, "mainwindow", "flash=[times]")
