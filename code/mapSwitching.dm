/*
Map switcher thing!
Relies a lot on the map_settings stuff in code/map.dm
Datum new() is called near the end of world/New()
*/

var/global/datum/mapSwitchHandler/mapSwitcher

/datum/mapSwitchHandler
	var/active = 0 //set to 1 if the datum initializes correctly
	var/current = null //the human-readable name of the current map
	var/next = null //the human-readable name of the next map, if set

	//player vote stuff
	var/votingAllowed = 1 //is map voting allowed?
	var/playersVoting = 0 //are players currently voting on the map?
	var/voteStartedAt = 0 //timestamp when the map vote was started
	var/autoVoteDelay = 30 SECONDS //how long should we wait after round start to trigger to automatic map vote?
	var/autoVoteDuration = 7 MINUTES //how long (in byond deciseconds) the automatic map vote should last (1200 = 2 mins)
	var/voteCurrentDuration = 0 //how long is the current vote set to last?
	var/voteChosenMap = "" //the map that the players voted to switch to
	var/nextMapIsVotedFor = 0 //is the next map a result of player voting?
	var/voteIndex = 0 //a count of votes
	var/list/playerPickable = list() //list of maps players are allowed to pick
	var/list/passiveVotes = list() //list of passive map votes
	var/list/previousVotes = list() //a list of how people voted for every vote


	New()
		..()
		src.setupPickableList()


	proc/setupPickableList()
		//map_setting set by code/map.dm
		src.playerPickable.len = 0
		for (var/map in mapNames)
			if (mapNames[map]["id"] == map_setting)
				src.active = 1
				src.setCurrentMap(map)

			if (mapNames[map]["playerPickable"])
				if (mapNames[map]["MinPlayersAllowed"])
					if (total_clients() < mapNames[map]["MinPlayersAllowed"])
						continue
				#ifndef UPSCALED_MAP
				if (mapNames[map]["MaxPlayersAllowed"])
					if (total_clients() > mapNames[map]["MaxPlayersAllowed"])
						continue
				#endif

				src.playerPickable[map] += mapNames[map]

		if (!src.active)
			logTheThing(LOG_DEBUG, null, "<b>Map Switcher:</b> Failed to find an entry in mapNames. map_setting: [map_setting]")
			return


	proc/setCurrentMap(map)
		if (!src.active || !map)
			return

		src.current = map


	proc/setNextMap(trigger, mapName = "", mapID = "", votes = 0)
		if (!mapName && !mapID)
			throw EXCEPTION("No map identifier given")

		if (mapName && mapID)
			throw EXCEPTION("Too many map identifiers given")

		if (!src.active)
			throw EXCEPTION("Map switcher is currently inactive")

		if (mapName)
			if (!mapNames[mapName])
				throw EXCEPTION("Incorrect map name given: [mapName]")

			mapID = mapNames[mapName]["id"]
		else
			mapName = getMapNameFromID(mapID)

		var/datum/apiModel/MapSwitch/mapSwitchRes
		try
			var/datum/apiRoute/mapswitch/mapSwitch = new
			mapSwitch.buildBody(
				trigger == "Player Vote" ? null : trigger, // trigger should be a ckey if not a vote
				roundId,
				null,
				mapID,
				votes
			)
			mapSwitchRes = apiHandler.queryAPI(mapSwitch)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			throw EXCEPTION(error.message)

		if (text2num(mapSwitchRes.status) != 200)
			throw EXCEPTION("Build server failed to switch map. Expected HTTP status code 200, received code [isnull(mapSwitchRes.status) ? "null" : mapSwitchRes.status] instead")

		//make a note if this is a player voted map
		src.nextMapIsVotedFor = trigger == "Player Vote" ? 1 : 0

		//set next only if we're not re-compiling the current map for whatever reason
		if (src.current != mapName)
			src.next = mapName
		else
			src.next = null


	//start a vote to change the map
	proc/startMapVote(duration = 0)
		if (!src.votingAllowed)
			throw EXCEPTION("Map votes are currently disabled")

		if (src.playersVoting)
			throw EXCEPTION("A map vote is currently underway")

		src.setupPickableList()

		src.voteChosenMap = ""
		src.playersVoting = 1
		src.voteStartedAt = TIME
		src.voteCurrentDuration = duration
		src.voteIndex++

		for (var/client/C in clients)
			C.verbs += /client/proc/mapVote
			if(C?.preferences && length(C.preferences.preferred_map) && !istype(C.mob,/mob/new_player) && (C.preferences.preferred_map in playerPickable))
				src.passiveVotes[C.ckey] = C.preferences.preferred_map

		//announce vote
		var/msg = "<br><span class='bold notice'>"
		msg += "A vote for next round's map has started! Click here: [mapVoteLinkStat.chat_link()] or on the 'Map Vote' button in your status window."

		if (duration)
			msg += " It will end in [duration / 10] seconds."
		msg += "</span><br><br>"
		boutput(world, msg)

		//if the vote was triggered with a duration, wait that long and end it
		if (duration)
			var/currentVoteIndex = src.voteIndex
			SPAWN(duration)
				//it's possible that a vote was started, cancelled, and then another started again. we don't want this spawn to prematurely end the new one
				if (currentVoteIndex != src.voteIndex)
					return

				//it's possible the vote was cancelled
				if (src.playersVoting)
					src.endMapVote()


	//voting is DONE
	proc/endMapVote()
		if (!src.playersVoting)
			throw EXCEPTION("There is no map vote underway")

		src.playersVoting = 0

		for (var/client/C in clients)
			C.verbs -= /client/proc/mapVote

		//count votes
		var/list/reportData = list()
		var/list/votes = list()

		var/list/results = map_vote_holder.count_votes()
		votes = results["tally"]
		reportData = results["report"]

		//save this vote data
		src.previousVotes["vote[src.voteIndex]"] = reportData
		src.previousVotes["vote_tally[src.voteIndex]"] = votes

		logTheThing(LOG_DEBUG, null, "<b>Map Vote Debug:</b> Vote data: [json_encode(votes)]. Report data: [json_encode(reportData)]")

		//reset votes holders
		src.passiveVotes = new()
		map_vote_holder.clear_votes()
		//no one voted :(
		if (length(votes) == 0)
			return

		//determine winner
		var/highestVotes = 0
		var/list/tiedMaps = list()
		for (var/map in votes)
			var/mapVotes = votes[map]
			//note the map with the highest votes
			if (mapVotes > highestVotes)
				highestVotes = mapVotes
				src.voteChosenMap = map
				// reset the tied list
				tiedMaps = list()

			//a tie is detected! make a note of which maps are tied
			else if (mapVotes == highestVotes)
				if (length(tiedMaps) == 0)
					//retroactively note that the previously highest voted map is now tied
					tiedMaps += src.voteChosenMap
				tiedMaps += map

		//handle ties
		if (tiedMaps.len)
			logTheThing(LOG_DEBUG, null, "Map tie detected. Choices: [json_encode(tiedMaps)]")
			src.voteChosenMap = pick(tiedMaps)

		//trigger map switch using voteChosenMap
		if (src.voteChosenMap == src.current)
			//dont trigger a recompile of the current map for no reason
			src.nextMapIsVotedFor = 1
		else
			try
				src.setNextMap("Player Vote", mapName = src.voteChosenMap, votes = highestVotes)
			catch (var/exception/e)
				logTheThing(LOG_ADMIN, null, "Failed to set map <b>[src.voteChosenMap]</b> from map vote: [e.name]")
				logTheThing(LOG_DIARY, null, "Failed to set map <b>[src.voteChosenMap]</b> from map vote: [e.name]", "debug")
				return

		//announce winner
		var/msg = "<br><span style='font-size: 1.25em;' class='internal'>"
		msg += "The vote for next map has ended. The winning choice is '[src.voteChosenMap]'.<a href='?src=\ref[src];type=view_mapvote_report_simple;vote=[src.voteIndex]'>(View Tally)</a>"
		if (src.voteChosenMap == src.current)
			msg += " (No change)"
		msg += "</span><br><br>"
		boutput(world, msg)

		//log this
		logTheThing(LOG_ADMIN, null, "The players voted for <b>[src.voteChosenMap]</b> as the next map.")
		logTheThing(LOG_DIARY, null, "The players voted for [src.voteChosenMap] as the next map.", "admin")
		message_admins("The players voted for <b>[src.voteChosenMap]</b> as the next map. <a href='?src=\ref[src];type=view_mapvote_report;vote=[src.voteIndex]'>(View Voters)</a>")

	//rudely cancel the vote without counting votes/doing anything
	proc/cancelMapVote()
		src.playersVoting = 0

		for (var/client/C in clients)
			C.verbs -= /client/proc/mapVote

	// Standardized way to ask a user for a map
	proc/clientSelectMap(client/C,var/pickable)
		return tgui_input_list(C, "Select a map. Currently on: [src.current]", "Switch Map", pickable ? src.playerPickable : mapNames, src.next || src.current)

	//show a html report of who voted for what in any given map vote
	proc/composeVoteReport(vote)
		if (!vote)
			return

		vote = text2num(vote)
		if (vote > src.voteIndex || !("vote[vote]" in src.previousVotes))
			throw EXCEPTION("That vote index does not exist")

		var/list/reportDataDetailed = src.previousVotes["vote[vote]"]
		var/datum/MapVoteReport/mvr = new(reportDataDetailed = reportDataDetailed)
		mvr.ui_interact(usr)

	//show a html report of the weighted votes per choice
	proc/composeVoteReportSimple(vote)
		if (!vote)
			return

		vote = text2num(vote)
		if (vote > src.voteIndex || !("vote_tally[vote]" in src.previousVotes))
			throw EXCEPTION("That vote index does not exist")

		var/list/reportDataSimple = src.previousVotes["vote_tally[vote]"]
		var/datum/MapVoteReport/mvr = new(reportDataSimple = reportDataSimple)
		mvr.ui_interact(usr)

	Topic(href, href_list)
		if (..())
			return

		if (href_list["type"])
			if (href_list["type"] == "view_mapvote_report")
				var/vote = href_list["vote"]
				src.composeVoteReport(vote)
			if (href_list["type"] == "view_mapvote_report_simple")
				var/vote = href_list["vote"]
				src.composeVoteReportSimple(vote)

	proc/get_player_pickable_map_list()
		. = new/list()
		for (var/map in src.playerPickable)
			. += list(list(
				name = map,
				thumbnail = "[config.goonhub_url]/storage/maps/[lowertext(src.playerPickable[map]["id"])]/thumb.png"
			))
