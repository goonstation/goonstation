//MBC : saving some cpu by doing these checks once per Stat() cycle and caching the results for all mobs
// All 'global' printouts should be set in mob_stat_thinker/update()
// All the player specific info should be handled directly in mob/stat().
//I know its really ugly ok i'm sorry

#define saveStat(key, value) stats[key] = value

/datum/mob_stat_thinker
	var/last_update = 0
	var/update_interval = 11
	var/is_construction_mode = 0

	var/list/stats = list()
	var/list/statNames = list("Map:","Next Map:","Map Vote Link:","Map Vote Time:","Map Vote Spacer","Vote Link:","Vote Time:","Vote Spacer","Game Mode:","Time To Start:","Server Load:","Shift Time Spacer","Shift Time:","Shuttle")
	//above : ORDER IS IMPORANT

	New()
		//-1 indicates a blank space to be inserted (These are set in update() but for ease of reading I have labeled the spacers here)
		//this shit is kind of messy to read but it is Quicker than repopulating the list each update()
		stats["Map:"] = 0
		stats["Next Map:"] = 0
		stats["Map Vote Link:"] = 0
		stats["Map Vote Time:"] = 0
		stats["Map Vote Spacer"] = -1
		stats["Vote Link:"] = 0
		stats["Vote Time:"] = 0
		stats["Vote Spacer"] = -1
		stats["Game Mode:"] = 0
		stats["Time To Start:"] = 0
		stats["Server Load:"] = 0
		stats["Shift Time Spacer"] = -1
		stats["Shift Time:"] = 0
		stats["Shuttle:"] = 0

	proc/update()
		last_update = world.time

		for (var/S in stats)
			S = 0

		if (mapSwitcher)
			stats["Map Vote Spacer"] = -1
			if (mapSwitcher.current)
				var/currentMap = mapSwitcher.current

				if (mapSwitcher.locked && !mapSwitcher.next && isadmin(src))
					currentMap += " (Compiling)"

				saveStat("Map:", currentMap)

			stats["Next Map:"] = 0
			if (mapSwitcher.next)
				var/nextMap = mapSwitcher.next

				//if the players voted for the next map, show them compile status, otherwise limit that info to admins
				if (mapSwitcher.locked && (mapSwitcher.nextMapIsVotedFor || isadmin(src)))
					nextMap += " (Compiling)"

				if (mapSwitcher.nextMapIsVotedFor && isadmin(src))
					nextMap += " (Player Voted)"

				if (mapSwitcher.queuedVoteCompile && mapSwitcher.voteChosenMap)
					nextMap += " (Queued: [mapSwitcher.voteChosenMap])"

				saveStat("Next Map:", nextMap)

			if (mapSwitcher.playersVoting)
				saveStat("Map Vote Link:",mapVoteLinkStat)

				if (mapSwitcher.voteCurrentDuration)
					saveStat("Map Vote Time:", "([round(((mapSwitcher.voteStartedAt + mapSwitcher.voteCurrentDuration + PREGAME_LOBBY_TICKS) - world.time) / 10)] seconds remaining, [map_vote_holder.voters] vote[map_vote_holder.voters != 1 ? "s" : ""])")
			else
				stats["Map Vote Link:"] = 0
				stats["Map Vote Time:"] = 0

		if (!isnull(vote_manager) && vote_manager.active_vote)
			saveStat("Vote Link:",newVoteLinkStat)
			saveStat("Vote Time:", "([round(((vote_manager.active_vote.vote_started + vote_manager.active_vote.vote_length) - world.time) / 10)] seconds remaining, [vote_manager.active_vote.voted_ckey.len] vote[vote_manager.active_vote.voted_ckey.len != 1 ? "s" : ""])")
			stats["Vote Spacer"] = -1
		else
			stats["Vote Link:"] = 0
			stats["Vote Time:"] = 0
			stats["Vote Spacer"] = 0

		if (ticker)
			saveStat("Game Mode:",ticker.hide_mode ? "secret" : "[master_mode]")

			if (current_state <= GAME_STATE_PREGAME)
				var/timeLeftColor
				switch (ticker.pregame_timeleft)
					if (100 to 999)
						timeLeftColor = "green"
					if (50 to 100)
						timeLeftColor = "#ffb400"
					if (0 to 50)
						timeLeftColor = "red"
				saveStat("Time To Start:", "<span style='color: [timeLeftColor];'>[ticker.pregame_timeleft]</span>")

			else if (ticker.round_elapsed_ticks)
				stats["Time To Start:"] = 0
				var/shiftTime = round(ticker.round_elapsed_ticks / 600)
				saveStat("Shift Time:", "[shiftTime] minute[shiftTime == 1 ? "" : "s"]")

				//MBC : nah we don't run construction anyway
				//if (ticker.mode && istype(ticker.mode, /datum/game_mode/construction))
				//	is_construction_mode = 1


		/*
		var/ticklagtext = "Light"
		switch (world.tick_lag)
			if (0.5 to 0.7)
				ticklagtext = "Medium"
			if (0.71 to 0.9)
				ticklagtext = "Heavy"
			if (0.9 to 2)
				ticklagtext = "Insane"
		*/
		saveStat("Server Load:", world.cpu < 90 ? "No" : "Yes") //Yes very useful a++
		//saveStat("Server Load:", ticklagtext)   //Yes, very useful! A+!

		if (emergency_shuttle && emergency_shuttle.online && emergency_shuttle.location < SHUTTLE_LOC_RETURNED)
			stats["Shift Time Spacer"] = -1
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				var/locstr = ""
				switch( emergency_shuttle.location )
					if( 1 )
						locstr = "ETD"
					if( 1.5 )
						locstr = "ETA to Centcom"
					else
						locstr = "ETA"

				saveStat("Shuttle", "[locstr]: [(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")
		else
			stats["Shuttle"] = 0

