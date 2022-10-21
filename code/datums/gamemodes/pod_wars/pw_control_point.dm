/datum/control_point
	var/name = "Capture Point"

	var/list/beacons = list()
	var/obj/control_point_computer/computer
	var/area/capture_area
	var/capture_value = 0				//values from -100 to 100. Positives denote NT, negatives denote SY.  	/////////UNUSED
	var/capture_rate = 1				//1 or 3 based on if a commander has entered their code.  				/////////UNUSED
	var/capturing_team					//0 if not moving, either uncaptured or at max capture. 1=NT, 2=SY  	/////////UNUSED
	var/owner_team = 0						//1=NT, 2=SY, not the team datum
	var/true_name						//backend name, var/name is the user readable name. Used for warp beacon searching, etc.
	var/last_cap_time					//Time it was last captured.
	var/crate_rewards_tier = 0			//var 0-3 none/low/med/high. Should correlate to holding the point for <5 min, <10 min, <15
	var/datum/game_mode/pod_wars/mode

	New(var/obj/control_point_computer/computer, var/area/capture_area, var/name, var/true_name, var/datum/game_mode/pod_wars/mode)
		..()
		src.computer = computer
		src.capture_area = capture_area
		src.name = name
		src.true_name = true_name
		src.mode = mode

		for(var/obj/warp_beacon/pod_wars/B in by_type[/obj/warp_beacon])
			if (B.control_point == true_name)
				src.beacons += B

	//deliver crate for appropriate tier.in front of this control point for the owner of the point
	proc/do_item_delivery()
		if (!src.computer)
			message_admins("SOMETHING WENT THE CONTROL POINTS!!!owner_team=[owner_team]|1 is NT, 2 is SY")
			logTheThing(LOG_DEBUG, null, "PW CONTROL POINT has null computer var.!!!owner_team=[owner_team]")
			return 0
		if (src.owner_team == 0)
			return 0

		var/turf/T = get_step(src.computer, src.computer.dir)		//tile in front of computer
		var/spawned_crate = FALSE

		//GAZE UPON MY WORKS AND DESPAIR!!!
		//Spawns a crate at the correct time at the correct tier.
		if (TIME > last_cap_time + 5 MINUTES && src.crate_rewards_tier == 0)	//Do anything special on capture here? idk, not yet at least...
			src.crate_rewards_tier ++
			return 0
		else if (TIME > last_cap_time + 10 MINUTES && src.crate_rewards_tier == 1)
			new/obj/storage/secure/crate/pod_wars_rewards(loc = T, team_num = src.owner_team, tier = src.crate_rewards_tier)
			src.crate_rewards_tier ++
			spawned_crate = TRUE

		else if (TIME > last_cap_time + 15 MINUTES && src.crate_rewards_tier == 2)
			new/obj/storage/secure/crate/pod_wars_rewards(loc = T, team_num = src.owner_team, tier = src.crate_rewards_tier)
			src.crate_rewards_tier ++
			spawned_crate = TRUE

		//ok, this is shit. To explain, if the tier is 3, then it'll be 15 minutes, if it's 4, it'll be 20 minutes, if it's 5, it'll be 25 minutes, etc...
		else if (TIME >= last_cap_time + (15 MINUTES + 5 MINUTES * (src.crate_rewards_tier-3) ) && src.crate_rewards_tier == 3)
			new/obj/storage/secure/crate/pod_wars_rewards(loc = T, team_num = src.owner_team, tier = src.crate_rewards_tier)
			src.crate_rewards_tier ++
			spawned_crate = TRUE

		//subtract 2 points from the enemy team every time a rewards crate is spawned on a point.
		if (spawned_crate == TRUE && istype(ticker.mode, /datum/game_mode/pod_wars))
			//get the team datum from its team number right when we allocate points.
			var/datum/game_mode/pod_wars/mode = ticker.mode

			//get the opposite team. lower their points
			var/datum/pod_wars_team/other_team
			switch(src.owner_team)
				if (TEAM_NANOTRASEN)
					other_team = mode.team_SY
				if (TEAM_SYNDICATE)
					other_team = mode.team_NT
			//error checking
			if (!other_team)
				message_admins("Can't grab the opposite team for control point [src.name]. It's owner_team value is:[src.owner_team]")
				logTheThing(LOG_DEBUG, null, "Can't grab the opposite team for control point [src.name]. It's owner_team value is:[src.owner_team]")
				return 0
			other_team.change_points(-5)

		return 1



	proc/capture(var/mob/user, var/team_num)
		src.owner_team = team_num
		src.last_cap_time = TIME
		//rewards tier goes to back down to 1 AFTER giving the enemy a crate. A little sort of catchup mechanic...
		if (src.crate_rewards_tier > 0)
			src.do_item_delivery()
			src.crate_rewards_tier = 1

		//update beacon teams
		for (var/obj/warp_beacon/pod_wars/B in beacons)
			B.current_owner = team_num

		var/datum/pod_wars_team/pw_team
		//This needs to give the actual team up to the control point datum, which in turn gives it to the game_mode datum to handle it
		//I don't think I do anything special with the team there yet, but I might want it for something eventually. Most things are just fine with the team_num.
		switch(team_num)
			if (TEAM_NANOTRASEN)
				pw_team = mode.team_NT
			if (TEAM_SYNDICATE)
				pw_team = mode.team_SY

		//update scoreboard
		mode.handle_control_point_change(src, user, pw_team)

		//log player_stats. Increment nearby player's capture point stat
		if (mode.stats_manager)
			mode.stats_manager.inc_control_point_caps(team_num, src.computer)


//I'll probably remove this all cause it's so shit, but in case I want to come back and finish it, I leave - kyle
	// proc/receive_prevent_capture(var/mob/user, var/user_team)
	// 	capturing_team = 0
	// 	return

	// proc/capture_start(var/mob/user, var/user_team)
	// 	if (owner_team == user_team)
	// 		boutput_
	// 	if (capturing_team == user_team)
	// 		capture_rate = 1
	// 		//is a commander, then change capture rate to be higher
	// 		if (istype(ticker.mode, /datum/game_mode/pod_wars))
	// 			var/datum/game_mode/pod_wars/mode = ticker.mode
	// 			if (user.mind == mode.team_NT.commander)
	// 				capture_rate = 3
	// 			else if (user.mind == mode.team_SY.commander)
	// 				capture_rate = 3


	// proc/process()

	// 	//clamp values, set capturing team to 0
	// 	if (capture_value >= 100)
	// 		capture_value = 100
	// 		capturing_team = 0
	// 		computer.update_from_manager(TEAM_NANOTRASEN, capturing_team)

	// 	else if (capture_value <= -100)
	// 		capture_value = -100
	// 		capturing_team = 0
	// 		computer.update_from_manager(TEAM_SYNDICATE, capturing_team)

	// 	if (capturing_team == TEAM_NANOTRASEN)
	// 		capture_value += capture_rate
	// 	else if (capturing_team == TEAM_SYNDICATE)
	// 		capture_value -= capture_rate
	// 	else
	// 		return

