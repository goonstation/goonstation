var/global/datum/controller/gameticker/ticker
var/global/current_state = GAME_STATE_INVALID
var/global/game_force_started = FALSE

#define LATEJOIN_FULL_WAGE_GRACE_PERIOD 9 MINUTES
/datum/controller/gameticker
	var/hide_mode = TRUE
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/list/datum/mind/minds = list()
	var/last_readd_lost_minds_to_ticker = 1 // In relation to world time.

	var/pregame_timeleft = 0

	// this is actually round_elapsed_deciseconds
	var/round_elapsed_ticks = 0

	var/click_delay = 3

	var/datum/ai_rack_manager/ai_law_rack_manager = new /datum/ai_rack_manager()

	var/datum/crewCredits/creds = null

	var/skull_key_assigned = 0

	var/tmp/last_try_dilate = 0
	var/tmp/useTimeDilation = TIME_DILATION_ENABLED
	var/tmp/timeDilationLowerBound = MIN_TICKLAG
	var/tmp/timeDilationUpperBound = OVERLOADED_WORLD_TICKLAG
	/// how many times in a row has the cpu been high
	var/tmp/highCpuCount = 0
	/// how many times in a row has the map_cpu been high
	var/tmp/highMapCpuCount = 0

/datum/controller/gameticker/proc/pregame()

	pregame_timeleft = PREGAME_LOBBY_TICKS
	boutput(world, "<b>Welcome to the pre-game lobby!</b><br>Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds.")

	// let's try doing this here, yoloooo
	// zamu 20200823: idk if this is even getting called...
	//if (mining_controls?.mining_z && mining_controls.mining_z_asteroids_max)
	//	mining_controls.spawn_mining_z_asteroids()

	if(master_mode == "battle_royale")
		lobby_titlecard = new /datum/titlecard/battleroyale()
		lobby_titlecard.set_pregame_html()

	if(master_mode != "extended")
		src.hide_mode = TRUE
	else
		src.hide_mode = FALSE

	#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
	pregame_timeleft = 1
	#endif



	var/did_mapvote = FALSE
	var/did_reminder = FALSE

	#ifdef LIVE_SERVER
	new /obj/overlay/zamujasa/round_start_countdown/encourage()
	#endif
	var/obj/overlay/zamujasa/round_start_countdown/timer/title_countdown = new()
	while (current_state <= GAME_STATE_PREGAME)
		sleep(1 SECOND)
		// Start the countdown as normal, but hold it at 30 seconds until setup is complete
		if (!game_start_delayed && (pregame_timeleft > 30 || current_state == GAME_STATE_PREGAME))
			pregame_timeleft--

			if (pregame_timeleft <= 60 && !did_mapvote)
				// do it here now instead of before the countdown
				// as part of the early start most people might not even see it at 150
				// so this makes it show up a minute before the game starts
				handle_mapvote()
				did_mapvote = TRUE

			if (pregame_timeleft <= 30 && !did_reminder)
				// hey boo the rounds starting and you didnt ready up
				var/list/targets = list()
				for_by_tcl(P, /mob/new_player)
					if (!P.ready)
						targets += P
				playsound_global(targets, 'sound/misc/clock_tick.ogg', 50)
				did_reminder = TRUE

			if (title_countdown)
				title_countdown.update_time(pregame_timeleft)
		else if(title_countdown)
			title_countdown.update_time(-1)


		if(pregame_timeleft <= 0)
			current_state = GAME_STATE_SETTING_UP
			qdel(title_countdown)
			qdel(game_start_countdown)

#ifdef SERVER_SIDE_PROFILING
#ifdef SERVER_SIDE_PROFILING_PREGAME
#warn Profiler will output at pregame stage
	var/profile_out = file("data/profile/[time2text(world.realtime, "YYYY-MM-DD hh-mm-ss")]-pregame.log")
	profile_out << world.Profile(PROFILE_START | PROFILE_AVERAGE, "sendmaps", "json")
	world.log << "Dumped profiler data."
#endif

#if defined(SERVER_SIDE_PROFILING_INGAME_ONLY)
#warn Profiler reset for ingame stage
	// We're in game now, so reset profiler data
	world.Profile(PROFILE_RESTART | PROFILE_AVERAGE, "sendmaps", "json")
#elif !defined(SERVER_SIDE_PROFILING_FULL_ROUND)
#warn Profiler disabled after init
	// If we aren't doing ingame or full round then we're done with the profiler
	world.Profile(PROFILE_STOP | PROFILE_AVERAGE, "sendmaps", "json")
#endif
#endif

	SPAWN(0)
		setup()