/proc/isMapSwitcherBusted()
	if (!mapSwitcher || !mapSwitcher.active)
		return "The map switcher is apparently broken right now. Yell at Wire I guess"

	if (!config.allow_map_switching)
		return "Map switching is disabled on this server, sorry."

	return 0


/client/proc/mapVote()
	set name = "Map Vote"
	set desc = "Vote on the map for next round"
	set category = "Commands"
	set popup_menu = 0

	map_vote_holder.show_window(usr.client)

/datum/map_vote_holder
	var/list/client/vote_map = list() // a map of ckeys to (a map of map_names to the ckey's current vote)
	var/voters = 0

	disposing()
		clear_votes()
		..()

	proc/clear_votes()
		src.vote_map.len = 0

	proc/count_votes()
		var/list/results = list()
		var/list/map_vote_count = list()
		var/list/map_vote_report = list()
		for(var/key in vote_map)
			mapSwitcher.passiveVotes.Remove(key)
			var/client_vote_map = vote_map[key]
			for(var/map_name in client_vote_map)
				if(client_vote_map[map_name])
					if(map_name in map_vote_count)
						map_vote_count[map_name] += MAPVOTE_ACTIVE_WEIGHT
					else
						map_vote_count[map_name] = MAPVOTE_ACTIVE_WEIGHT
					if(map_name in map_vote_report)
						map_vote_report[map_name] += key
					else
						map_vote_report[map_name] = list(key)

		var/list/passive_votes = mapSwitcher.passiveVotes
		for(var/key in passive_votes)
			var/map_name = passive_votes[key]
			if(map_name in map_vote_count)
				map_vote_count[map_name] += MAPVOTE_PASSIVE_WEIGHT
			else
				map_vote_count[map_name] = MAPVOTE_PASSIVE_WEIGHT
			if(map_name in map_vote_report)
				map_vote_report[map_name] += key
			else
				map_vote_report[map_name] = list(key)

		results["tally"] = map_vote_count
		results["report"] = map_vote_report
		return results

	proc/setup_client_vote_map(var/client/C)
		if(!C.ckey)
			return
		var/key = C.ckey
		if(key in vote_map)
			return
		var/list/maps = list()
		for(var/map in mapSwitcher.playerPickable)
			maps[map] = 0
		src.vote_map[key] = maps
		voters++

	proc/get_client_votes(var/client/C)
		if(!C.ckey)
			return
		var/key = C.ckey
		if(!(key in vote_map))
			return
		var/list/maps = list()
		var/list/client_vote_map = vote_map[key]
		for(var/map in client_vote_map)
			if(client_vote_map[map] > 0)
				maps += map
		return maps

	proc/toggle_vote(map_name, client/C)
		if(!(C.ckey in vote_map))
			setup_client_vote_map(C)
		var/list/client_vote_map = vote_map[C.ckey]
		if(map_name in client_vote_map)
			client_vote_map[map_name] = !client_vote_map[map_name]

	proc/all_yes(client/C)
		if(!(C.ckey in vote_map))
			setup_client_vote_map(C)
		var/list/client_vote_map = vote_map[C.ckey]
		for(var/map_name in client_vote_map)
			client_vote_map[map_name] = 1

	proc/all_no(client/C)
		if(!(C.ckey in vote_map))
			setup_client_vote_map(C)
		var/list/client_vote_map = vote_map[C.ckey]
		for(var/map_name in client_vote_map)
			client_vote_map[map_name] = 0

	proc/special_vote(var/client/C,var/map_name)
		if(!(C.ckey in vote_map))
			setup_client_vote_map(C)
		var/list/client_vote_map = vote_map[C.ckey]
		client_vote_map[map_name] = 1

	proc/voting_box(var/obj/voting_box/V,var/map_name)
		var/vref = "\ref[V]"
		vote_map[vref] = list(map_name)
		vote_map[vref][map_name] = 1

	ui_state(mob/user)
		return tgui_always_state.can_use_topic(src, user)

	ui_status(mob/user, datum/ui_state/state)
		return tgui_always_state.can_use_topic(src, user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "MapVote", "Map Vote")
			ui.open()

	ui_static_data()
		. = list(
			"mapList" = mapSwitcher.get_player_pickable_map_list()
		)

	ui_data(mob/user)
		if(!(user.client.ckey in vote_map))
			setup_client_vote_map(user.client)

		. = list(
			"playersVoting" = mapSwitcher.playersVoting,
			"clientVoteMap" = vote_map[user.client.ckey]
		)

	proc/show_window(client/C)
		ui_interact(C.mob)

	ui_act(action, list/params)
		switch (action)
			if("toggle_vote")
				toggle_vote(params["map_name"], usr)
			if("all_yes")
				all_yes(usr)
			if("all_no")
				all_no(usr)
		. = TRUE

