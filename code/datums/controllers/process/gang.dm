/datum/controller/process/gang_tag_vision
	setup()
		name = "Gang_Tags"
		schedule_interval = GANG_TAG_SCAN_RATE

	doWork()
		for_by_tcl(tag, /obj/decal/gangtag)
			if (tag.active)
				tag.find_players()



/datum/controller/process/gang_tag_score
	setup()
		name = "Gang_Tags_Score"
		schedule_interval = GANG_TAG_SCORE_INTERVAL

	doWork()
		var/topHeat = 0
		// calculate all heats
		for_by_tcl(I, /obj/decal/gangtag)
			if (I.active)
				topHeat = max(I.calculate_heat(), topHeat)

		for_by_tcl(I, /obj/decal/gangtag)
			if (I.active)
				I.apply_score(topHeat)



/datum/controller/process/gang_spray_regen
	setup()
		name = "Gang_Tags_Spraypaint_Regen"
		schedule_interval = GANG_SPRAYPAINT_REGEN
	doWork()
		if (istype(ticker.mode, /datum/game_mode/gang))
			var/datum/game_mode/gang/gamemode = ticker.mode
			broadcast_to_all_gangs("Each gang has [GANG_SPRAYPAINT_REGEN_QUANTITY > 1 ? "extra spray cans" : "an extra spray can" ] available from their locker.")
			for(var/datum/gang/gang as anything in gamemode.gangs)
				gang.spray_paint_remaining += GANG_SPRAYPAINT_REGEN_QUANTITY


/datum/controller/process/gang_launder_money
	setup()
		name = "Gang_Money_laundering"
		schedule_interval = GANG_LAUNDER_DELAY
	doWork()
		for_by_tcl(locker, /obj/ganglocker)
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
			var/points = round(amount/GANG_CASH_DIVISOR) // only launder full points
			if (points < 1)
				locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
				locker.UpdateIcon()
				return

			if (locker.superlaunder_stacks)
				locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_superlaunder")
			else
				locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_launder")
			locker.UpdateIcon()
			locker.stored_cash -= (points*GANG_CASH_DIVISOR)
			locker.gang.score_cash += points
			locker.gang.add_points(points, location = get_turf(locker), showText = TRUE)


/datum/controller/process/gang_crate_drop
	var/list/potential_hot_zones[0]
	var/crate_spawn_repeats = 0
	name = "Gang_Crate_Drops"
	setup()
		schedule_interval = GANG_CRATE_INITIAL_DROP
		var/list/area/areas = get_accessible_station_areas()
		for(var/area_name in areas)
			if(istype(areas[area_name], /area/station/security) || areas[area_name].teleport_blocked || istype(areas[area_name], /area/station/turret_protected))
				continue
			potential_hot_zones += areas[area_name]
	doWork()
		if (!istype(ticker.mode, /datum/game_mode/gang))
			src.disable()
			return
		crate_spawn_repeats++
		if (crate_spawn_repeats == 1)
			return //do nothing on our first run
		else if (crate_spawn_repeats == 2)
			schedule_interval = GANG_CRATE_DROP_FREQUENCY
		var/turfList[0]
		var/attempts = 0
		var/area/drop_zone

		while (attempts <= 3 && !length(turfList))
			attempts++
			drop_zone = pick(potential_hot_zones)
			for (var/turf/simulated/floor/T in drop_zone.contents)
				if (!is_blocked_turf(T))
					turfList.Add(T)
			if (!length(turfList))
				logTheThing(LOG_DEBUG, null, "Couldn't find a valid location to drop a weapons crate inside [drop_zone.name].")
		if (!length(turfList))
			message_admins("All attempts to find a valid location to spawn a weapons crate failed!")
			return
		var/turf/location = pick(turfList)
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANG_OBJECTIVES)
		var/obj/effects/gang_crate_indicator/indicator = new(location)
		var/image/objective_image = image('icons/effects/gang_overlays.dmi', indicator, "cratedrop")
		objective_image.plane = PLANE_WALL
		objective_image.alpha = 180
		imgroup.add_image(objective_image)
		broadcast_to_all_gangs("<span style='font-size:24px'> We're dropping off weapons & ammunition at <b>\the [drop_zone.name]!</b> It'll arrive in [GANG_CRATE_DROP_TIME/(1 MINUTE)] minute[s_es(GANG_CRATE_DROP_TIME/(1 MINUTE))] so get fortifying!</span>")

		var/datum/game_mode/gang/gamemode = ticker.mode
		for(var/datum/gang/targetGang as anything in gamemode.gangs) //create loot bags for this gang (so they get pinged)
			var/datum/targetable/abil = targetGang.leader?.current?.getAbility(/datum/targetable/gang/set_gang_base/migrate)
			if (abil)
				abil.last_cast = world.time + GANG_CRATE_DROP_TIME + 5 MINUTES
				targetGang.leader.current.abilityHolder?.updateButtons()

		SPAWN(GANG_CRATE_DROP_TIME - 30 SECONDS)
			if(drop_zone != null)
				broadcast_to_all_gangs("The weapons crate at the [drop_zone.name] will arrive in 30 seconds!")
				logTheThing(LOG_GAMEMODE, src, "The crate in [drop_zone.name] will arrive in 30 seconds. Location: [location.x],[location.y].")
			sleep(30 SECONDS)
			if(drop_zone != null)
				imgroup.remove_image(objective_image)
				qdel(indicator)
				var/obj/storage/crate/gang_crate/guns_and_gear/crate = new(location)
				broadcast_to_all_gangs("The weapons crate at the [drop_zone.name] has arrived! Drag it to your locker.")
				logTheThing(LOG_GAMEMODE, crate, "The crate in [drop_zone.name] arrives on station. Location: [location.x],[location.y].")

