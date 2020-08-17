/client
	preload_rsc = 1
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
	var/pray_l = 0
	var/fakekey = null
	var/suicide = 0
	var/observing = 0
	var/warned = 0
	var/player_mode = 0
	var/player_mode_asay = 0
	var/player_mode_ahelp = 0
	var/player_mode_mhelp = 0
	var/only_local_looc = 0
	var/deadchatoff = 0
	var/local_deadchat = 0
	var/queued_click = 0
	var/joined_date = null
	var/adventure_view = 0
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

	var/tg_controls = 0
	var/tg_layout = 0

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

	var/chui/window/keybind_menu/keybind_menu = null

	var/delete_state = DELETE_STOP

	var/list/cloudsaves
	var/list/clouddata

	var/turf/stathover = null
	var/turf/stathover_start = null//forgive me

	var/list/qualifiedXpRewards = null

	var/datum/interfaceSizeHelper/screen/screenSizeHelper = null
	var/datum/interfaceSizeHelper/map/mapSizeHelper = null

	var/obj/screen/screenHolder //Invisible, holds images that are used as render_sources.

	var/experimental_intents = 0

	var/admin_intent = 0

	var/hand_ghosts = 1 //pickup ghosts inhand

/client/proc/audit(var/category, var/message, var/target)
	if(src.holder && (src.holder.audit & category))
		logTheThing("audit", src, target, message)

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
	if (player_capa && src.login_success)
		player_cap_grace[src.ckey] = TIME + 2 MINUTES

	if (current_state < GAME_STATE_FINISHED)
		ircbot.event("logout", src.key)

	logTheThing("admin", src, null, " has disconnected.")

	src.images.Cut() //Probably not needed but eh.

	if (src.mob)
		src.mob.remove_dialogs()

	clients -= src
	if(src.holder)
		onlineAdmins.Remove(src)
		src.holder.dispose()
		src.holder = null
	return ..()

/client/New()
	Z_LOG_DEBUG("Client/New", "New connection from [src.ckey] from [src.address] via [src.connection]")
	logTheThing("diary", null, src, "Login attempt: [src.ckey] from [src.address] via [src.connection], compid [src.computer_id]", "access")

	login_success = 0

	if(findtext(src.key, "Telnet @"))
		boutput(src, "Sorry, this game does not support Telnet.")
		sleep(5 SECONDS)
		del(src)
		return

	logTheThing("admin", src, null, " has connected.")

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Connected")

	player = find_player(key)
	if (!player)
		player = make_player(key)
	player.client = src

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Player set ([player])")

	//Assign custom interface datums
	src.chatOutput = new /datum/chatOutput(src)
	//src.chui = new /datum/chui(src)

	//Should eliminate any local resource loading issues with chui windows
	if (!cdn && !(!address || (world.address == src.address)))
		var/list/chuiResources = list(
			"browserassets/js/jquery.min.js",
			"browserassets/js/jquery.nanoscroller.min.js",
			"browserassets/js/chui/chui.js",
			"browserassets/js/errorHandler.js",
			"browserassets/css/fonts/fontawesome-webfont.eot",
			"browserassets/css/fonts/fontawesome-webfont.svg",
			"browserassets/css/fonts/fontawesome-webfont.ttf",
			"browserassets/css/fonts/fontawesome-webfont.woff",
			"browserassets/css/font-awesome.css"
		)
		src.loadResourcesFromList(chuiResources)

	if (!istype(src.mob, /mob/new_player))
		src.loadResources()