/obj/mapVoteLink
	name = "<span style='color: green; text-decoration: underline;'>Map Vote</span>"
	flags = NOSPLASH

	Click()
		var/client/C = usr.client
		if (!C) return
		var/mob/living/M = C.mob
		var/chosenMap = null
		if(istype(M))
			var/obj/item/I = M.equipped()
			if(istype(I, /obj/item/reagent_containers) && I:reagents:has_reagent("space_fungus"))
				chosenMap = "Mushroom"
			if(istype(I, /obj/item/reagent_containers) && (I:reagents:has_reagent("reversium") || I:reagents:has_reagent("fliptonium")))
				chosenMap = "1 pamgoC"
			//if(istype(I, /obj/item/reagent_containers) && I:reagents:has_reagent("ldmatter"))
				//chosenMap = "Density"
			if(istype(I, /obj/item/reagent_containers/food/snacks/donut))
				chosenMap = "Donut 2"
			//if(istype(I, /obj/item/grab))
				//chosenMap = "Wrestlemap"

		if (mapSwitcher.playersVoting)
			if(chosenMap)
				map_vote_holder.special_vote(C,chosenMap)
				boutput(C.mob, SPAN_SUCCESS("Map vote successful???"))
			else
				map_vote_holder.show_window(C)


	examine()
		return list()

	proc/chat_link()
		return "<a href='?src=\ref[src]'>[src]</a>"

	Topic(href, href_list)
		. = ..()
		Click()