/datum/controller/gameticker/proc/setup()
	set background = 1
	//Create and announce mode

	// try to roll a gamemode 10 times before giving up
	var/attempts_left = 10
	var/list/failed_modes = list()
	while(attempts_left > 0)
		switch(master_mode)
			if("random","secret") src.mode = config.pick_random_mode(failed_modes)
			if("action")
				src.mode = config.pick_mode(pick("nuclear","wizard","blob"))
			if("pod_wars")
				src.mode = config.pick_mode("pod_wars")
			else src.mode = config.pick_mode(master_mode)

		#if defined(MAP_OVERRIDE_POD_WARS)
		src.mode = config.pick_mode("pod_wars")
		#endif

		//Configure mode and assign player to special mode stuff
		var/can_continue = src.mode.pre_setup()

		if(can_continue)
			break
		attempts_left--
		failed_modes += src.mode.config_tag
		// no point trying to do this 9 more times if we know whats gonna happen
		if(src.mode.config_tag == master_mode)
			attempts_left = 0
		logTheThing(LOG_DEBUG, null, "Error setting up [mode] for [master_mode], trying [attempts_left] more times.")
		qdel(src.mode)
		src.mode = null

	if(!src.mode)
		logTheThing(LOG_DEBUG, null, "Gamemode selection on mode [master_mode] failed, reverting to pre-game lobby.")
		boutput(world, "<B>Error setting up [master_mode].</B> reverting to pre-game lobby.")
		current_state = GAME_STATE_PREGAME
		SPAWN(0) pregame()
		return 0

	if(hide_mode)
		#ifdef RP_MODE
		boutput(world, "<B>Have fun and RP!</B>")

		#else
		var/modes = sortList(config.get_used_mode_names(), /proc/cmp_text_asc)
		boutput(world, "<B>The current game mode is a secret!</B>")
		boutput(world, "<B>Possibilities:</B> [english_list(modes)]")

		#endif
	else
		src.mode.announce()

	logTheThing(LOG_DEBUG, null, "Chosen game mode: [mode] ([master_mode]) on map [getMapNameFromID(map_setting)].")
	message_admins("Chosen game mode: [mode] ([master_mode]).")

	//Tell the participation recorder to queue player data while the round starts up
	participationRecorder.setHold()

#ifdef RP_MODE
	looc_allowed = 1
	boutput(world, "<B>LOOC has been automatically enabled.</B>")
	ooc_allowed = 0
	boutput(world, "<B>OOC has been automatically disabled until the round ends.</B>")
#else
	if (istype(src.mode, /datum/game_mode/construction))
		looc_allowed = 1
		boutput(world, "<B>LOOC has been automatically enabled.</B>")
	else
		ooc_allowed = 0
		boutput(world, "<B>OOC has been automatically disabled until the round ends.</B>")
#endif
#ifndef IM_REALLY_IN_A_FUCKING_HURRY_HERE
	Z_LOG_DEBUG("Game Start", "Animating client colors to black now")
	var/list/animateclients = list()
	for (var/client/C)
		if (!istype(C.mob,/mob/new_player))
			continue
		var/mob/new_player/P = C.mob
		if (P.ready)
			Z_LOG_DEBUG("Game Start/Ani", "Animating [P.client]")
			animateclients += P.client
			animate(P.client, color = "#000000", time = 5, easing = QUAD_EASING | EASE_IN)
#endif
	// Give said clients time to animate the fadeout before we do this...
	sleep(0.5 SECONDS)

	//Distribute jobs
	distribute_jobs()

	//Create player characters and transfer them
	create_characters()

	add_minds()

	// rip collar key, nerds murdered people for you as non-antags and it was annoying
	//implant_skull_key() //Solarium

#ifdef CREW_OBJECTIVES
	//Create objectives for the non-traitor/nogoodnik crew.
	generate_crew_objectives()
#endif
	//picky eater trait handling
	for (var/mob/living/carbon/human/H in mobs)
		if (H.client && H.traitHolder?.hasTrait("picky_eater"))
			var/datum/trait/picky_eater/eater_trait = H.traitHolder.getTrait("picky_eater")
			if (length(eater_trait.fav_foods) > 0)
				boutput(H, eater_trait.explanation_text)
				H.mind.store_memory(eater_trait.explanation_text)

	//Equip characters
	equip_characters()

#ifndef IM_REALLY_IN_A_FUCKING_HURRY_HERE
	Z_LOG_DEBUG("Game Start", "Animating client colors to normal")
	for (var/client/C in animateclients)
		if (C)
			Z_LOG_DEBUG("Game Start/A", "Animating client [C]")
			var/target_color = "#FFFFFF"
			if(C.color != "#000000")
				target_color = C.color
			animate(C, color = "#000000", time = 0, flags = ANIMATION_END_NOW)
			animate(color = "#000000", time = 10, easing = QUAD_EASING | EASE_IN)
			animate(color = target_color, time = 10, easing = QUAD_EASING | EASE_IN)