/*
	SPAWN_DBG(rand(4,18))
		if(proxy_check(src.address))
			logTheThing("diary", null, src, "Failed Login: [constructTarget(src,"diary")] - Using a Tor Proxy Exit Node", "access")
			if (announce_banlogin) message_admins("<span class='internal'>Failed Login: [src] - Using a Tor Proxy Exit Node (IP: [src.address], ID: [src.computer_id])</span>")
			boutput(src, "You may not connect through TOR.")
			SPAWN_DBG(0) del(src)
			return
*/

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Running parent new")

	..()

	if (join_motd)
		boutput(src, "<div class=\"motd\">[join_motd]</div>")

	if (IsGuestKey(src.key))
		if(!src.address || src.address == world.host)
			world.log << ("Hello host or developer person! You're not logged into BYOND. Fix this so you can test your feature turned bug!")
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

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Checking bans")
	var/isbanned = checkBan(src.ckey, src.computer_id, src.address, record = 1)

	if (isbanned)
		Z_LOG_DEBUG("Client/New", "[src.ckey] - Banned!!")
		logTheThing("diary", null, src, "Failed Login: [constructTarget(src,"diary")] - Banned", "access")
		if (announce_banlogin) message_admins("<span class='internal'>Failed Login: <a href='?src=%admin_ref%;action=notes;target=[src.ckey]'>[src]</a> - Banned (IP: [src.address], ID: [src.computer_id])</span>")
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
									<span class='banreason'>Reason: [isbanned].</span><br>
									If you believe you were unjustly banned, head to <a href=\"https://forum.ss13.co\">the forums</a> and post an appeal.
								</body>
							</html>
						"}
		src.mob.Browse(banstring, "window=ripyou")
		sleep(10)
		if (src)
			del(src)
		return

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Ban check complete")

	//admins and mentors can enter a server through player caps.
	if (init_admin())
		boutput(src, "<span class='ooc adminooc'>You are an admin! Time for crime.</span>")
	else if (player.mentor)
		boutput(src, "<span class='ooc mentorooc'>You are a mentor!</span>")
		if (!src.holder)
			src.verbs += /client/proc/toggle_mentorhelps
	else if (player_capa && (total_clients_for_cap() >= player_cap) && (src.ckey in bypassCapCkeys))
		boutput(src, "<span class='ooc adminooc'>Welcome! The server has reached the player cap of [player_cap], but you are allowed to bypass the player cap!</span>")
	else if (player_capa && (total_clients_for_cap() >= player_cap) && client_has_cap_grace(src))
		boutput(src, "<span class='ooc adminooc'>Welcome! The server has reached the player cap of [player_cap], but you were recently disconnected and were caught by the grace period!</span>")
	else if(player_capa && (total_clients_for_cap() >= player_cap) && !src.holder)
		boutput(src, "<span class='ooc adminooc'>I'm sorry, the player cap of [player_cap] has been reached for this server. You will now be forcibly disconnected</span>")
		alert(src.mob,"I'm sorry, the player cap of [player_cap] has been reached for this server. You will now be forcibly disconnected", "SERVER FULL")
		del(src)
		return

	// moved preferences from new_player so it's accessible in the client scope
	if (!preferences)
		preferences = new

	Z_LOG_DEBUG("Client/New", "[src.ckey] - Adding to clients")

	clients += src

	SPAWN_DBG(0) // to not lock up spawning process
		if (IsGuestKey(src.key))
			src.has_contestwinner_medal = 0
		else if (!config || !config.medal_hub || !config.medal_password)
			src.has_contestwinner_medal = 0
		else
			src.has_contestwinner_medal = world.GetMedal("Too Cool", src.key, config.medal_hub, config.medal_password)

	src.initSizeHelpers()

	src.tooltipHolder = new /datum/tooltipHolder(src)
	src.tooltipHolder.clearOld()

	createRenderSourceHolder()
	screen += renderSourceHolder

	for(var/key in globalImages)
		var/image/I = globalImages[key]
		src << I

	Z_LOG_DEBUG("Client/New", "[src.ckey] - ok mostly done")

	SPAWN_DBG(0)
		updateXpRewards()

	SPAWN_DBG(3 SECONDS)
		var/is_newbie = 0
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
				src.mob.Browse(grabResource("html/tgControls.html"),"window=tgcontrolsinfo;size=600x400;title=TG Controls Help")
				boutput(src, "<span class='alert'>Welcome! You don't have a character profile saved yet, so please create one. If you're new, check out the <a target='_blank' href='https://wiki.ss13.co/Getting_Started#Fundamentals'>quick-start guide</a> for how to play!</span>")
				//hey maybe put some 'new player mini-instructional' prompt here
				//ok :)
#endif
				is_newbie = 1
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
			if (it_is_ass_day)
				src.verbs += /client/proc/cmd_ass_day_rules
				src.cmd_ass_day_rules()


			if (src.byond_version < 513 || src.byond_build < 1526)
				if (alert(src, "Please update BYOND to the latest version! Would you like to be taken to the download page? Make sure to download the stable release.", "ALERT", "Yes", "No") == "Yes")
					src << link("http://www.byond.com/download/")
				else
					alert(src, "You won't be able to play without updating, sorry!")
					del(src)
					return

