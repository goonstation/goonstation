var/global/datum/controller/gameticker/ticker
var/global/current_state = GAME_STATE_WORLD_INIT
/* -- moved to _setup.dm
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4
*/
/datum/controller/gameticker
	//var/current_state = GAME_STATE_PREGAME
	//replaced with global

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/list/datum/mind/minds = list()
	var/last_readd_lost_minds_to_ticker = 1 // In relation to world time.

	var/pregame_timeleft = 0

	// this is actually round_elapsed_deciseconds
	var/round_elapsed_ticks = 0

	var/click_delay = 3

	var/datum/ai_laws/centralized_ai_laws

	var/skull_key_assigned = 0

	var/tmp/useTimeDilation = TIME_DILATION_ENABLED
	var/tmp/timeDilationLowerBound = MIN_TICKLAG
	var/tmp/timeDilationUpperBound = OVERLOADED_WORLD_TICKLAG
	var/tmp/last_tick_realtime = 0
	var/tmp/last_tick_byondtime = 0
	var/tmp/last_interval_tick_offset = 0 //how far off the last tick (byondtime - realtime)
	var/tmp/last_try_dilate = 0

	var/tmp/threshold_dilation = TICKLAG_DILATION_THRESHOLD	//remove later
	var/tmp/threshold_normalization = TICKLAG_NORMALIZATION_THRESHOLD //remove later

/datum/controller/gameticker/proc/pregame()

#ifdef SERVER_SIDE_PROFILING
#ifdef SERVER_SIDE_PROFILING_PREGAME
#warn Profiler will output at pregame stage
	var/profile_out = file("data/profile/[time2text(world.realtime, "YYYY-MM-DD hh-mm-ss")]-pregame.log")
	profile_out << world.Profile(PROFILE_START, "json")
	world.log << "Dumped profiler data."
#endif

#if defined(SERVER_SIDE_PROFILING_INGAME_ONLY)
#warn Profiler reset for ingame stage
	// We're in game now, so reset profiler data
	world.Profile(PROFILE_RESTART)
#elif !defined(SERVER_SIDE_PROFILING_FULL_ROUND)
#warn Profiler disabled after init
	// If we aren't doing ingame or full round then we're done with the profiler
	world.Profile(PROFILE_STOP)
#endif
#endif

	pregame_timeleft = PREGAME_LOBBY_TICKS
	boutput(world, "<B><FONT color='blue'>Welcome to the pre-game lobby!</FONT></B>")
	boutput(world, "Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds")
	#if ASS_JAM
	vote_manager.active_vote = new/datum/vote_new/mode("assday")
	boutput(world, "<B>ASS JAM: Ass Day Classic vote has been started: [newVoteLinkStat.chat_link()] (120 seconds remaining)<br>(or click on the Status map as you do for map votes)</B>")
	#endif

	// let's try doing this here, yoloooo
	if (mining_controls && mining_controls.mining_z && mining_controls.mining_z_asteroids_max)
		mining_controls.spawn_mining_z_asteroids()

	if(master_mode == "battle_royale")
		lobby_titlecard.icon_state += "_battle_royale"

	#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
	for(var/mob/new_player/C in world)
		C.ready = 1
	pregame_timeleft = 0
	#endif

	handle_mapvote()

	while(current_state <= GAME_STATE_PREGAME)
		sleep(1 SECOND)
		if (!game_start_delayed)
			pregame_timeleft--

		if(pregame_timeleft <= 0)
			current_state = GAME_STATE_SETTING_UP

	SPAWN_DBG(0) setup()