#endif

	current_state = GAME_STATE_PLAYING
	round_time_check = world.timeofday
	round_start_time = TIME	// this will not be accurate after 24 hours

	SPAWN(0)
		ircbot.event("roundstart")
		mode.post_setup()

		build_random_floor_turf_list()

		mode.post_post_setup()

		for(var/turf/T in landmarks[LANDMARK_ARTIFACT_SPAWN])
			var/spawnchance = landmarks[LANDMARK_ARTIFACT_SPAWN][T]
			if (prob(spawnchance))
				Artifact_Spawn(T)

		shippingmarket.get_market_timeleft()

		logTheThing(LOG_STATION, null, "<b>Current round begins</b>")
		boutput(world, "<FONT class='notice'><B>Enjoy the game!</B></FONT>")

		for(var/mob/new_player/lobby_player in mobs)
			if(lobby_player.client)
				if(lobby_player.client.antag_tokens > 0)
					winset(lobby_player, "joinmenu", "size=240x200")
					winset(lobby_player, "joinmenu.observe", "pos=18,136")
					winset(lobby_player, "joinmenu.button_ready_antag", "is-disabled=true;is-visible=false")
				winset(lobby_player, "joinmenu.button_joingame", "is-disabled=false;is-visible=true")
				winset(lobby_player, "joinmenu.button_ready", "is-disabled=true;is-visible=false")

		//Setup the hub site logging
		var hublog_filename = "data/stats/data.txt"
		if (fexists(hublog_filename))
			fdel(hublog_filename)

		hublog = file(hublog_filename)
		hublog << ""

		//Tell the participation recorder that we're done FAFFING ABOUT
		participationRecorder.releaseHold()
		roundManagement.recordUpdate(mode)

#ifdef BAD_MONKEY_NO_BANANA
	for_by_tcl(monke, /mob/living/carbon/human/npc/monkey)
		qdel(monke)
#endif

	SPAWN(10 MINUTES) // standard engine warning
		for_by_tcl(E, /obj/machinery/computer/power_monitor/smes)
			LAGCHECK(LAG_LOW)
			var/area/A = get_area(E) // only check the main (engine) pnet
			if (!istype(A, /area/station) || istype(A, /area/station/engine/substation) || istype(A, /area/station/solar) || istype(A, /area/station/maintenance/solar))
				continue
			var/datum/powernet/PN = E.get_direct_powernet()
			if(PN?.avail <= 0)
				command_alert("Reports indicate that the engine on-board [station_name()] has not yet been started. Setting up the engine is strongly recommended, or else stationwide power failures may occur.", "Power Grid Warning", alert_origin = ALERT_STATION)
			break

	if(!countJob("AI")) // There is no roundstart AI, spawn in a Latejoin AI on the spawn landmark.
		for(var/turf/T in job_start_locations["AI"])
			new /mob/living/silicon/ai/latejoin(T)

	if(!processScheduler.isRunning)
		processScheduler.start()

	if (total_clients() >= OVERLOAD_PLAYERCOUNT)
		world.tick_lag = OVERLOADED_WORLD_TICKLAG
	else if (total_clients() >= SEMIOVERLOAD_PLAYERCOUNT)
		world.tick_lag = SEMIOVERLOADED_WORLD_TICKLAG

/datum/controller/gameticker/proc/roundstart_player_count(loud = TRUE)
	var/readied_count = 0
	var/unreadied_count = 0
	for (var/client/C in global.clients)
		var/mob/new_player/mob = C.mob
		if (istype(mob))
			if (mob.ready)
				readied_count++
			else
				unreadied_count++
	var/total = readied_count + (unreadied_count/2)
	if (loud)
		logTheThing(LOG_GAMEMODE, "Found [readied_count] readied players and [unreadied_count] unreadied ones, total count being fed to gamemode datum: [total]")
	return total

//Okay this is kinda stupid, but mapSwitcher.autoVoteDelay which is now set to 30 seconds, (used to be 5 min).
//The voting will happen 30 seconds into the pre-game lobby. This is probably fine to leave. But if someone changes that var then it might start before the lobby timer ends.
/datum/controller/gameticker/proc/handle_mapvote()
	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (!bustedMapSwitcher)
		SPAWN(mapSwitcher.autoVoteDelay)
			//Trigger the automatic map vote
			try
				mapSwitcher.startMapVote(duration = mapSwitcher.autoVoteDuration)
			catch (var/exception/e)
				logTheThing(LOG_ADMIN, usr ? usr : src, null, "the automated map switch vote couldn't run because: [e.name]")
				logTheThing(LOG_DIARY, usr ? usr : src, null, "the automated map switch vote couldn't run because: [e.name]", "admin")
				message_admins("[key_name(usr ? usr : src)] the automated map switch vote couldn't run because: [e.name]")

/datum/controller/gameticker
	proc/distribute_jobs()
		DivideOccupations()

	proc/create_characters()
		// SHOULD_NOT_SLEEP(TRUE)
		for (var/mob/new_player/player in mobs)
#ifdef TWITCH_BOT_ALLOWED
			if (player.twitch_bill_spawn)
				player.try_force_into_bill()
				continue