var/global/datum/mob_stat_thinker/mobStat = new

/mob/Stat()
	..()
	if (src.abilityHolder)
		abilityHolder.StatAbilities()

	statpanel("Status")
	if (client.statpanel == "Status")
		if (world.time - mobStat.last_update > mobStat.update_interval)
			mobStat.update()

		/*

		if (mobStat.stats["Map Vote Time:"])
			var/vote = mapSwitcher.playerVotes[src.client.ckey]
			if (vote)
				stat ("Your vote: ","[vote]")

		*/

		//MBC : Copy paste for life : This is the same loop as below basically. (I don't want to check admin holder each and every loop iteration for non-admins! I'd rather the code look like shit.

		//THIS ONE FOR ADMINS
		if (src.client.holder)
			//todo : figure out a good way to do less checks within this loop
			for(var/i = 1, i <= mobStat.statNames.len, i++)
				if (mobStat.stats[mobStat.statNames[i]] == 0)
					continue
				else if (mobStat.stats[mobStat.statNames[i]] == -1)
					stat(null, " ")
					continue

				//BLUEGH ADMIN SHIT
				if (mobStat.statNames[i] == "Server Load:")
					stat("Server Load:", "[world.cpu]")
					#if TIME_DILATION_ENABLED == 1
					stat("Variable Ticklag:", "[world.tick_lag]")
					#endif

					if (!istype(src.loc, /turf) && !isnull(loc))
						stat("Co-ordinates:", "([loc.x], [loc.y], [loc.z])")
					else
						stat("Co-ordinates:", "([x], [y], [z])")
					stat("Runtimes:", runtime_count)
					continue
				if (mobStat.statNames[i] == "Game Mode:")
					stat("Game Mode:", (ticker && ticker.hide_mode) ? "[master_mode] **HIDDEN**" : "[master_mode]")
					continue
				//ADMIN SHIT END

				stat(mobStat.statNames[i],mobStat.stats[mobStat.statNames[i]])

		//THIS ONE FOR PLAYERS
		else
			for(var/i = 1, i <= mobStat.statNames.len, i++)
				if (mobStat.stats[mobStat.statNames[i]] == 0)
					continue
				else if (mobStat.stats[mobStat.statNames[i]] == -1)
					stat(null, " ")
					continue

				stat(mobStat.statNames[i],mobStat.stats[mobStat.statNames[i]])

		//screw this we don't even run construction mode
		/*
		if (mobStat.is_construction_mode)
			stat(null, " ")
			var/datum/game_mode/construction/C = ticker.mode
			stat("Construction time left:", C.human_time_left)
			var/datum/construction_controller/E = C.events
			if (E.event_delay)
				if (E.current_event)
					stat("Event in progress:", E.current_event.name)
				else
					stat("Event cycle starts in:", dstohms(E.event_delay - ticker.round_elapsed_ticks))
			else if (E.choose_at)
				stat("Next event type:", E.next_event_type)
				stat("Estimated event ETA:", dstohms(E.next_event_at - ticker.round_elapsed_ticks))
			else if (E.next_event_at)
				stat("Next event type:", E.next_event_type)
				stat("Event ETA:", dstohms(E.next_event_at - ticker.round_elapsed_ticks))
			stat(null, " ")
		*/

		#ifdef XMAS
		stat("Spacemas Cheer:", "[christmas_cheer]%")
		#endif

		stat(null, " ")

	if (abilityHolder)
		abilityHolder.Stat()

	if (is_near_gauntlet())
		gauntlet_controller.Stat()

	if (is_near_colosseum())
		colosseum_controller.Stat()

#undef saveStat