/datum/controller/gameticker/proc/setup()
	set background = 1
	//Create and announce mode
	if(master_mode in list("secret","action","intrigue","wizard","alien"))
		src.hide_mode = 1

	switch(master_mode)
		if("random","secret") src.mode = config.pick_random_mode()
		if("action") src.mode = config.pick_mode(pick("nuclear","wizard","blob"))
		if("intrigue") src.mode = config.pick_mode(pick("mixed_rp", "traitor","changeling","vampire","conspiracy","spy_theft", prob(50); "extended"))
		else src.mode = config.pick_mode(master_mode)

	if(hide_mode)
		#ifdef RP_MODE
		boutput(world, "<B>Have fun and RP!</B>")

		#else
		var/modes = sortList(config.get_used_mode_names())
		boutput(world, "<B>The current game mode is a secret!</B>")
		boutput(world, "<B>Possibilities:</B> [english_list(modes)]")

		#endif
	else
		src.mode.announce()

	// uhh is this where this goes??
	src.centralized_ai_laws = new /datum/ai_laws/asimov()

	//Configure mode and assign player to special mode stuff
	var/can_continue = src.mode.pre_setup()

	if(!can_continue)
		qdel(mode)

		current_state = GAME_STATE_PREGAME
		boutput(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")

		SPAWN_DBG(0) pregame()

		return 0

	logTheThing("debug", null, null, "Chosen game mode: [mode] ([master_mode]) on map [getMapNameFromID(map_setting)].")

	//Tell the participation recorder to queue player data while the round starts up
	participationRecorder.setHold()

#ifdef RP_MODE
	looc_allowed = 1
	boutput(world, "<B>LOOC has been automatically enabled.</B>")
#else
	if (it_is_ass_day || istype(src.mode, /datum/game_mode/construction))
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

	SPAWN_DBG(0)
		ircbot.event("roundstart")
		mode.post_setup()

		cleanup_landmarks()

		event_wormhole_buildturflist()

		mode.post_post_setup()

		for(var/obj/landmark/artifact/A in landmarks)
			LAGCHECK(LAG_LOW)
			if (prob(A.spawnchance))
				if (A.spawnpath)
					new A.spawnpath(A.loc)
				else
					Artifact_Spawn(A.loc)

		var/list/lootspawn = list()
		for(var/obj/landmark/S in landmarks)//world)
			if (S.name == "Loot spawn")
				lootspawn.Add(S.loc)
			LAGCHECK(LAG_LOW)
		if(lootspawn.len)
			var/lootamt = rand(5,15)
			while(lootamt > 0)
				LAGCHECK(LAG_LOW)
				var/lootloc = lootspawn.len ? pick(lootspawn) : null
				if (lootloc && prob(75))
					new/obj/storage/crate/loot(lootloc)
				--lootamt

		shippingmarket.get_market_timeleft()

		logTheThing("ooc", null, null, "<b>Current round begins</b>")
		boutput(world, "<FONT color='blue'><B>Enjoy the game!</B></FONT>")
		boutput(world, "<span class='notice'><b>Tip:</b> [pick(tips)]</span>")

		//Setup the hub site logging
		var hublog_filename = "data/stats/data.txt"
		if (fexists(hublog_filename))
			fdel(hublog_filename)

		hublog = file(hublog_filename)
		hublog << ""

		//Tell the participation recorder that we're done FAFFING ABOUT
		participationRecorder.releaseHold()

	SPAWN_DBG (6000) // 10 minutes in
		for(var/obj/machinery/power/generatorTemp/E in machine_registry[MACHINES_POWER])
			LAGCHECK(LAG_LOW)
			if (E.lastgen <= 0)
				command_alert("Reports indicate that the engine on-board [station_name()] has not yet been started. Setting up the engine is strongly recommended, or else stationwide power failures may occur.", "Power Grid Warning")
			break

	processScheduler.start()

	if (total_clients() >= OVERLOAD_PLAYERCOUNT)
		world.tick_lag = OVERLOADED_WORLD_TICKLAG

//Okay this is kinda stupid, but mapSwitcher.autoVoteDelay which is now set to 30 seconds, (used to be 5 min). 
//The voting will happen 30 seconds into the pre-game lobby. This is probably fine to leave. But if someone changes that var then it might start before the lobby timer ends.
/datum/controller/gameticker/proc/handle_mapvote()
	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (!bustedMapSwitcher)
		SPAWN_DBG (mapSwitcher.autoVoteDelay)
			//Trigger the automatic map vote
			try
				mapSwitcher.startMapVote(duration = mapSwitcher.autoVoteDuration)
			catch (var/exception/e)
				logTheThing("admin", usr ? usr : src, null, "the automated map switch vote couldn't run because: [e.name]")
				logTheThing("diary", usr ? usr : src, null, "the automated map switch vote couldn't run because: [e.name]", "admin")
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

				else if (player.mind && player.mind.special_role == "wraith")
					player.close_spawn_windows()
					var/mob/wraith/W = player.make_wraith()
					if (W)
						W.set_loc(pick(observer_start))
						logTheThing("debug", W, null, "<b>Late join</b>: assigned antagonist role: wraith.")
						antagWeighter.record(role = "wraith", ckey = W.ckey)

				else if (player.mind && player.mind.special_role == "blob")
					player.close_spawn_windows()
					var/mob/living/intangible/blob_overmind/B = player.make_blob()
					if (B)
						B.set_loc(pick(observer_start))
						logTheThing("debug", B, null, "<b>Late join</b>: assigned antagonist role: blob.")
						antagWeighter.record(role = "blob", ckey = B.ckey)

				else if (player.mind)
					if (player.client.using_antag_token)
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
						logTheThing("debug", player, null, "<b>Gameticker fallback:</b> re-added player to ticker.minds.")
					else
						logTheThing("debug", player, null, "<b>Gameticker setup:</b> added player to ticker.minds.")
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
					SPAWN_DBG(5 SECONDS)
						if(H.organHolder && H.organHolder.skull)
							H.organHolder.skull.key = new /obj/item/device/key/skull (H.organHolder.skull)
							logTheThing("debug", H, null, "has the dubious pleasure of having a key embedded in their skull.")
						else
							skull_key_assigned = 0
		else if(!skull_key_assigned)
			logTheThing("debug", null, null, "<B>SpyGuy/collar key:</B> Did not implant a key because there was not enough players.")

	proc/equip_characters()
		for(var/mob/living/carbon/human/player in mobs)
			if(player.mind && player.mind.assigned_role)
				if(player.mind.assigned_role != "MODE")
					SPAWN_DBG(0)
						player.Equip_Rank(player.mind.assigned_role)

	proc/process()
		if(current_state != GAME_STATE_PLAYING)
			return 0

		updateRoundTime()

		mode.process()
#ifdef HALLOWEEN
		spooktober_GH.update()
#endif

		emergency_shuttle.process()

		if (useTimeDilation)//TIME_DILATION_ENABLED set this
			if (world.time > last_try_dilate + TICKLAG_DILATE_INTERVAL) //interval separate from the process loop. maybe consider moving this for cleanup later (its own process loop with diff. interval?)
				last_try_dilate = world.time

				last_interval_tick_offset = max(0, (world.timeofday - last_tick_realtime) - (world.time - last_tick_byondtime))
				last_tick_realtime = world.timeofday
				last_tick_byondtime = world.time

				var/dilated_tick_lag = world.tick_lag

				if (last_interval_tick_offset >= threshold_dilation)
					dilated_tick_lag = 	min(world.tick_lag + TICKLAG_DILATION_INC,	timeDilationUpperBound)
				else if (last_interval_tick_offset <= threshold_normalization)
					dilated_tick_lag =	max(world.tick_lag - TICKLAG_DILATION_DEC, timeDilationLowerBound)

				if (world.tick_lag != dilated_tick_lag)
					world.tick_lag = dilated_tick_lag


		// Minds are sometimes kicked out of the global list, hence the fallback (Convair880).
		if (src.last_readd_lost_minds_to_ticker && world.time > src.last_readd_lost_minds_to_ticker + 1800)
			src.add_minds(1)
			src.last_readd_lost_minds_to_ticker = world.time

		if(mode.check_finished())
			current_state = GAME_STATE_FINISHED

			// This does a little more than just declare - it handles all end of round processing
			//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] Starting declare_completion.")
			try
				declare_completion()
			catch(var/exception/e)
				logTheThing("debug", null, null, "Game Completion Runtime: [e.file]:[e.line] - [e.name] - [e.desc]")
				logTheThing("diary", null, null, "Game Completion Runtime: [e.file]:[e.line] - [e.name] - [e.desc]", "debug")

			//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] Finished declare_completion. The round is now over.")

			// Official go-ahead to be an end-of-round asshole
			boutput(world, "<h3>The round has ended!</h3><strong style='color: #393;'>Further actions will have no impact on round results. Go hog wild!</strong>")

			// i feel like this should probably be a proc call somewhere instead but w/e
			if (!ooc_allowed)
				ooc_allowed = 1
				boutput(world, "<B>OOC is now enabled.</B>")

			SPAWN_DBG(5 SECONDS)
				//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] game-ending spawn happening")

				boutput(world, "<span class='bold notice'>A new round will begin soon.</span>")

				sleep(60 SECONDS)
				//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] one minute delay, game should restart now")

				if (game_end_delayed == 1)
					message_admins("<font color='blue'>Server would have restarted now, but the restart has been delayed[game_end_delayer ? " by [game_end_delayer]" : null]. Remove the delay for an immediate restart.</font>")
					game_end_delayed = 2
					var/ircmsg[] = new()
					ircmsg["msg"] = "Server would have restarted now, but the restart has been delayed[game_end_delayer ? " by [game_end_delayer]" : null]."
					ircbot.export("admin", ircmsg)
				else
					ircbot.event("roundend")
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] REBOOTING THE SERVER!!!!!!!!!!!!!!!!!")
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

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] statlog_traitors")
	statlog_traitors()
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] statlog_ailaws")
	statlog_ailaws(0)
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] round_end_data")
	round_end_data(1) //Export round end packet (normal completion)

	var/pets_rescued = 0
	for(var/pet in pets)
		if(iscritter(pet))
			var/obj/critter/P = pet
			if(P.alive && in_centcom(P)) pets_rescued++
		else if(ismobcritter(pet))
			var/mob/living/critter/P = pet
			if(isalive(P) && in_centcom(P)) pets_rescued++

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] Processing end-of-round generic medals")
	for(var/mob/living/player in mobs)
		if (player.client)
			if (!isdead(player))
				if (in_centcom(player))
					player.unlock_medal("100M dash", 1)
					if (pets_rescued >= 6)
						player.unlock_medal("Noah's Shuttle", 1)
				player.unlock_medal("Survivor", 1)

				if (player.check_contents_for(/obj/item/gnomechompski))
					player.unlock_medal("Guardin' gnome", 1)

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
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] Processing crew objectives")
	var/list/successfulCrew = list()
	for (var/datum/mind/crewMind in minds)
		if (!crewMind.current || !crewMind.objectives.len)
			continue

		var/count = 0
		var/allComplete = 1
		crewMind.all_objs = 1
		for (var/datum/objective/crew/CO in crewMind.objectives)
			count++
			if(CO.check_completion())
				crewMind.completed_objs++
				boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] <span class='success'><B>Success</B></span>")
				logTheThing("diary",crewMind,null,"completed objective: [CO.explanation_text]")
				if (!isnull(CO.medal_name) && !isnull(crewMind.current))
					crewMind.current.unlock_medal(CO.medal_name, CO.medal_announce)
			else
				boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] <span class='alert'>Failed</span>")
				logTheThing("diary",crewMind,null,"failed objective: [CO.explanation_text]. Bummer!")
				allComplete = 0
				crewMind.all_objs = 0

		if (allComplete && count)
			successfulCrew += "[crewMind.current.real_name] ([crewMind.key])"