#endif

			if (player.ready)
				var/datum/player/P
				if (player.mind)
					P = player.mind.get_player()

				if (player.mind.ckey)
					//Record player participation in this round via the goonhub API
					participationRecorder.record(P)

				if (player.mind && player.mind.assigned_role == "AI")
					player.close_spawn_windows()
					var/mob/living/silicon/ai/A = player.AIize()
					A.Equip_Bank_Purchase(A.mind.purchased_bank_item)

				else if (player.mind && player.mind.special_role == ROLE_WRAITH)
					player.close_spawn_windows()
					logTheThing(LOG_DEBUG, player, "<b>Late join</b>: assigned antagonist role: wraith.")
					SPAWN(0)
						antagWeighter.record(role = ROLE_WRAITH, P = P)

				else if (player.mind && player.mind.special_role == ROLE_BLOB)
					player.close_spawn_windows()
					logTheThing(LOG_DEBUG, player, "<b>Late join</b>: assigned antagonist role: blob.")
					SPAWN(0)
						antagWeighter.record(role = ROLE_BLOB, P = P)

				else if (player.mind && player.mind.special_role == ROLE_FLOCKMIND)
					player.close_spawn_windows()
					logTheThing(LOG_DEBUG, player, "<b>Late join</b>: assigned antagonist role: flockmind.")
					SPAWN(0)
						antagWeighter.record(role = ROLE_FLOCKMIND, P = P)

				else if (player.mind)
					if (player.client.using_antag_token && ticker.mode.antag_token_support)
						player.client.use_antag_token()	//Removes a token from the player
					player.create_character()
					qdel(player)

	proc/add_minds(var/periodic_check = 0)
		// SHOULD_NOT_SLEEP(TRUE)
		for (var/mob/player in mobs)
			// Who cares about NPCs? Adding them here breaks all antagonist objectives
			// that attempt to scale with total player count (Convair880).
			if (player.mind && !istype(player, /mob/new_player) && player.client)
				if (!(player.mind in ticker.minds))
					if (periodic_check == 1)
						logTheThing(LOG_DEBUG, player, "<b>Gameticker fallback:</b> re-added player to ticker.minds.")
					else
						logTheThing(LOG_DEBUG, player, "<b>Gameticker setup:</b> added player to ticker.minds. [player.mind.on_ticker_add_log()]")
					ticker.minds.Add(player.mind)

	proc/implant_skull_key()
		//Hello, I will sneak in a solarium thing here.
		if(!skull_key_assigned && length(ticker.minds) > 5) //Okay enough gaming the system you pricks
			var/list/HL = list()
			for (var/mob/living/carbon/human/human in mobs)
				if (human.client)
					HL += human

			if(length(HL) > 5)
				var/mob/living/carbon/human/H = pick(HL)
				if(istype(H))
					skull_key_assigned = 1
					SPAWN(5 SECONDS)
						if(H.organHolder && H.organHolder.skull)
							H.organHolder.skull.key = new /obj/item/device/key/skull (H.organHolder.skull)
							logTheThing(LOG_DEBUG, H, "has the dubious pleasure of having a key embedded in their skull.")
						else
							skull_key_assigned = 0
		else if(!skull_key_assigned)
			logTheThing(LOG_DEBUG, null, "<B>SpyGuy/collar key:</B> Did not implant a key because there was not enough players.")

	proc/equip_characters()
		// SHOULD_NOT_SLEEP(TRUE)
		for(var/mob/living/carbon/human/player in mobs)
			if(player.mind && player.mind.assigned_role)
				if(player.mind.assigned_role != "MODE")
					player.Equip_Rank(player.mind.assigned_role)
				spawn_rules_controller.apply_to(player)
				player.apply_roundstart_events()

	proc/process()
		if(current_state != GAME_STATE_PLAYING)
			return 0

		updateRoundTime()

		mode.process()
#ifdef HALLOWEEN
		spooktober_GH.update()
