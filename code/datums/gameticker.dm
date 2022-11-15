var/global/datum/controller/gameticker/ticker
var/global/current_state = GAME_STATE_WORLD_INIT

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

	var/skull_key_assigned = 0

	var/tmp/last_try_dilate = 0
	var/tmp/useTimeDilation = TIME_DILATION_ENABLED
	var/tmp/timeDilationLowerBound = MIN_TICKLAG
	var/tmp/timeDilationUpperBound = OVERLOADED_WORLD_TICKLAG
	var/tmp/highMapCpuCount = 0 // how many times in a row has the map_cpu been high

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



	var/did_mapvote = 0
	if (!player_capa)
		new /obj/overlay/zamujasa/round_start_countdown/encourage()
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
				did_mapvote = 1

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


	SPAWN(0) setup()

/datum/controller/gameticker/proc/setup()
	set background = 1
	//Create and announce mode

	switch(master_mode)
		if("random","secret") src.mode = config.pick_random_mode()
		if("action") src.mode = config.pick_mode(pick("nuclear", "wizard", "blob", "flock"))
		if("intrigue") src.mode = config.pick_mode(pick(prob(300);"mixed_rp", prob(200); "traitor", prob(75);"changeling","vampire", prob(50); "conspiracy", "spy_theft","arcfiend", prob(50); "extended"))
		if("pod_wars") src.mode = config.pick_mode("pod_wars")
		else src.mode = config.pick_mode(master_mode)

#if defined(MAP_OVERRIDE_POD_WARS)
	src.mode = config.pick_mode("pod_wars")