#endif

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] mode.declare_completion()")
	mode.declare_completion()
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] mode.declare_completion() done - calculating score")

	score_tracker.calculate_score()
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] score calculated")

	var/final_score = score_tracker.final_score_all
	if (final_score > 200)
		final_score = 200
	else if (final_score <= 0)
		final_score = 0
	else
		final_score = 100

	boutput(world, score_tracker.escapee_facts())
	boutput(world, score_tracker.heisenhat_stats())

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] ai law display")
	for (var/mob/living/silicon/ai/aiPlayer in AIs)
		if (!isdead(aiPlayer))
			boutput(world, "<b>The AI, [aiPlayer.name] ([aiPlayer.get_message_mob().key]) had the following laws at the end of the game:</b>")
		else
			boutput(world, "<b>The AI, [aiPlayer.name] ([aiPlayer.get_message_mob().key]) had the following laws when it was deactivated:</b>")

		aiPlayer.show_laws(1)

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] resetting gauntlet (why? who cares! the game is over!)")
	if (gauntlet_controller.state)
		gauntlet_controller.resetArena()
#ifdef CREW_OBJECTIVES
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] displaying completed crew objectives")
	if (successfulCrew.len)
		boutput(world, "<B>The following crewmembers completed all of their Crew Objectives:</B>")
		for (var/i in successfulCrew)
			boutput(world, "<B>[i]</B>")
		boutput(world, "Good job!")
	else
		boutput(world, "<B>Nobody completed all of their Crew Objectives!</B>")