#endif

		#ifdef APRIL_FOOLS
		if(prob(0.1))
			if(isnull(random_floor_turfs))
				build_random_floor_turf_list()
			var/turf/T = pick(random_floor_turfs)
			new /mob/living/critter/jeans_elemental(T)
		#endif

		wagesystem.process()

		emergency_shuttle.process()

		if (useTimeDilation)//TIME_DILATION_ENABLED set this
			if (world.time > last_try_dilate + TICKLAG_DILATE_INTERVAL) //interval separate from the process loop. maybe consider moving this for cleanup later (its own process loop with diff. interval?)
				last_try_dilate = world.time

				// adjust the counter up or down and keep it within the set boundaries
				if (world.cpu >= TICKLAG_CPU_MAX)
					if (highCpuCount < TICKLAG_INCREASE_THRESHOLD)
						highCpuCount++
				else if (world.cpu <= TICKLAG_CPU_MIN)
					if (highCpuCount > -TICKLAG_DECREASE_THRESHOLD)
						highCpuCount--

				if (world.map_cpu >= TICKLAG_MAPCPU_MAX)
					if (highMapCpuCount < TICKLAG_INCREASE_THRESHOLD)
						highMapCpuCount++
				else if (world.map_cpu <= TICKLAG_MAPCPU_MIN)
					if (highMapCpuCount > -TICKLAG_DECREASE_THRESHOLD)
						highMapCpuCount--

				// adjust the tick_lag, if needed
				var/dilated_tick_lag
				if (max(highCpuCount, highMapCpuCount) >= TICKLAG_INCREASE_THRESHOLD)
					dilated_tick_lag = round(min(world.tick_lag + TICKLAG_DILATION_INC,	timeDilationUpperBound), min(TICKLAG_DILATION_INC, TICKLAG_DILATION_DEC))
				else if (max(highCpuCount, highMapCpuCount) <= -TICKLAG_DECREASE_THRESHOLD)
					dilated_tick_lag = round(max(world.tick_lag - TICKLAG_DILATION_DEC, timeDilationLowerBound), min(TICKLAG_DILATION_INC, TICKLAG_DILATION_DEC))

				// only set the value if it changed! earlier iteration of this was
				// setting world.tick_lag very often, which caused instability with
				// the networking. do not spam change world.tick_lag! you will regret it!
				if (dilated_tick_lag && (round(world.tick_lag, 0.1) != dilated_tick_lag))
					world.tick_lag = dilated_tick_lag
					highCpuCount = 0
					highMapCpuCount = 0

		// Minds are sometimes kicked out of the global list, hence the fallback (Convair880).
		if (src.last_readd_lost_minds_to_ticker && world.time > src.last_readd_lost_minds_to_ticker + 1800)
			src.add_minds(1)
			src.last_readd_lost_minds_to_ticker = world.time

		if(mode.check_finished())
			current_state = GAME_STATE_FINISHED

			// This does a little more than just declare - it handles all end of round processing
			try
				declare_completion()
			catch(var/exception/e)
				logTheThing(LOG_DEBUG, null, "Game Completion Runtime: [e.file]:[e.line] - [e.name] - [e.desc]")
				logTheThing(LOG_DIARY, null, "Game Completion Runtime: [e.file]:[e.line] - [e.name] - [e.desc]", "debug")

			// Various round end tracking for Goonhub
			src.sendEvents()
			record_player_playtime()
			roundManagement.recordEnd()

			// In a funny twist of fate there was no actual logging that the round was officially over.
			var/total_round_time = (TIME - round_start_time) / (1 SECOND)
			logTheThing(LOG_STATION, null, "The round is now over. Round time: [round(total_round_time / 3600)]:[add_zero(total_round_time / 60 % 60, 2)]:[add_zero(total_round_time % 60, 2)]")

			// Official go-ahead to be an end-of-round asshole
			boutput(world, "<h3>The round has ended!</h3><strong style='color: #393;'>Further actions will have no impact on round results. Go hog wild!</strong>")

			SPAWN(0)
				change_ghost_invisibility(INVIS_NONE)
				var/datum/client_image_group/image_group = get_image_group(CLIENT_IMAGE_GROUP_ALL_ANTAGONISTS)
				for(var/client/client in global.clients)
					image_group.add_client(client)

			// i feel like this should probably be a proc call somewhere instead but w/e
			if (!ooc_allowed)
				ooc_allowed = 1
				boutput(world, "<B>OOC is now enabled.</B>")

			SPAWN(5 SECONDS)
				//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] game-ending spawn happening")

				boutput(world, "<span class='bold notice'>A new round will begin soon.</span>")

				var/datum/hud/roundend/roundend_countdown = new()

				for (var/client/C in clients)
					roundend_countdown.add_client(C)

				var/roundend_time = 60
				while (roundend_time >= 0)
					roundend_countdown.update_time(roundend_time)
					sleep(1 SECONDS)
					roundend_time--

				//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] one minute delay, game should restart now")
				if (game_end_delayed == 1)
					roundend_countdown.update_delayed()

					message_admins(SPAN_INTERNAL("Server would have restarted now, but the restart has been delayed[game_end_delayer ? " by [game_end_delayer]" : null]. Remove the delay for an immediate restart."))
					game_end_delayed = 2
					var/ircmsg[] = new()
					ircmsg["msg"] = "Server would have restarted now, but the restart has been delayed[game_end_delayer ? " by [game_end_delayer]" : null]."
					ircbot.export_async("admin", ircmsg)

					if (game_end_delayer)
						var/client/delayerClient = find_client(ckey(game_end_delayer))
						if (delayerClient) delayerClient.flash_window()
				else
					ircbot.event("roundend")
					//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] REBOOTING THE SERVER!!!!!!!!!!!!!!!!!")
					Reboot_server()

		return 1

	proc/updateRoundTime()
		if (round_time_check)
			var/elapsed = world.timeofday - round_time_check
			round_time_check = world.timeofday

			if (round_time_check == 0) // on the slim chance that this happens exactly on a timeofday rollover
				round_time_check = 1   // make it nonzero so it doesn't quit updating

			if (elapsed > 0)
				ticker.round_elapsed_ticks += elapsed

	proc/sendEvents()
		try
			// Antags and antag objectives
			for (var/datum/antagonist/antagonist_role as anything in get_all_antagonists())
				var/datum/mind/M = antagonist_role.owner
				var/datum/eventRecord/Antag/antagEvent = new()
				antagEvent.buildAndSend(antagonist_role)

				if (M.objectives)
					for (var/datum/objective/objective in M.objectives)
		#ifdef CREW_OBJECTIVES
						if (istype(objective, /datum/objective/crew)) continue
		#endif
						var/datum/eventRecord/AntagObjective/antagObjectiveEvent = new()
						antagObjectiveEvent.buildAndSend(antagonist_role, objective)

			// AI Laws
			for_by_tcl(aiPlayer, /mob/living/silicon/ai)
				var/laws[] = new()
				if (aiPlayer.lawset_connection)
					laws = aiPlayer.lawset_connection.format_for_irc()
				for (var/key in laws)
					var/datum/eventRecord/AILaw/aiLawEvent = new()
					aiLawEvent.buildAndSend(aiPlayer, key, laws[key])
		catch(var/exception/e)
			logTheThing(LOG_DEBUG, null, "Gameticker Send Events Runtime: [e.file]:[e.line] - [e.name] - [e.desc]")
			logTheThing(LOG_DIARY, null, "Gameticker Send Events Runtime: [e.file]:[e.line] - [e.name] - [e.desc]", "debug")


