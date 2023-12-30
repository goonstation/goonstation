/datum/controller/process/gang_tag_vision
	setup()
		name = "Gang_Tags"
		schedule_interval = GANG_TAG_SCAN_RATE

	doWork()
		for_by_tcl(tag, /obj/decal/gangtag)
			tag.find_players()



/datum/controller/process/gang_tag_score
	setup()
		name = "Gang_Tags_Score"
		schedule_interval = GANG_TAG_SCORE_INTERVAL

	doWork()
		var/topHeat = 0
		// calculate all heats
		for_by_tcl(I, /obj/decal/gangtag)
			topHeat = max(I.calculate_heat(), topHeat)

		for_by_tcl(I, /obj/decal/gangtag)
			if (!I || I.disposed || I.qdeled)
				continue
			I.apply_score(topHeat)



/datum/controller/process/gang_spray_regen
	setup()
		name = "Gang_Tags_Spraypaint_Regen"
		schedule_interval = GANG_SPRAYPAINT_REGEN
	doWork()
		if (istype(ticker.mode, /datum/game_mode/gang))
			var/datum/game_mode/gang/gamemode = ticker.mode
			broadcast_to_all_gangs("Each gang has [GANG_SPRAYPAINT_REGEN_QUANTITY > 1 ? "extra spray cans" : "an extra spray can" ] available from their locker.")
			for(var/datum/gang/gang in gamemode.gangs)
				gang.spray_paint_remaining += GANG_SPRAYPAINT_REGEN_QUANTITY


/datum/controller/process/gang_launder_money
	setup()
		name = "Gang_Money_laundering"
		schedule_interval = GANG_LAUNDER_DELAY
	doWork()
		var/datum/game_mode/gang/gamemode = ticker.mode
		for(var/datum/gang/gang in gamemode.gangs)
			var/obj/ganglocker/locker = gang.locker
			if (!locker)
				return
			if (locker.stored_cash < 1)
				locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
				locker.UpdateIcon()
				return

			var/launder_rate = GANG_LAUNDER_RATE
			if (locker.superlaunder_stacks > 0)
				locker.superlaunder_stacks -= 1
				launder_rate = GANG_LAUNDER_RATE * 1.5

			var/amount = round(min(locker.stored_cash, launder_rate))
			var/points = round(amount/CASH_DIVISOR) // only launder full points
			if (points < 1)
				locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
				locker.UpdateIcon()
				return

			if (locker.superlaunder_stacks)
				locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_superlaunder")
			else
				locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_launder")
			locker.UpdateIcon()
			locker.stored_cash -= (points*CASH_DIVISOR)
			gang.score_cash += points
			gang.add_points(points)


/datum/controller/process/gang_crate_drop
	var/list/potential_hot_zones = null
	var/crate_spawn_repeats = 0
	setup()
		name = "Gang_Crate_Drops"
		potential_hot_zones = list()
		schedule_interval = GANG_CRATE_DROP_FREQUENCY
		for(var/area/A as area in world)
			if(A.z != 1 || A.teleport_blocked || istype(A, /area/supply) || istype(A, /area/shuttle/) || A.name == "Space" || A.name == "Ocean")
				continue
			potential_hot_zones += A
	doWork()
		if (!istype(ticker.mode, /datum/game_mode/gang))
			src.disable()
			return
		crate_spawn_repeats++
		if (crate_spawn_repeats == 1)
			return //do nothing on our first run
		var/turfList[0]
		var/valid = 0
		var/attempts = 0
		var/area/drop_zone

		while (attempts <= 3 && !length(turfList))
			attempts++
			drop_zone = pick(potential_hot_zones)
			for (var/turf/simulated/floor/T in drop_zone.contents)
				if (!T.density)
					valid = 1
					for (var/obj/O in T.contents)
						if (O.density)
							valid=0
							break
					if (valid == 1)
						turfList.Add(T)
			if (!length(turfList))
				logTheThing(LOG_DEBUG, null, "Couldn't find a valid location to drop a weapons crate inside [drop_zone.name].")
		if (!length(turfList))
			message_admins("All attempts to find a valid location to spawn a weapons crate failed!")
			return
		new/obj/storage/crate/gang_crate/guns_and_gear(pick(turfList))
		broadcast_to_all_gangs("We've dropped off weapons & ammunition at the [drop_zone.name]! It's anchored in place for 5 minutes, so get fortifying!")


		SPAWN(GANG_CRATE_LOCK_TIME -1 MINUTE)
			if(drop_zone != null)
				broadcast_to_all_gangs("The weapons crate at the [drop_zone.name] can be moved in 1 minute!")
			sleep(1 MINUTE)
			if(drop_zone != null)
				broadcast_to_all_gangs("The weapons crate at the [drop_zone.name] is free! Drag it to your locker.")

/datum/controller/process/gang_duffle_drop
	var/repeats = 1
	var/duffle_spawn_repeats = 0
	setup()
		name = "Gang_Duffle_Drops"
		schedule_interval = GANG_LOOT_DROP_FREQUENCY
		src.repeats = GANG_LOOT_DROP_VOLUME_PER_GANG
	doWork()
		if (!istype(ticker.mode, /datum/game_mode/gang))
			src.disable()
			return
		duffle_spawn_repeats++
		if (duffle_spawn_repeats == 1)
			return //do nothing on our first run
		var/datum/game_mode/gang/gamemode = ticker.mode
		var/list/civiliansAlreadyPinged = list()// try not to have the same person picked twice
		for(var/datum/gang/targetGang as anything in gamemode.gangs) //create loot bags for this gang (so they get pinged)
			var/list/datum/mind/gangChosenCivvies = list() //which civilians have been picked for this gang
			for(var/i = 1 to repeats)
				var/datum/mind/civvie = targetGang.get_random_civvie(civiliansAlreadyPinged)
				civiliansAlreadyPinged += civvie
				if (!(civvie in gangChosenCivvies))
					gangChosenCivvies += civvie
				targetGang.target_loot_spawn(civvie)

			var/broadcast_string = "Our associates have hidden [repeats] bag[s_es(repeats)] of weapons & supplies on board. The location[s_es(repeats)] have been tipped off to: "
			if (length(gangChosenCivvies) > 1)
				for (var/name=1 to length(gangChosenCivvies)-1)
					broadcast_string += "[gangChosenCivvies[name].current.real_name] the [gangChosenCivvies[name].assigned_role]."
				broadcast_string += "and [gangChosenCivvies[length(gangChosenCivvies)].current.real_name] the [gangChosenCivvies[length(gangChosenCivvies)].assigned_role]."
			else
				broadcast_string += "[gangChosenCivvies[1].current.real_name] the [gangChosenCivvies[1].assigned_role],"

			targetGang.broadcast_to_gang(broadcast_string)