#endif
#ifdef MISCREANTS
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] displaying miscreants")
	boutput(world, "<B>Miscreants:</B>")
	if(miscreants.len == 0) boutput(world, "None!")
	for(var/datum/mind/miscreantMind in miscreants)
		if(!miscreantMind.objectives.len)
			continue

		var/miscreant_info = "[miscreantMind.key]"
		if(miscreantMind.current) miscreant_info = "[miscreantMind.current.real_name] ([miscreantMind.key])"

		boutput(world, "<B>[miscreant_info] was a miscreant!</B>")
		for (var/datum/objective/miscreant/O in miscreantMind.objectives)
			boutput(world, "Objective: [O.explanation_text] <B>Maybe</B>")
#endif

	// DO THE PERSISTENT_BANK STUFF
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] processing spacebux updates")

	var/escape_possible = 1
	if (istype(mode, /datum/game_mode/blob) || istype(mode, /datum/game_mode/nuclear) || istype(mode, /datum/game_mode/revolution))
		escape_possible = 0

	var/time = world.time
	for(var/mob/player in mobs)
		if (player.client && player.mind && !player.mind.joined_observer && !istype(player,/mob/new_player))
			//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] spacebux calc start: [player.mind.ckey]")

			var/chui/window/earn_spacebux/bank_earnings = new

			//get base wage + initial earnings calculation
			var/job_wage = 100
			if (wagesystem.jobs.Find(player.mind.assigned_role))
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
			var/player_dead = isdead(player) || isVRghost(player) || isghostcritter(player)
			if (istype(player,/mob/dead/observer))
				player_dead = 1
				var/mob/dead/observer/O = player
				if (O.corpse)
					player_body_escaped = in_centcom(O.corpse)
				else
					player_body_escaped = 0
			else if (istype(player,/mob/dead/target_observer))
				player_dead = 1
				var/mob/dead/target_observer/O = player
				if (O.corpse)
					player_body_escaped = in_centcom(O.corpse)
				else
					player_body_escaped = 0
			else if (isghostdrone(player))
				player_dead = 1
				player_body_escaped = 0

			//AI doesn't need to escape
			if (isAI(player) || isshell(player))
				player_body_escaped = 1
				if (isAIeye(player))
					var/mob/dead/aieye/E = player
					player_dead = isdead(E.mainframe)

			if (!escape_possible)
				player_body_escaped = 1
				if (istype(mode, /datum/game_mode/nuclear)) //bleh the nuke thing kills everyone
					player_dead = 0

			if (player_body_escaped)
				bank_earnings.escaped = 1
			else
				earnings = (earnings/4)
				bank_earnings.escaped = 0
				player_dead = 1



			//handle traitors
			if (player.mind && ticker.mode.traitors.Find(player.mind))
				earnings = job_wage
				bank_earnings.badguy = 1
				player_dead = 0
			//some might not actually have a wage
			if (isnukeop(player) ||  (isblob(player) && (player.mind && player.mind.special_role == "blob")) || iswraith(player) || (iswizard(player) && (player.mind && player.mind.special_role == "wizard")) )
				earnings = 800

			if (player.mind.completed_objs > 0)
				earnings += (player.mind.completed_objs * 50) // CREW OBJECTIVE SBUX, ONE OBJECTIVE
				bank_earnings.completed_objs = (player.mind.completed_objs * 50)
				if (player.mind.all_objs)
					earnings += 100; // ALL CREW OBJECTIVE SBUX BONUS
					bank_earnings.all_objs = 100

			if (it_is_ass_day)
				earnings *= 2

			//add_to_bank and show earnings receipt
			earnings = round(earnings)
			//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] spacebux calc finish: [player.mind.ckey]")

			SPAWN_DBG(0)
				if(player.client)
					player.client.add_to_bank(earnings)
					// Fix for persistent_bank-is-NaN bug
					if (player.client.persistent_bank != player.client.persistent_bank)
						player.client.set_persistent_bank(50000)
					if (player_dead)
						player.client.set_last_purchase(0)

					bank_earnings.final_payout = earnings
					bank_earnings.held_item = player.client.persistent_bank_item
					bank_earnings.new_balance = player.client.persistent_bank
					bank_earnings.Subscribe( player.client )

		for(var/obj/bookshelf/persistent/P in by_type[/obj/bookshelf/persistent]) //make the bookshelf save its contents
			P.build_curr_contents()

	SPAWN_DBG(0)
		//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] creds/new")
		var/chui/window/crew_credits/creds = new
		//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] displaying tickets and scores")
		for(var/mob/E in mobs)
			if(E.client)
				if (E.client.preferences.view_tickets)
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] sending tickets to [E.ckey]")
					E.showtickets()
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] done sending tickets to [E.ckey]")

				if (E.client.preferences.view_score)
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] sending crew credits to [E.ckey]")
					creds.Subscribe(E.client)
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] done crew credits to [E.ckey]")
				SPAWN_DBG(0) show_xp_summary(E.key, E)

		//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] done showing tickets/scores")


	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] finished spacebux updates")


	return 1