var/global/obj/mapVoteLink/mapVoteLinkStat = new /obj/mapVoteLink
var/global/datum/map_vote_holder/map_vote_holder = new()

/datum/MapVoteReport
	var/list/mapList
	var/winner
	var/isDetailed = FALSE

	New(list/reportDataSimple, list/reportDataDetailed)
		src.mapList = mapSwitcher.get_player_pickable_map_list()

		if (reportDataSimple)
			for (var/map in src.mapList)
				map["count"] = reportDataSimple[map["name"]] || 0

		if (reportDataDetailed)
			isDetailed = TRUE
			for (var/map in src.mapList)
				map["count"] = length(reportDataDetailed[map["name"]]) || 0
				map["voters"] = reportDataDetailed[map["name"]]

		sortList(src.mapList, /proc/compare_map_vote_count)

		src.winner = mapSwitcher.voteChosenMap

		..()

	ui_state(mob/user)
		return tgui_always_state.can_use_topic(src, user)

	ui_status(mob/user, datum/ui_state/state)
		return tgui_always_state.can_use_topic(src, user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "MapVoteReport", "Vote Report")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"mapList" = mapList,
			"winner" = winner,
			"isDetailed" = isDetailed)

/proc/compare_map_vote_count(list/a, list/b)
	. = b["count"] - a["count"]