/datum/controller/gameticker/proc/declare_completion()
	//End of round statistic collection for goonhub
	save_flock_stats()

	var/pets_rescued = 0
	for(var/pet in by_cat[TR_CAT_PETS])
		if(iscritter(pet))
			var/obj/critter/P = pet
			if(P.alive && in_centcom(P)) pets_rescued++
		else if(ismobcritter(pet))
			var/mob/living/critter/P = pet
			if(isalive(P) && in_centcom(P)) pets_rescued++
		else if(istype(pet, /obj/item/rocko) && in_centcom(pet)) pets_rescued++

	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] Processing end-of-round generic medals")
	var/list/all_the_baddies = ticker.mode.traitors + ticker.mode.token_players + ticker.mode.Agimmicks + ticker.mode.former_antagonists
	for(var/mob/living/player in mobs)
		if (player.client)
			if (!isdead(player))
				if (in_centcom(player))
					player.unlock_medal("100M dash", 1)
					if (pets_rescued >= 7)
						player.unlock_medal("Noah's Shuttle", 1)
				player.unlock_medal("Survivor", 1)

				if (player.check_contents_for(/obj/item/gnomechompski))
					player.unlock_medal("Guardin' gnome", 1)

				if (player.mind.assigned_role == "Security Assistant")
					player.unlock_medal("I helped!", 1)

				if (ishuman(player))
					var/mob/living/carbon/human/H = player
					if (H && istype(H) && H.implant && length(H.implant) > 0)
						var/bullets = 0
						for (var/obj/item/implant/I in H)
							if (istype(I, /obj/item/implant/projectile))
								bullets = 1
								break
						if (bullets > 0)
							H.unlock_medal("It's just a flesh wound!", 1)
					if (H.limbs && (!H.limbs.l_arm && !H.limbs.r_arm))
						H.unlock_medal("Mostly Armless", 1)

#ifdef CREW_OBJECTIVES
	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] Processing crew objectives")
	var/list/successfulCrew = list()
	for (var/datum/mind/crewMind in minds)
		if (!crewMind.current || !length(crewMind.objectives))
			continue

		var/count = 0
		var/allComplete = 1
		crewMind.all_objs = 1
		for (var/datum/objective/crew/CO in crewMind.objectives)
			count++
			if(CO.check_completion())
				crewMind.completed_objs++
				boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] [SPAN_SUCCESS("<B>Success</B>")]")
				JOB_XP(crewMind.current, crewMind.assigned_role, CO.XPreward)
				logTheThing(LOG_DIARY, crewMind, "completed objective: [CO.explanation_text]")
				if (!isnull(CO.medal_name) && !isnull(crewMind.current))
					crewMind.current.unlock_medal(CO.medal_name, CO.medal_announce)
			else
				boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] [SPAN_ALERT("Failed")]")
				logTheThing(LOG_DIARY, crewMind, "failed objective: [CO.explanation_text]. Bummer!")
				allComplete = 0
				crewMind.all_objs = 0
		if (allComplete && count)
			successfulCrew += "[crewMind.current.real_name] ([crewMind.displayed_key])"
		boutput(crewMind.current, "<br>")
#endif

	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] mode.declare_completion()")
	mode.declare_completion()
	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] mode.declare_completion() done - calculating score")

	score_tracker.calculate_score()
	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] score calculated")

	src.creds = new /datum/crewCredits

	var/final_score = score_tracker.final_score_all
	if (final_score > 200)
		final_score = 200
	else if (final_score <= 0)
		final_score = 0
	else
		final_score = 100

	if(!score_tracker.score_calculated)
		final_score = 100

	boutput(world, score_tracker.escapee_facts())
	boutput(world, score_tracker.heisenhat_stats())
	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] ai law display")
	boutput(world, "<b>AIs and Cyborgs had the following laws at the end of the game:</b><br>[ticker.ai_law_rack_manager.format_for_logs("<br>", TRUE)]")


	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] resetting gauntlet (why? who cares! the game is over!)")
	if (gauntlet_controller.state)
		gauntlet_controller.resetArena()
#ifdef CREW_OBJECTIVES
	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] displaying completed crew objectives")
	if (successfulCrew.len)
		boutput(world, "<B>The following crewmembers completed all of their Crew Objectives:</B><br>[successfulCrew.Join("<br>")]<br>Good job!")
	else
		boutput(world, "<B>Nobody completed all of their Crew Objectives!</B>")