// Let's throw it here, why not! -ZeWaka
#if DM_BUILD < 1526 && !defined(SPACEMAN_DMM)
#error Please update your BYOND version to the latest stable release.
#endif

		else
			if (noir)
				animate_fade_grayscale(src, 1)
			preferences.savefile_load(src)
			load_antag_tokens()
			load_persistent_bank()

		Z_LOG_DEBUG("Client/New", "[src.ckey] - setjoindate")
		setJoinDate()

		if (winget(src, null, "hwmode") != "true")
			alert(src, "Hardware rendering is disabled.  This may cause errors displaying lighting, manifesting as BIG WHITE SQUARES.\nPlease enable hardware rendering from the byond preferences menu.","Potential Rendering Issue")

		ircbot.event("login", src.key)
#if defined(RP_MODE) && !defined(IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME)
		src.verbs += /client/proc/cmd_rp_rules
		if (istype(src.mob, /mob/new_player))
			src.cmd_rp_rules()
#endif
		//Cloud data
		if (cdn)
			var/http[] = world.Export( "http://spacebee.goonhub.com/api/cloudsave?list&ckey=[ckey]&api_key=[config.ircbot_api]" )
			if( !http )
				logTheThing( "debug", src, null, "failed to have their cloud data loaded: Couldn't reach Goonhub" )

			var/list/ret = json_decode(file2text( http[ "CONTENT" ] ))
			if( ret["status"] == "error" )
				logTheThing( "debug", src, null, "failed to have their cloud data loaded: [ret["error"]["error"]]" )
			else
				cloudsaves = ret["saves"]
				clouddata = ret["cdata"]
				load_antag_tokens()
				load_persistent_bank()
				var/decoded = cloud_get("audio_volume")
				if(decoded)
					var/cur = volumes.len
					volumes = json_decode(decoded)
					volumes.len = cur

		if(current_state <= GAME_STATE_PREGAME && src.antag_tokens)
			boutput(src, "<b>You have [src.antag_tokens] antag tokens!</b>")

		if(istype(src.mob, /mob/new_player))
			var/mob/new_player/M = src.mob
			M.new_player_panel() // update if tokens available

	if(do_compid_analysis)
		do_computerid_test(src) //Will ban yonder fucker in case they are prix
		check_compid_list(src) 	//Will analyze their computer ID usage patterns for aberrations


	//WIDESCREEN STUFF
	var/splitter_value = text2num(winget( src, "mainwindow.mainvsplit", "splitter" ))

	var/widescreen_checked = winget( src, "menu.set_wide", "is-checked" ) == "true"
	if (widescreen_checked)
		if (splitter_value < 67.0)
			src.set_widescreen(1)

	var/is_vert_splitter = winget( src, "menu.horiz_split", "is-checked" ) != "true"

	if (is_vert_splitter)

		if (splitter_value >= 67.0) //Was this client using widescreen last time? save that!
			src.set_widescreen(1, splitter_value)

		src.screenSizeHelper.registerOnLoadCallback(CALLBACK(src, "checkScreenAspect"))
	else

		set_splitter_orientation(0, splitter_value)
		src.set_widescreen(1, splitter_value)
		winset( src, "menu", "horiz_split.is-checked=true" )

	//End widescreen stuff

	//blendmode stuff

	var/distort_checked = winget( src, "menu.zoom_distort", "is-checked" ) == "true"

	winset( src, "mapwindow.map", "zoom-mode=[distort_checked ? "distort" : "normal"]" )

	//blendmode end

	// cursed darkmode stuff

	src.sync_dark_mode()

	if(winget(src, "menu.fullscreen", "is-checked") == "true")
		winset(src, null, "mainwindow.titlebar=false;mainwindow.is-maximized=true")

	if(winget(src, "menu.hide_status_bar", "is-checked") == "true")
		winset(src, null, "mainwindow.statusbar=false")

	if(winget(src, "menu.hide_menu", "is-checked") == "true")
		winset(src, null, "mainwindow.menu='';menub.is-visible = true")

	// cursed darkmode end

	//tg controls stuff

	tg_controls = winget( src, "menu.tg_controls", "is-checked" ) == "true"
	tg_layout = winget( src, "menu.tg_layout", "is-checked" ) == "true"

	//tg controls end

	use_chui = winget( src, "menu.use_chui", "is-checked" ) == "true"
	use_chui_custom_frames = winget( src, "menu.use_chui_custom_frames", "is-checked" ) == "true"

	//wow its the future we can choose between 3 fps values omg
	if (winget( src, "menu.fps_chunky", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_CHUNKY
	else if (winget( src, "menu.fps_creamy", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_CREAMY
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

	src.reputations = new(src)

	if(src.holder && src.holder.level >= LEVEL_CODER)
		src.control_freak = 0
	Z_LOG_DEBUG("Client/New", "[src.ckey] - new() finished.")

	login_success = 1
/*
/client/proc/write_gauntlet_matches()
	return
*/

/client/proc/init_admin()
	if(!address || (world.address == src.address))
		admins[src.ckey] = "Host"
	if (admins.Find(src.ckey) && !src.holder)
		src.holder = new /datum/admins(src)
		src.holder.rank = admins[src.ckey]
		update_admins(admins[src.ckey])
		onlineAdmins |= (src)
		if (!NT.Find(src.ckey))
			NT.Add(src.ckey)
		return 1

	return 0

/client/proc/clear_admin()
	if(src.holder)
		src.holder.dispose()
		src.holder = null
		src.clear_admin_verbs()
		src.update_admins(null)
		onlineAdmins -= src

/client/proc/checkScreenAspect(list/params)
	if (params.len)
		if ((params["screenW"]/params["screenH"]) == (4/3))
			SPAWN_DBG(6 SECONDS)
				if(alert(src, "You appear to be using a 4:3 aspect ratio! The Horizontal Split option is reccomended for your display. Activate Horizontal Split?",,"Yes","No") == "Yes")
					set_splitter_orientation(0)
					winset( src, "menu", "horiz_split.is-checked=true" )

/client/Command(command)
	command = html_encode(command)
	out(src, "<span class='alert'>Command \"[command]\" not recognised</span>")

/client/proc/load_antag_tokens()
	var/savefile/AT = LoadSavefile("data/AntagTokens.sav")
	if (!AT)
		if( cloud_available() )
			antag_tokens = cloud_get( "antag_tokens" ) ? text2num(cloud_get( "antag_tokens" )) : 0
		return

	var/ATtoken
	AT[ckey] >> ATtoken
	if (!ATtoken)
		antag_tokens = cloud_get( "antag_tokens" ) ? text2num(cloud_get( "antag_tokens" )) : 0
		return
	else
		antag_tokens = ATtoken
	if( cloud_available() )
		antag_tokens += text2num( cloud_get( "antag_tokens" ) || "0" )
		var/failed = cloud_put( "antag_tokens", antag_tokens )
		if( failed )
			logTheThing( "debug", src, null, "Failed to store antag tokens in the ~cloud~: [failed]" )
		else
			AT[ckey] << null

/client/proc/set_antag_tokens(amt as num)
	antag_tokens = amt
	if( cloud_available() )
		cloud_put( "antag_tokens", amt )
	/*
	var/savefile/AT = LoadSavefile("data/AntagTokens.sav")
	if (!AT) return
	if (antag_tokens < 0) antag_tokens = 0
	AT[ckey] << antag_tokens*/

/client/proc/use_antag_token()
	src.set_antag_tokens(--antag_tokens)


/client/proc/load_persistent_bank()
	//var/savefile/PB = LoadSavefile("data/PersistentBank.sav")
	//if (!PB)
	//	if( cloud_available() )
	//		persistent_bank = cloud_get( "persistent_bank" ) ? text2num(cloud_get( "persistent_bank" )) : 0
	//	return

	//var/bank = 0
	//PB[ckey] >> bank
	//if (!bank)

	persistent_bank_valid = cloud_available()

	persistent_bank = cloud_get( "persistent_bank" ) ? text2num(cloud_get( "persistent_bank" )) : 0
	//	return
	//else
	//	persistent_bank = bank
	if( !persistent_bank && cloud_available() )
		logTheThing( "debug", src, null, "first cloud_get failed but cloud is available!" )
		persistent_bank += text2num( cloud_get( "persistent_bank" ) || "0" )
		var/failed = cloud_put( "persistent_bank", persistent_bank )
		if( failed )
			logTheThing( "debug", src, null, "Failed to store persistent cash in the ~cloud~: [failed]" )
		//else
		//	PB[ckey] << null

	persistent_bank_item = cloud_get( "persistent_bank_item" )

	if( !persistent_bank_item && cloud_available() )
		persistent_bank_item = cloud_get( "persistent_bank_item" )
		var/failed = cloud_put( "persistent_bank_item", persistent_bank_item )
		if( failed )
			logTheThing( "debug", src, null, "Failed to store persistent bank item in the ~cloud~: [failed]" )


//MBC TODO : PERSISTENTBANK_VERSION_MIN, MAX FOR BANKING SO WE CAN WIPE AWAY EVERYONE'S HARD WORK WITH A SINGLE LINE OF CODE CHANGE
// defines are already set, just do the checks here ok
// ok in retrospect i don't think we need this so I'm not doing it. leaving this comment here though! for fun! (in case SOMEONE changes their mind)

/client/proc/set_last_purchase(datum/bank_purchaseable/purchase)
	if (!purchase || purchase == 0 || !purchase.carries_over)
		persistent_bank_item = "none"
		if( cloud_available() )
			cloud_put( "persistent_bank_item", "none" )
	else
		persistent_bank_item = purchase.name
		if( cloud_available() )
			cloud_put( "persistent_bank_item", persistent_bank_item )

/client/proc/set_persistent_bank(amt as num)
	persistent_bank = amt
	if( cloud_available() )
		cloud_put( "persistent_bank", amt )
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
	var/new_bank_value = persistent_bank + amt
	src.set_persistent_bank(new_bank_value)

/client/proc/sub_from_bank(datum/bank_purchaseable/purchase)
	add_to_bank(-purchase.cost)

/client/proc/bank_can_afford(amt as num)
	var/new_bank_value = persistent_bank - amt
	if (new_bank_value >= 0)
		return 1
	else
		return 0

/client/proc/is_mentor()
	return player.mentor

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
		var/addr = address
		var/ck = ckey
		var/cid = computer_id
		SPAWN_DBG(0)
			if (geoip_check(addr))
				var/addData[] = new()
				addData["ckey"] = ck
				addData["compID"] = cid
				addData["ip"] = addr
				addData["reason"] = "Ban evader: computer ID collision." // haha get fucked
				addData["akey"] = "Marquesas"
				addData["mins"] = 0
				var/slt = rand(600, 3000)
				logTheThing("admin", null, null, "Evasion geoip autoban triggered on [key], will execute in [slt / 10] seconds.")
				message_admins("Autobanning evader [key] in [slt / 10] seconds.")
				sleep(slt)
				addBan(addData)

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
	//	logTheThing("admin", null, null, "Banned location: Argentina, Entre Rios, Federal for IP [addr].")
	//	return 1
	if (findtext(jd, asshole_proxy_provider))
		logTheThing("admin", null, null, "Banned proxy: AnchorFree Hotspot Shield [addr].")
		return 1
	return 0

/client/proc/setJoinDate()
	set background = 1
	joined_date = ""
	var/list/text = world.Export("http://byond.com/members/[src.ckey]?format=text")
	if(text)
		var/content = file2text(text["CONTENT"])
		var/savefile/save = new
		save.ImportText("/", content)
		save.cd = "general"
		joined_date = save["joined"]
		jd_warning(joined_date)
	return

/client/verb/ping()
	set name = "Ping"
	boutput(usr, "Pong")

/client/verb/changeServer(var/server as text)
	set name = "Change Server"
	set hidden = 1
	var/serverURL
	var/serverName
	switch (server)
		if (1, "rp")
			serverName = "Goonstation Roleplay"
			serverURL = "byond://goon1.goonhub.com:26100"
		if (2, "main")
			serverName = "Goonstation"
			serverURL = "byond://goon2.goonhub.com:26200"
		if (3, "main2")
			serverName = "Goonstation Roleplay Overflow"
			serverURL = "byond://goon3.goonhub.com:26300"
		if (4, "main3")
			serverName = "Goonstation Overflow"
			serverURL = "byond://goon4.goonhub.com:26400"

	if (serverURL)
		boutput(usr, "You are being redirected to [serverName]...")
		usr << link(serverURL)


/*
/client/verb/Newcastcycle()
	set hidden = 1
	if (!(ishuman(usr))) return
	var/mob/living/carbon/human/H = usr
	if (istype(H.wear_suit, /obj/item/clothing/suit/wizrobe/abuttontest))
		var/obj/screen/ability_button/spell/U = H.wear_suit.ability_buttons[2]
		U.execute_ability()
*/

/client/Stat()
	. = ..()
	if(src.stathover)
		if(get_turf(mob) != stathover_start || get_dist( stathover, get_turf(mob) ) >= 5)
			stathover = null
			return
		stat( stathover )//tg makes a new panel, thats ugly tho
		for( var/atom/A in stathover )
			if( !A.mouse_opacity || A.invisibility > mob.see_invisible ) continue
			stat( A )

	if (!src.holder)//todo : maybe give admins a toggle
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
		M = whois_ckey_to_mob_reference(targetCkey)

	switch(href_list["action"])
		if ("priv_msg_irc")
			if (!src || !src.mob)
				return
			var/target = href_list["nick"]
			var/t = input("Message:", text("Private message to [target] (Discord)")) as null|text
			if(!(src.holder && (src.holder.rank in list("Host", "Coder"))))
				t = strip_html(t,500)
			if (!( t ))
				return
			boutput(src.mob, "<span class='ahelp' class=\"bigPM\">Admin PM to-<b>[target] (Discord)</b>: [t]</span>")
			logTheThing("admin_help", src, null, "<b>PM'd [target]</b>: [t]")
			logTheThing("diary", src, null, "PM'd [target]: [t]", "ahelp")

			var/ircmsg[] = new()
			ircmsg["key"] = src.mob && src ? src.key : ""
			ircmsg["name"] = src.mob.real_name
			ircmsg["key2"] = target
			ircmsg["name2"] = "Discord"
			ircmsg["msg"] = html_decode(t)
			ircbot.export("pm", ircmsg)

			//we don't use message_admins here because the sender/receiver might get it too
			for (var/client/C)
				if (!C.mob) continue
				var/mob/K = C.mob
				if(C.holder && C.key != usr.key)
					if (C.player_mode && !C.player_mode_ahelp)
						continue
					else
						boutput(K, "<span class='ahelp'><b>PM: [key_name(src.mob,0,0)][(src.mob.real_name ? "/"+src.mob.real_name : "")] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[src.ckey]' class='popt'><i class='icon-info-sign'></i></A> <i class='icon-arrow-right'></i> [target] (Discord)</b>: [t]</span>")

		if ("priv_msg")
			do_admin_pm(href_list["target"], usr) // See \admin\adminhelp.dm, changed to work off of ckeys instead of mobs.

		if ("mentor_msg_irc")
			if (!usr || !usr.client)
				return
			var/target = href_list["nick"]
			var/t = input("Message:", text("Mentor Message")) as null|text
			if(!(src.holder && (src.holder.rank in list("Host", "Coder"))))
				t = strip_html(t,500)
			if (!( t ))
				return
			boutput(src.mob, "<span class='mhelp'><b>MENTOR PM: TO [target] (Discord)</b>: <span class='message'>[t]</span></span>")
			logTheThing("mentor_help", src, null, "<b>Mentor PM'd [target]</b>: [t]")
			logTheThing("diary", src, null, "Mentor PM'd [target]: [t]", "admin")

			var/ircmsg[] = new()
			ircmsg["key"] = src.mob && src ? src.key : ""
			ircmsg["name"] = src.mob.real_name
			ircmsg["key2"] = target
			ircmsg["name2"] = "Discord"
			ircmsg["msg"] = html_decode(t)
			ircbot.export("mentorpm", ircmsg)

			//we don't use message_admins here because the sender/receiver might get it too
			var/mentormsg = "<span class='mhelp'><b>MENTOR PM: [key_name(src.mob,0,0,1)] <i class='icon-arrow-right'></i> [target] (Discord)</b>: <span class='message'>[t]</span></span>"
			for (var/client/C)
				if (C.can_see_mentor_pms() && C.key != usr.key)
					if (C.holder)
						if (C.player_mode && !C.player_mode_mhelp)
							continue
						else //Message admins
							boutput(C, "<span class='mhelp'><b>MENTOR PM: [key_name(src.mob,0,0,1)][(src.mob.real_name ? "/"+src.mob.real_name : "")] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[src.ckey]' class='popt'><i class='icon-info-sign'></i></A> <i class='icon-arrow-right'></i> [target] (Discord)</b>: <span class='message'>[t]</span></span>")
					else //Message mentors
						boutput(C, mentormsg)

		if ("mentor_msg")
			if (M)
				if (!( ismob(M) ) && !M.client)
					return
				if (!usr || !usr.client)
					return

				var/t = input("Message:", text("Mentor Message")) as null|text
				if (href_list["target"])
					M = whois_ckey_to_mob_reference(href_list["target"])
				if (!(src.holder && (src.holder.rank in list("Host", "Coder"))))
					t = strip_html(t,500)
				if (!( t ))
					return
				if (!src || !src.mob) //ZeWaka: Fix for null.client
					return

				if (src.holder)
					boutput(M, "<span class='mhelp'><b>MENTOR PM: FROM [key_name(src.mob,0,0,1)]</b>: <span class='message'>[t]</span></span>")
					boutput(src.mob, "<span class='mhelp'><b>MENTOR PM: TO [key_name(M,0,0,1)][(M.real_name ? "/"+M.real_name : "")] <A HREF='?src=\ref[src.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[t]</span></span>")
				else
					if (M.client && M.client.holder)
						boutput(M, "<span class='mhelp'><b>MENTOR PM: FROM [key_name(src.mob,0,0,1)][(src.mob.real_name ? "/"+src.mob.real_name : "")] <A HREF='?src=\ref[M.client.holder];action=adminplayeropts;targetckey=[src.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[t]</span></span>")
					else
						boutput(M, "<span class='mhelp'><b>MENTOR PM: FROM [key_name(src.mob,0,0,1)]</b>: <span class='message'>[t]</span></span>")
					boutput(usr, "<span class='mhelp'><b>MENTOR PM: TO [key_name(M,0,0,1)]</b>: <span class='message'>[t]</span></span>")

				logTheThing("mentor_help", src.mob, M, "Mentor PM'd [constructTarget(M,"mentor_help")]: [t]")
				logTheThing("diary", src.mob, M, "Mentor PM'd [constructTarget(M,"diary")]: [t]", "admin")

				var/ircmsg[] = new()
				ircmsg["key"] = src.mob && src ? src.key : ""
				ircmsg["name"] = src.mob.real_name
				ircmsg["key2"] = (M != null && M.client != null && M.client.key != null) ? M.client.key : ""
				ircmsg["name2"] = (M != null && M.real_name != null) ? M.real_name : ""
				ircmsg["msg"] = html_decode(t)
				ircbot.export("mentorpm", ircmsg)

				var/mentormsg = "<span class='mhelp'><b>MENTOR PM: [key_name(src.mob,0,0,1)] <i class='icon-arrow-right'></i> [key_name(M,0,0,1)]</b>: <span class='message'>[t]</span></span>"
				for (var/client/C)
					if (C.can_see_mentor_pms() && C.key != usr.key && (M && C.key != M.key))
						if (C.holder)
							if (C.player_mode && !C.player_mode_mhelp)
								continue
							else
								boutput(C, "<span class='mhelp'><b>MENTOR PM: [key_name(src.mob,0,0,1)][(src.mob.real_name ? "/"+src.mob.real_name : "")] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[src.ckey]' class='popt'><i class='icon-info-sign'></i></A> <i class='icon-arrow-right'></i> [key_name(M,0,0,1)]/[M.real_name] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[t]</span></span>")
						else
							boutput(C, mentormsg)

		if ("mach_close")
			var/window = href_list["window"]
			var/t1 = text("window=[window]")
			usr.remove_dialogs()
			usr.Browse(null, t1)
			//Special cases
			switch (window)
				if ("aialerts")
					usr:viewalerts = 0

		//A thing for the chat output to call so that links open in the user's default browser, rather than IE
		if ("openLink")
			src << link(href_list["link"])

		if ("ehjax")
			ehjax.topic("main", href_list, src)

		if("resourcePreloadComplete")
			bout(src, "<span class='notice'><b>Preload completed.</b></span>")
			src.Browse(null, "window=resourcePreload")
			return

	..()
	return

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


//drsingh, don't read the rest of this comment; BELOW: CLOUD STUFFS
//Sets and uploads cloud data on the client
//Try to avoid calling often, as it contacts Goonhub and uses the dreaded spawn.
//TODO: Pool puts, determine value of doing as such.
/client/proc/cloud_put( var/key, var/value )
	if( !clouddata )
		return "Failed to talk to Goonhub; try rejoining."//oh no
	clouddata[key] = "[value]"
	SPAWN_DBG(0)//I do not advocate this! So basically hide your eyes for one line of code.
		world.Export( "http://spacebee.goonhub.com/api/cloudsave?dataput&api_key=[config.ircbot_api]&ckey=[ckey]&key=[url_encode(key)]&value=[url_encode(clouddata[key])]" )//If it fails, oh well...
//Returns some cloud data on the client
/client/proc/cloud_get( var/key )
	return clouddata ? clouddata[key] : null
//Returns 1 if you can set or retrieve cloud data on the client
/client/proc/cloud_available()
	return !!clouddata

/proc/add_test_screen_thing()
	var/client/C = input("For who", "For who", null) in clients
	var/wavelength_shift = input("Shift wavelength bounds by <x> nm, should be in the range of -370 to 370", "Wavelength shift", 0) as num
	if (wavelength_shift < -370 || wavelength_shift > 370)
		boutput(usr, "Invalid value.")
		return
	var/s_r = 0
	var/s_g = 0
	var/s_b = 0

	// total range: 380 - 750 (range: 370nm)
	// red: 570 - 750 (range: 180nm)
	if (wavelength_shift < 0)
		s_r = min(-wavelength_shift / 180 * 255, 255)
	else if (wavelength_shift > 190)
		s_r = min((wavelength_shift - 190) / 180 * 255, 255)
	// green: 490 - 620 (range: 130nm)
	if (wavelength_shift < -130)
		s_g = min(-(wavelength_shift + 130) / 130 * 255, 255)
	else if (wavelength_shift > 110)
		s_g = min((wavelength_shift - 110) / 130 * 255, 255)
	// blue: 380 - 500 (range: 120nm)
	if (wavelength_shift < -250)
		s_b = min(-(wavelength_shift + 250) / 120 * 255, 255)
	else if (wavelength_shift > 0)
		s_b = min(wavelength_shift / 120 * 255, 255)

	var/subtr_color = rgb(s_r, s_g, s_b)

	var/si_r = max(min(input("Red spectrum intensity (0-1)", "Intensity", 1.0) as num, 1), 0)
	var/si_g = max(min(input("Green spectrum intensity (0-1)", "Intensity", 1.0) as num, 1), 0)
	var/si_b = max(min(input("Blue spectrum intensity (0-1)", "Intensity", 1.0) as num, 1), 0)

	var/multip_color = rgb(si_r * 255, si_g * 255, si_b * 255)

	var/obj/screen/S = new
	S.icon = 'icons/mob/whiteview.dmi'
	S.blend_mode = BLEND_SUBTRACT
	S.color = subtr_color
	S.layer = HUD_LAYER - 0.2
	S.screen_loc = "SOUTH,WEST"
	S.mouse_opacity = 0

	C.screen += S

	var/obj/screen/M = new
	M.icon = 'icons/mob/whiteview.dmi'
	M.blend_mode = BLEND_MULTIPLY
	M.color = multip_color
	M.layer = HUD_LAYER - 0.1
	M.screen_loc = "SOUTH,WEST"
	M.mouse_opacity = 0

	C.screen += M


/client/verb/apply_depth_shadow()
	set hidden = 1
	set name ="apply-depth-shadow"

	apply_depth_filter() //see _plane.dm

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
	SPAWN_DBG(1 DECI SECOND)
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

/client/verb/set_tg_layout()
	set hidden = 1
	set name = "set-tg-layout"
	SPAWN_DBG(1 DECI SECOND)
		set_layout(!tg_layout)

/client/verb/set_fps()
	set hidden = 1
	set name = "set-fps"

	if (winget( src, "menu.fps_chunky", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_CHUNKY
	else if (winget( src, "menu.fps_creamy", "is-checked" ) == "true")
		src.tick_lag = CLIENTSIDE_TICK_LAG_CREAMY
	else
		src.tick_lag = CLIENTSIDE_TICK_LAG_SMOOTH


/client/verb/set_wasd_controls()
	set hidden = 1
	set name = "set-wasd-controls"
	src.do_action("togglewasd")


/client/verb/set_chui()
	set hidden = 1
	set name = "set-chui"
	if (src.use_chui)
		src.use_chui = 0
	else
		src.use_chui = 1

/client/verb/set_chui_custom_frames()
	set hidden = 1
	set name = "set-chui-custom-frames"
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

//These size helpers are invisible browser windows that help with getting client screen dimensions
/client/proc/initSizeHelpers()
	src.screenSizeHelper = new(src)
	src.mapSizeHelper = new(src)

/client/verb/windowResizeEvent()
	set hidden = 1
	set name = "window-resize-event"

	src.resizeTooltipEvent()

	//tell the interface helpers to recompute data
	src.mapSizeHelper.update()

/client/verb/autoscreenshot()
	set hidden = 1
	set name = ".autoscreenshot"

	winset(src, null, "command=\".screenshot auto\"")
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
<source src="http://cdn.goonhub.com/misc/cinematics/[name].mp4" type="video/mp4">
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
info.tab-text-color=[_SKIN_TEXT]"

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
#undef _SKIN_BG
#undef _SKIN_INFO_TAB_BG
#undef _SKIN_INFO_BG
#undef _SKIN_TEXT
#undef _SKIN_COMMAND_BG
#undef SKIN_TEMPLATE