/////
/////SETTING UP THE GAME
/////

/////
/////MAIN PROCESS PART
/////
/*
/datum/controller/gameticker/proc/game_process()

	switch(mode.name)
		if("deathmatch","monkey","nuclear emergency","Corporate Restructuring","revolution","traitor",
		"wizard","extended")
			do
				if (!( shuttle_frozen ))
					if (src.timing == 1)
						src.timeleft -= 10
					else
						if (src.timing == -1.0)
							src.timeleft += 10
							if (src.timeleft >= shuttle_time_to_arrive)
								src.timeleft = null
								src.timing = 0
				if (prob(0.5))
					spawn_meteors()
				if (src.timeleft <= 0 && src.timing)
					src.timeup()
				sleep(1 SECOND)
			while(src.processing)
			return
//Standard extended process (incorporates most game modes).
//Put yours in here if you don't know where else to put it.
		if("AI malfunction")
			do
				check_win()
				ticker.AItime += 10
				sleep(1 SECOND)
				if (ticker.AItime == 6000)
					boutput(world, "<FONT size = 3><B>Cent. Com. Update</B> AI Malfunction Detected</FONT>")
					boutput(world, "<span class='alert'>It seems we have provided you with a malfunctioning AI. We're very sorry.</span>")
			while(src.processing)
			return
//malfunction process
		if("meteor")
			do
				if (!( shuttle_frozen ))
					if (src.timing == 1)
						src.timeleft -= 10
					else
						if (src.timing == -1.0)
							src.timeleft += 10
							if (src.timeleft >= shuttle_time_to_arrive)
								src.timeleft = null
								src.timing = 0
				for(var/i = 0; i < 10; i++)
					spawn_meteors()
				if (src.timeleft <= 0 && src.timing)
					src.timeup()
				sleep(1 SECOND)
			while(src.processing)
			return
//meteor mode!!! MORE METEORS!!!
		else
			return
//Anything else, like sandbox, return.
*/

/datum/controller/gameticker/proc/cleanup_landmarks()
	for(var/obj/landmark/start/S in landmarks)
		//Deleting Startpoints but we need the ai point to AI-ize people later
		if (S.name != "AI")
			S.dispose()