/datum/controller/process/gang_duffle_objectives
	var/repeats = 1
	var/duffle_spawn_repeats = 0
	var/list/unvandalised_departments = list()
	setup()
		name = "Gang_Duffle_Objectives"
		schedule_interval = GANG_LOOT_INITIAL_DROP
		unvandalised_departments += /area/station/engine
		unvandalised_departments += /area/station/medical
		unvandalised_departments += /area/station/quartermaster
		unvandalised_departments += /area/station/janitor
		unvandalised_departments += /area/station/science
		unvandalised_departments += /area/station/crew_quarters

	doWork()
		if (!istype(ticker.mode, /datum/game_mode/gang))
			src.disable()
			return
		duffle_spawn_repeats++
		if (duffle_spawn_repeats == 1)
			return //do nothing on our first run
		else if (duffle_spawn_repeats == 2)
			schedule_interval = GANG_LOOT_DROP_FREQUENCY
		var/datum/game_mode/gang/gamemode = ticker.mode
		var/list/duffle_list = list()
		var/list/vandal_list = list()
		for(var/datum/gang/targetGang as anything in gamemode.gangs)
			if ((prob(30)) && length(unvandalised_departments))
				duffle_list[targetGang] = GANG_LOOT_DROP_VOLUME_PER_GANG-1
				vandal_list[targetGang] = pick(unvandalised_departments)
				unvandalised_departments -= vandal_list[targetGang]
			else
				duffle_list[targetGang] = GANG_LOOT_DROP_VOLUME_PER_GANG

		var/list/duffle_broadcasts = doDuffles(duffle_list)
		var/list/vandalism_broadcasts = doVandalism(vandal_list)

		for(var/datum/gang/targetGang as anything in gamemode.gangs)
			var/broadcast = "There are [GANG_LOOT_DROP_VOLUME_PER_GANG] bag[s_es(GANG_LOOT_DROP_VOLUME_PER_GANG)] of weapons & supplies ready for your gang to claim.<br>"
			broadcast += " - [duffle_broadcasts[targetGang]]"
			broadcast += "<br>"
			broadcast += " - [vandalism_broadcasts[targetGang]]"
			targetGang.broadcast_to_gang(broadcast)

	proc/doDuffles(gang_duffle_list)
		var/datum/game_mode/gang/gamemode = ticker.mode
		var/list/civiliansAlreadyPinged = list()// try not to have the same person picked twice
		var/list/broadcasts = list()
		for(var/datum/gang/targetGang as anything in gamemode.gangs) //create loot bags for this gang (so they get pinged)
			var/list/datum/mind/gangChosenCivvies = list() //which civilians have been picked for this gang
			if (gang_duffle_list[targetGang] == 0) continue

			for(var/i = 1 to gang_duffle_list[targetGang])
				var/datum/mind/civvie = targetGang.get_random_civvie(civiliansAlreadyPinged)
				civiliansAlreadyPinged += civvie
				if (!(civvie in gangChosenCivvies))
					gangChosenCivvies += civvie
				targetGang.target_loot_spawn(civvie,targetGang)
			var/broadcast_string = "<span style='font-size:20px'> The location of [gang_duffle_list[targetGang]] bag[s_es(gang_duffle_list[targetGang])] [(gang_duffle_list[targetGang] == 1) ? "is" : "are" ] available on the PDA[s_es(gang_duffle_list[targetGang])] of: "
			if (length(gangChosenCivvies) > 1)
				for (var/name=1 to length(gangChosenCivvies)-1)
					broadcast_string += "[gangChosenCivvies[name].current.real_name] the [gangChosenCivvies[name].assigned_role], "
				broadcast_string += "and [gangChosenCivvies[length(gangChosenCivvies)].current.real_name] the [gangChosenCivvies[length(gangChosenCivvies)].assigned_role]."
			else
				broadcast_string += "[gangChosenCivvies[1].current.real_name] the [gangChosenCivvies[1].assigned_role]."
			broadcast_string += "</span>"
			broadcasts[targetGang] = broadcast_string
		return broadcasts


	proc/doVandalism(gang_vandalism_list)
		var/datum/game_mode/gang/gamemode = ticker.mode
		var/list/broadcasts = list()
		for(var/datum/gang/targetGang as anything in gamemode.gangs) //create loot bags for this gang (so they get pinged)
			if (gang_vandalism_list[targetGang] == null) continue
			var/area/chosen_area = gang_vandalism_list[targetGang]
			var/broadcast_string = "<span style='font-size:20px'> Go to the [initial(chosen_area.name)] and wreck it. Cause havoc, cover it in ProPaint tags for a bag!</span>"
			if (istype(chosen_area, /area/station/janitor))
				targetGang.vandalism_tracker[chosen_area] = GANG_VANDALISM_REQUIRED_SCORE/2 // usually very small and unlikely to get caught anyway. but funny
			else
				targetGang.vandalism_tracker[chosen_area] = GANG_VANDALISM_REQUIRED_SCORE
			broadcasts[targetGang] = broadcast_string
		return broadcasts