#endif

	// DO THE PERSISTENT_BANK STUFF
	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] processing spacebux updates")

	// Sample world time to calculate wage loss for latejoiners later
	var/game_end_time = world.time

	logTheThing(LOG_DEBUG, null, "Revving up the spacebux loop...")

	/// list of ckeys and keypairs to bulk commit
	var/list/bulk_commit = list()
	for(var/mob/player in mobs)
		if (player?.client && player.mind && !player.mind.get_player()?.joined_observer && !istype(player,/mob/new_player))
			logTheThing(LOG_DEBUG, null, "Iterating on [player.client]")
			player.mind.personal_summary = new /datum/personal_summary
			//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] spacebux calc start: [player.mind.ckey]")

			//get base wage + initial earnings calculation
			var/job_wage = 100
			if (player.mind.assigned_role != null && istext(player.mind.assigned_role))
				var/datum/job/J = find_job_in_controller_by_string(player.mind.assigned_role)
				if (istype(J))
					job_wage = J.wages

			var/job_wage_converted = 100
			switch(job_wage)
				if(0 to PAY_DUMBCLOWN)
					job_wage_converted = 100
				if(PAY_DUMBCLOWN+1 to PAY_UNTRAINED)
					job_wage_converted = PAY_UNTRAINED
				if(PAY_UNTRAINED+1 to PAY_TRADESMAN)
					job_wage_converted = PAY_TRADESMAN
				if(PAY_TRADESMAN+1 to PAY_DOCTORATE)
					job_wage_converted = PAY_DOCTORATE
				if(PAY_DOCTORATE+1 to PAY_IMPORTANT)
					job_wage_converted = PAY_IMPORTANT
				if(PAY_IMPORTANT+1 to INFINITY)
					job_wage_converted = PAY_EXECUTIVE

			job_wage = job_wage_converted

			if (isrobot(player))
				var/mob/living/silicon/robot/borg = player
				if(borg.shell) // is this secretly an AI??
					job_wage = PAY_IMPORTANT
				else
					job_wage = PAY_DOCTORATE
			if (isAI(player) || isshell(player))
				job_wage = PAY_IMPORTANT

			//if part-time, reduce wage
			if (player.mind.join_time > LATEJOIN_FULL_WAGE_GRACE_PERIOD) //grace period of 9 mins after roundstart to be a full-time employee
				var/lossRatio = ((game_end_time - player.mind.join_time) / game_end_time)
				job_wage = job_wage * lossRatio
				player.mind.personal_summary.is_part_time = TRUE

			var/earnings = final_score/100 * job_wage * 2 //TODO ECNONMY_REBALANCE: remove the *2
			player.mind.personal_summary.base_wage = round(job_wage * 2)  //TODO ECNONMY_REBALANCE: remove the *2
			player.mind.personal_summary.score_adjusted_wage = round(earnings)

			//check if escaped
			//if we are dead - get the location of our corpse
			var/player_body_escaped = in_centcom(player)
			var/player_loses_held_item = isdead(player) || isVRghost(player) || isghostcritter(player)
			if (istype(player,/mob/dead/observer))
				player_loses_held_item = 1
				var/mob/dead/observer/O = player
				if (O.corpse)
					player_body_escaped = in_centcom(O.corpse)
				else
					player_body_escaped = 0
			else if (istype(player,/mob/dead/target_observer))
				player_loses_held_item = 1
				var/mob/dead/target_observer/O = player
				if (O.corpse)
					player_body_escaped = in_centcom(O.corpse)
				else
					player_body_escaped = 0
			else if (isghostdrone(player))
				player_loses_held_item = 1
				player_body_escaped = 0

			//AI doesn't need to escape
			if (isAI(player) || isshell(player))
				player_body_escaped = 1
				if (isAIeye(player))
					var/mob/living/intangible/aieye/E = player
					player_loses_held_item = isdead(E.mainframe)

			if (!mode.escape_possible)
				player_body_escaped = 1
				if (istype(mode, /datum/game_mode/nuclear)) //bleh the nuke thing kills everyone
					player_loses_held_item = 0

			if (player_body_escaped)
				player.mind.personal_summary.is_escaped = TRUE
			else
				earnings = (earnings/4)
				player.mind.personal_summary.is_escaped = FALSE
				player_loses_held_item = 1

			//handle traitors
			if (player.mind && (player.mind in ticker.mode.traitors)) // Roundstart people get the full bonus
				earnings = job_wage
				player.mind.personal_summary.is_antagonist = TRUE
				player_loses_held_item = 0
			else if (istype(player.loc, /obj/cryotron) || player.mind && (player.mind in all_the_baddies)) // Cryo'd or was a baddie at any point? Keep your shit, but you don't get the extra bux
				player_loses_held_item = 0
			//some might not actually have a wage
			if (!isvirtual(player) && ((isnukeop(player) || isnukeopgunbot(player)) ||  (isblob(player) && (player.mind && player.mind.special_role == ROLE_BLOB)) || iswraith(player) || (iswizard(player) && (player.mind && player.mind.special_role == ROLE_WIZARD)) ))
				player.mind.personal_summary.base_wage = 0 //only effects the end of round display
				earnings = 800

			if (player.mind.completed_objs > 0)
				earnings += (player.mind.completed_objs * 50) // CREW OBJECTIVE SBUX, ONE OBJECTIVE
				player.mind.personal_summary.objective_completed_bonus = (player.mind.completed_objs * 50)
				if (player.mind.all_objs)
					earnings += 100; // ALL CREW OBJECTIVE SBUX BONUS
					player.mind.personal_summary.all_objectives_bonus = 100


			//pilot's bonus check and reward
			var/pilot_bonus = 500 //for receipt
			if(!isdead(player) && in_centcom(player))
				if (player.buckled)
					if (istype(player.buckled,/obj/stool/chair/comfy/shuttle/pilot))
						player.mind.personal_summary.is_pilot = TRUE
						earnings += pilot_bonus
				else if (isAI(player))
					var/mob/living/silicon/ai/M = null
					if (isAIeye(player))
						M = player:mainframe
					else
						M = player
					var/obj/stool/chair/comfy/shuttle/pilot/O = locate() in M.loc
					if (O && !O.buckled_guy) //no double piloting
						player.mind.personal_summary.is_pilot = TRUE
						earnings += pilot_bonus

			//add_to_bank and show earnings receipt
			earnings = round(earnings)
			//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] spacebux calc finish: [player.mind.ckey]")

			if(player.client)
				if (player_loses_held_item)
					logTheThing(LOG_DEBUG, null, "[player.ckey] lost held item")
					player.client.persistent_bank_item = "none"

				if (player.client.player.id)
					if (player.client.persistent_bank_valid)
						bulk_commit["[bulk_commit.len + 1]"] = list(
							"player_id" = player.client.player.id,
							"key" = "persistent_bank",
							"value" = player.client.persistent_bank + earnings
						)
					bulk_commit["[bulk_commit.len + 1]"] = list(
						"player_id" = player.client.player.id,
						"key" = "persistent_bank_item",
						"value" = player.client.persistent_bank_item
					)

				SPAWN(0)
					player.mind.personal_summary.pilot_bonus = pilot_bonus
					player.mind.personal_summary.earned_spacebux = earnings
					if (player.client) // client shit
						player.mind.personal_summary.held_item = player.client.persistent_bank_item
					if (player.client)
						player.mind.personal_summary.total_spacebux = player.client.persistent_bank + earnings


	//do bulk commit
	SPAWN(0)
		cloud_saves_put_data_bulk(bulk_commit)
		logTheThing(LOG_DEBUG, null, "Done with spacebux")

	for_by_tcl(P, /obj/bookshelf/persistent) //make the bookshelf save its contents
		P.build_curr_contents()

