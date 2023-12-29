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
			topHeat = max(I.get_heat(), topHeat)

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
		if (istype(ticker.mode, /datum/game_mode/gang))
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


