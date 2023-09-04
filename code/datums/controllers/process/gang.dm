/datum/controller/process/gang_tag_vision
	setup()
		name = "Gang_Tags"
		schedule_interval = GANG_TAG_SCAN_RATE DECI SECONDS

	doWork()
		for(var/obj/decal/gangtag/I in by_cat[TR_CAT_GANGTAGS])
			if (!I || I.disposed || I.qdeled)
				continue
			I.find_players()



/datum/controller/process/gang_tag_score
	setup()
		name = "Gang_Tags_Score"
		schedule_interval = GANG_TAG_SCORE_INTERVAL SECONDS

	doWork()
		var/topHeat = 0
		//calculate all heats
		for(var/obj/decal/gangtag/I in by_cat[TR_CAT_GANGTAGS])
			if (!I || I.disposed || I.qdeled)
				continue
			topHeat = max(I.get_heat(), topHeat)

		for(var/obj/decal/gangtag/I in by_cat[TR_CAT_GANGTAGS])
			if (!I || I.disposed || I.qdeled)
				continue
			I.apply_score(topHeat)



/datum/controller/process/gang_spray_regen
	setup()
		name = "Gang_Tags_Spraypaint_Regen"
		schedule_interval = GANG_SPRAYPAINT_REGEN SECONDS
	doWork()
		if (istype(ticker.mode, /datum/game_mode/gang))
			var/datum/game_mode/gang/gamemode = ticker.mode
			broadcast_to_all_gangs("All gangs have been given [GANG_SPRAYPAINT_REGEN_QUANTITY > 1 ? "extra spray cans" : "an extra spray can" ].")
			for(var/datum/gang/I in gamemode.gangs)
				I.spray_paint_remaining += GANG_SPRAYPAINT_REGEN_QUANTITY


/datum/controller/process/gang_launder_money
	setup()
		name = "Gang_Money_laundering"
		schedule_interval = GANG_LAUNDER_DELAY SECONDS
	doWork()
		if (istype(ticker.mode, /datum/game_mode/gang))
			var/datum/game_mode/gang/gamemode = ticker.mode
			for(var/datum/gang/I in gamemode.gangs)
				var/obj/ganglocker/locker = I.locker
				if (locker)
					if (locker.stored_cash > 0)
						var/launder_rate = GANG_LAUNDER_RATE
						if (locker.superlaunder_stacks > 0)
							locker.superlaunder_stacks -= 1
							launder_rate = GANG_LAUNDER_RATE * 1.5

						var/amount = round(min(locker.stored_cash, launder_rate))
						var/points = round(amount/CASH_DIVISOR) //only launder full points
						if (points > 0)
							if (locker.superlaunder_stacks)
								locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_superlaunder")
							else
								locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_launder")
							locker.stored_cash -= (points*CASH_DIVISOR)
							I.score_cash += points
							I.add_points(points)
						else
							locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
					else
						locker.default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
					locker.update_icon()