#ifdef SECRETS_ENABLED
	for_by_tcl(S, /obj/santa_helper)
		S.save_mail()
#endif

	logTheThing(LOG_DEBUG, null, "Done with books")

	award_archived_round_xp()

	logTheThing(LOG_DEBUG, null, "Spawned XP")

	logTheThing(LOG_DEBUG, null, "Power Generation: [json_encode(station_power_generation)]")

	var/ptl_cash = 0
	for(var/obj/machinery/power/pt_laser/P in machine_registry[MACHINES_POWER])
		ptl_cash += P.lifetime_earnings
	if(ptl_cash)
		logTheThing(LOG_DEBUG, null, "PTL Cash: [ptl_cash]")

	var/is_inspector_report = (length(score_tracker.inspector_report) > 0)
	var/is_tickets_or_fines = (length(creds.citation_tab_data[CITATION_TAB_SECTION_TICKETS]) || length(creds.citation_tab_data[CITATION_TAB_SECTION_FINES]))

	SPAWN(0)
		for(var/mob/E in mobs)
			if(E.client)
				if (!E.abilityHolder)
					E.add_ability_holder(/datum/abilityHolder/generic)
				E.addAbility(/datum/targetable/crew_credits)
				if (E.client.preferences.view_score)
					creds.ui_interact(E)
				else if (E.client.preferences.view_tickets && is_tickets_or_fines)
					creds.ui_interact(E)
				if(is_inspector_report)
					E.show_inspector_report()
					E.addAbility(/datum/targetable/inspector_report)
				SPAWN(0)
					E.mind.personal_summary.generate_xp(E.key)
					E.mind.personal_summary.ui_interact(E)
					E.addAbility(/datum/targetable/personal_summary)

	logTheThing(LOG_DEBUG, null, "Did credits")

	if(global.lag_detection_process.automatic_profiling_on)
		global.lag_detection_process.automatic_profiling(force_stop=TRUE)

	return 1

/datum/controller/gameticker/proc/get_credits()
	RETURN_TYPE(/datum/crewCredits)
	if (!src.creds)
		src.creds = new /datum/crewCredits
	return src.creds

#undef LATEJOIN_FULL_WAGE_GRACE_PERIOD