#endif

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

	//Configure mode and assign player to special mode stuff
	var/can_continue = src.mode.pre_setup()

	if(!can_continue)
		qdel(mode)

		current_state = GAME_STATE_PREGAME
		boutput(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")

		SPAWN(0) pregame()

		return 0

	logTheThing(LOG_DEBUG, null, "Chosen game mode: [mode] ([master_mode]) on map [getMapNameFromID(map_setting)].")

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

	//Equip characters
	equip_characters()

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


	current_state = GAME_STATE_PLAYING
	round_time_check = world.timeofday

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

		logTheThing(LOG_OOC, null, "<b>Current round begins</b>")
		boutput(world, "<FONT class='notice'><B>Enjoy the game!</B></FONT>")
		boutput(world, "<span class='notice'><b>Tip:</b> [pick(dd_file2list("strings/roundstart_hints.txt"))]</span>")

		//Setup the hub site logging
		var hublog_filename = "data/stats/data.txt"
		if (fexists(hublog_filename))
			fdel(hublog_filename)

		hublog = file(hublog_filename)
		hublog << ""

		//Tell the participation recorder that we're done FAFFING ABOUT
		participationRecorder.releaseHold()

#ifdef MAP_OVERRIDE_NADIR
	SPAWN(30 MINUTES) // special catalytic engine warning
		for(var/obj/machinery/power/catalytic_generator/CG in machine_registry[MACHINES_POWER])
			LAGCHECK(LAG_LOW)
			if(CG?.gen_rate < 70000 WATTS)
				command_alert("Reports indicate that one or more catalytic generators on [station_name()] may require replacement rods for continued operation. If catalytic rods are not replaced, this may result in sitewide power failures.", "Power Grid Warning")
			break
#else
	SPAWN(10 MINUTES) // standard engine warning
		for(var/obj/machinery/computer/power_monitor/smes/E in machine_registry[MACHINES_POWER])
			LAGCHECK(LAG_LOW)
			var/datum/powernet/PN = E.get_direct_powernet()
			if(PN?.avail <= 0)
				command_alert("Reports indicate that the engine on-board [station_name()] has not yet been started. Setting up the engine is strongly recommended, or else stationwide power failures may occur.", "Power Grid Warning", alert_origin = ALERT_STATION)
			break
#endif

	for(var/turf/T in job_start_locations["AI"])
		if(isnull(locate(/mob/living/silicon/ai) in T))
			new /obj/item/clothing/suit/cardboard_box/ai(T)

	processScheduler.start()

	if (total_clients() >= OVERLOAD_PLAYERCOUNT)
		world.tick_lag = OVERLOADED_WORLD_TICKLAG
	else if (total_clients() >= SEMIOVERLOAD_PLAYERCOUNT)
		world.tick_lag = SEMIOVERLOADED_WORLD_TICKLAG

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
		for (var/mob/new_player/player in mobs)
#ifdef TWITCH_BOT_ALLOWED
			if (player.twitch_bill_spawn)
				player.try_force_into_bill()
				continue
#endif

			if (player.ready)
				if (player.mind && player.mind.ckey)
					//Record player participation in this round via the goonhub API
					participationRecorder.record(player.mind.ckey)

				if (player.mind && player.mind.assigned_role == "AI")
					player.close_spawn_windows()
					var/mob/living/silicon/ai/A = player.AIize()
					A.Equip_Bank_Purchase(A.mind.purchased_bank_item)

				else if (player.mind && player.mind.special_role == ROLE_WRAITH)
					player.close_spawn_windows()
					var/mob/wraith/W = player.make_wraith()
					if (W)
						W.set_loc(pick_landmark(LANDMARK_OBSERVER))
						logTheThing(LOG_DEBUG, W, "<b>Late join</b>: assigned antagonist role: wraith.")
						antagWeighter.record(role = ROLE_WRAITH, ckey = W.ckey)

				else if (player.mind && player.mind.special_role == ROLE_BLOB)
					player.close_spawn_windows()
					var/mob/living/intangible/blob_overmind/B = player.make_blob()
					if (B)
						B.set_loc(pick_landmark(LANDMARK_OBSERVER))
						logTheThing(LOG_DEBUG, B, "<b>Late join</b>: assigned antagonist role: blob.")
						antagWeighter.record(role = ROLE_BLOB, ckey = B.ckey)

				else if (player.mind && player.mind.special_role == ROLE_FLOCKMIND)
					player.close_spawn_windows()
					var/mob/living/intangible/flock/flockmind/F = player.make_flockmind()
					if (F)
						F.set_loc(pick_landmark(LANDMARK_OBSERVER))
						logTheThing(LOG_DEBUG, F, "<b>Late join</b>: assigned antagonist role: flockmind.")
						antagWeighter.record(role = ROLE_FLOCKMIND, ckey = F.ckey)

				else if (player.mind)
					if (player.client.using_antag_token && ticker.mode.antag_token_support)
						player.client.use_antag_token()	//Removes a token from the player
					player.create_character()
					qdel(player)

	proc/add_minds(var/periodic_check = 0)
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
		if(!skull_key_assigned && ticker.minds.len > 5) //Okay enough gaming the system you pricks
			var/list/HL = list()
			for (var/mob/living/carbon/human/human in mobs)
				if (human.client)
					HL += human

			if(HL.len > 5)
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
		for(var/mob/living/carbon/human/player in mobs)
			if(player.mind && player.mind.assigned_role)
				if(player.mind.assigned_role != "MODE")
					SPAWN(0)
						player.Equip_Rank(player.mind.assigned_role)

	proc/process()
		if(current_state != GAME_STATE_PLAYING)
			return 0

		updateRoundTime()

		mode.process()
#ifdef HALLOWEEN
		spooktober_GH.update()
#endif

		wagesystem.process()

		emergency_shuttle.process()

		#if DM_VERSION >= 514
		if (useTimeDilation)//TIME_DILATION_ENABLED set this
			if (world.time > last_try_dilate + TICKLAG_DILATE_INTERVAL) //interval separate from the process loop. maybe consider moving this for cleanup later (its own process loop with diff. interval?)
				last_try_dilate = world.time

				// adjust the counter up or down and keep it within the set boundaries
				if (world.map_cpu >= TICKLAG_MAPCPU_MAX)
					if (highMapCpuCount < TICKLAG_INCREASE_THRESHOLD)
						highMapCpuCount++
				else if (world.map_cpu <= TICKLAG_MAPCPU_MIN)
					if (highMapCpuCount > -TICKLAG_DECREASE_THRESHOLD)
						highMapCpuCount--

				// adjust the tick_lag, if needed
				var/dilated_tick_lag = world.tick_lag
				if (highMapCpuCount >= TICKLAG_INCREASE_THRESHOLD)
					dilated_tick_lag = min(world.tick_lag + TICKLAG_DILATION_INC,	timeDilationUpperBound)
				else if (highMapCpuCount <= -TICKLAG_DECREASE_THRESHOLD)
					dilated_tick_lag = max(world.tick_lag - TICKLAG_DILATION_DEC, timeDilationLowerBound)

				// only set the value if it changed! earlier iteration of this was
				// setting world.tick_lag very often, which caused instability with
				// the networking. do not spam change world.tick_lag! you will regret it!
				if (world.tick_lag != dilated_tick_lag)
					world.tick_lag = dilated_tick_lag
					highMapCpuCount = 0
		#endif

		// Minds are sometimes kicked out of the global list, hence the fallback (Convair880).
		if (src.last_readd_lost_minds_to_ticker && world.time > src.last_readd_lost_minds_to_ticker + 1800)
			src.add_minds(1)
			src.last_readd_lost_minds_to_ticker = world.time

		if(mode.check_finished())
			current_state = GAME_STATE_FINISHED

			// This does a little more than just declare - it handles all end of round processing
			//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] Starting declare_completion.")
			try
				declare_completion()
			catch(var/exception/e)
				logTheThing(LOG_DEBUG, null, "Game Completion Runtime: [e.file]:[e.line] - [e.name] - [e.desc]")
				logTheThing(LOG_DIARY, null, "Game Completion Runtime: [e.file]:[e.line] - [e.name] - [e.desc]", "debug")

			//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] Finished declare_completion. The round is now over.")

			// Official go-ahead to be an end-of-round asshole
			boutput(world, "<h3>The round has ended!</h3><strong style='color: #393;'>Further actions will have no impact on round results. Go hog wild!</strong>")

			SPAWN(0)
				change_ghost_invisibility(INVIS_NONE)
				for(var/mob/M in global.mobs)
					M.antagonist_overlay_refresh(bypass_cooldown=TRUE)

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

					message_admins("<span class='internal'>Server would have restarted now, but the restart has been delayed[game_end_delayer ? " by [game_end_delayer]" : null]. Remove the delay for an immediate restart.</span>")
					game_end_delayed = 2
					var/ircmsg[] = new()
					ircmsg["msg"] = "Server would have restarted now, but the restart has been delayed[game_end_delayer ? " by [game_end_delayer]" : null]."
					ircbot.export_async("admin", ircmsg)
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

/datum/controller/gameticker/proc/declare_completion()
	//End of round statistic collection for goonhub

	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] statlog_traitors")
	statlog_traitors()
	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] statlog_ailaws")
	statlog_ailaws(0)
	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] round_end_data")
	round_end_data(1) //Export round end packet (normal completion)

	var/pets_rescued = 0
	for(var/pet in by_cat[TR_CAT_PETS])
		if(iscritter(pet))
			var/obj/critter/P = pet
			if(P.alive && in_centcom(P)) pets_rescued++
		else if(ismobcritter(pet))
			var/mob/living/critter/P = pet
			if(isalive(P) && in_centcom(P)) pets_rescued++

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
					if (H && istype(H) && H.implant && H.implant.len > 0)
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
				boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] <span class='success'><B>Success</B></span>")
				logTheThing(LOG_DIARY, crewMind, "completed objective: [CO.explanation_text]")
				if (!isnull(CO.medal_name) && !isnull(crewMind.current))
					crewMind.current.unlock_medal(CO.medal_name, CO.medal_announce)
			else
				boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] <span class='alert'>Failed</span>")
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
	boutput(world, "<b>AIs and Cyborgs had the following laws at the end of the game:</b><br>[ticker.ai_law_rack_manager.format_for_logs("<br>",true)]")


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

	var/time = world.time

	logTheThing(LOG_DEBUG, null, "Revving up the spacebux loop...")

	/// list of ckeys and keypairs to bulk commit
	var/list/bulk_commit = list()
	for(var/mob/player in mobs)
		if (player?.client && player.mind && !player.mind.joined_observer && !istype(player,/mob/new_player))
			logTheThing(LOG_DEBUG, null, "Iterating on [player.client]")
			//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] spacebux calc start: [player.mind.ckey]")

			var/chui/window/earn_spacebux/bank_earnings = new

			//get base wage + initial earnings calculation
			var/job_wage = 100
			if (player.mind.assigned_role in wagesystem.jobs)
				job_wage = wagesystem.jobs[player.mind.assigned_role]

			if (isrobot(player))
				job_wage = 500
			if (isAI(player) || isshell(player))
				job_wage = 900

			//if part-time, reduce wage
			if (player.mind.join_time > 5400) //grace period of 9 mins after roundstart to be a full-time employee
				job_wage = (time - player.mind.join_time) / time * job_wage
				bank_earnings.part_time = 1

			var/earnings = final_score/100 * job_wage * 2 //TODO ECNONMY_REBALANCE: remove the *2

			bank_earnings.wage_base = round(job_wage * 2) //TODO ECNONMY_REBALANCE: remove the *2
			bank_earnings.wage_after_score = round(earnings)

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
				bank_earnings.escaped = 1
			else
				earnings = (earnings/4)
				bank_earnings.escaped = 0
				player_loses_held_item = 1

			//handle traitors
			if (player.mind && (player.mind in ticker.mode.traitors)) // Roundstart people get the full bonus
				earnings = job_wage
				bank_earnings.badguy = 1
				player_loses_held_item = 0
			else if (istype(player.loc, /obj/cryotron) || player.mind && (player.mind in all_the_baddies)) // Cryo'd or was a baddie at any point? Keep your shit, but you don't get the extra bux
				player_loses_held_item = 0
			//some might not actually have a wage
			if (!isvirtual(player) && ((isnukeop(player) || isnukeopgunbot(player)) ||  (isblob(player) && (player.mind && player.mind.special_role == ROLE_BLOB)) || iswraith(player) || (iswizard(player) && (player.mind && player.mind.special_role == ROLE_WIZARD)) ))
				bank_earnings.wage_base = 0 //only effects the end of round display
				earnings = 800

			if (player.mind.completed_objs > 0)
				earnings += (player.mind.completed_objs * 50) // CREW OBJECTIVE SBUX, ONE OBJECTIVE
				bank_earnings.completed_objs = (player.mind.completed_objs * 50)
				if (player.mind.all_objs)
					earnings += 100; // ALL CREW OBJECTIVE SBUX BONUS
					bank_earnings.all_objs = 100


			//pilot's bonus check and reward
			var/pilot_bonus = 500 //for receipt
			if(!isdead(player) && in_centcom(player))
				if (player.buckled)
					if (istype(player.buckled,/obj/stool/chair/comfy/shuttle/pilot))
						bank_earnings.pilot = 1
						earnings += pilot_bonus
				else if (isAI(player))
					var/mob/living/silicon/ai/M = null
					if (isAIeye(player))
						M = player:mainframe
					else
						M = player
					var/obj/stool/chair/comfy/shuttle/pilot/O = locate() in M.loc
					if (O && !O.buckled_guy) //no double piloting
						bank_earnings.pilot = 1
						earnings += pilot_bonus

			//add_to_bank and show earnings receipt
			earnings = round(earnings)
			//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] spacebux calc finish: [player.mind.ckey]")

			if(player.client)
				if (player_loses_held_item)
					logTheThing(LOG_DEBUG, null, "[player.ckey] lost held item")
					player.client.persistent_bank_item = "none"

				bulk_commit[player.ckey] = list(
					"persistent_bank" = list(
						"command" = "add",
						"value" = earnings
					),
					"persistent_bank_item" = list(
						"command" = "replace",
						"value" = player.client.persistent_bank_item
					)
				)
				SPAWN(0)
					bank_earnings.pilot_bonus = pilot_bonus
					bank_earnings.final_payout = earnings
					bank_earnings.held_item = player.client.persistent_bank_item
					bank_earnings.new_balance = player.client.persistent_bank + earnings
					bank_earnings.Subscribe( player.client )

	//do bulk commit
	SPAWN(0)
		cloud_put_bulk(json_encode(bulk_commit))
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

	SPAWN(0)
		//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] creds/new")
		var/chui/window/crew_credits/creds = new
		//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] displaying tickets and scores")
		for(var/mob/E in mobs)
			if(E.client)
				if (E.client.preferences.view_tickets)
					//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] sending tickets to [E.ckey]")
					E.showtickets()
					//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] done sending tickets to [E.ckey]")

				if (E.client.preferences.view_score)
					//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] sending crew credits to [E.ckey]")
					creds.Subscribe(E.client)
					//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] done crew credits to [E.ckey]")
				SPAWN(0) show_xp_summary(E.key, E)

		//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] done showing tickets/scores")

	logTheThing(LOG_DEBUG, null, "Did credits")

	//logTheThing(LOG_DEBUG, null, "Zamujasa: [world.timeofday] finished spacebux updates")

	var/list/playtimes = list() //associative list with the format list("ckeys\[[player_ckey]]" = playtime_in_seconds)
	for_by_tcl(P, /datum/player)
		if (!P.ckey)
			continue
		P.log_leave_time() //get our final playtime for the round (wont cause errors with people who already d/ced bc of smart code)
		if (!P.current_playtime)
			continue
		playtimes["ckeys\[[P.ckey]]"] = round((P.current_playtime / (1 SECOND))) //rounds 1/10th seconds to seconds
	try
		apiHandler.queryAPI("playtime/record-multiple", playtimes)
	catch(var/exception/e)
		logTheThing(LOG_DEBUG, null, "playtime was unable to be logged because of: [e.name]")
		logTheThing(LOG_DIARY, null, "playtime was unable to be logged because of: [e.name]", "debug")

	if(global.lag_detection_process.automatic_profiling_on)
		global.lag_detection_process.automatic_profiling(force_stop=TRUE)

	return 1
