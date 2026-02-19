/datum/game_mode/construction
	name = "Construction (For testing only. Don't select this!)"
	config_tag = "construction"
	regular = FALSE
	crew_shortage_enabled = 0
	var/list/enabled_jobs = list()
	var/list/milestones = list()
	var/list/assigned_areas = list()
	var/starttime = null
	var/human_time_left = ""
	var/round_length = 0
	var/next_progress_check_at

	var/list/special_supply_control = list()
	var/list/special_demand_control = list()

	var/datum/construction_controller/events = null

	var/in_setup = 0

	var/g_smx
	var/g_smy
	do_antag_random_spawns = 0

/datum/generation_marker
	var/x
	var/y
	var/z
	var/probability

/datum/game_mode/construction/announce()
	boutput(world, "<B>The current game mode is - Construction!</B>")
	boutput(world, "<B>You have been assigned to construct the next generation space station.</B>")
	boutput(world, "<B>The map will reset in 12 hours and 30 minutes.</B>")

/datum/game_mode/construction/pre_setup()
	in_setup = 1
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (player.ready_play)
			player.close_spawn_windows()

	var/datum/job/special/station_builder/C = new /datum/job/special/station_builder()
	C.limit = -1
	enabled_jobs += C
	boutput(world, "<B><font color='red'>Setting up map for construction. This will not take a very long time.</font></B>")
	var/area/shuttle/arrival/station/AS = locate() in world
	AS.requires_power = 1
	var/turf/O = AS.find_middle(1)

	// Create a supply post.
	var/bx = O.x
	var/by = O.y
	var/list/dirs = list()
	if (bx - 25 > 0)
		if (by - 25 > 0)
			if (istype(locate(bx - 15, by - 15, 1), /turf/space))
				dirs += "southwest"
		if (by + 25 < 300)
			if (istype(locate(bx - 15, by + 15, 1), /turf/space))
				dirs += "northwest"
	if (bx + 25 < 300)
		if (by - 25 > 0)
			if (istype(locate(bx + 15, by - 15, 1), /turf/space))
				dirs += "southeast"
		if (by + 25 < 300)
			if (istype(locate(bx + 15, by + 15, 1), /turf/space))
				dirs += "northeast"
	var/supply_loc = pick(dirs)
	var/doorx = bx
	var/doory = by
	var/manx = bx
	switch (supply_loc)
		if ("southwest")
			bx -= 25
			by -= 25
			doorx = bx + 10
			manx = bx + 1
			doory = by + 9
		if ("northwest")
			bx -= 25
			by += 15
			doorx = bx + 10
			manx = bx + 1
			doory = by + 1
		if ("southeast")
			bx += 15
			by -= 25
			doorx = bx
			manx = bx + 9
			doory = by + 9
		if ("northeast")
			bx += 15
			by += 15
			doorx = bx
			manx = bx + 9
			doory = by + 1
	var/list/manufacturers = list(/obj/machinery/manufacturer/general, /obj/machinery/manufacturer/hangar,  /obj/machinery/portable_reclaimer, /obj/storage/crate/abcumarker, /obj/machinery/abcu, /obj/machinery/abcu)
	var/list/amounted = list(/obj/item/tile/steel, /obj/item/sheet/steel, /obj/item/rods/steel, /obj/item/sheet/glass)
	var/list/item_class_1 = list(/obj/item/crowbar, /obj/item/weldingtool, /obj/item/screwdriver, /obj/item/wrench, /obj/item/device/multitool, /obj/item/tank/air) + amounted
	var/list/item_class_2 = list(/obj/item/storage/toolbox/mechanical, /obj/item/storage/toolbox/electrical, /obj/item/storage/toolbox/emergency, /obj/item/tank/oxygen) + amounted
	var/list/item_class_3 = list(/obj/machinery/portable_atmospherics/canister/air, /obj/reagent_dispensers/fueltank, /obj/reagent_dispensers/foamtank, /obj/item/tank/jetpack, /obj/item/rcd_ammo) + amounted
	var/list/item_class_4 = list(/obj/machinery/portable_atmospherics/canister/oxygen, /obj/item/tank/jetpack, /obj/item/rcd_ammo/big, /obj/item/gun/energy/laser_gun) + amounted
	var/picks = 0
	for (var/cx = bx, cx <= bx + 10, cx++)
		for (var/cy = by, cy <= by + 10, cy++)
			var/turf/T = locate(cx, cy, 1)
			var/holds_items = 0
			if ((cx == bx || cy == by || cx == bx + 10 || cy == by + 10) && !(cx == doorx && cy == doory))
				T = new /turf/simulated/wall(T)
			else
				T = new /turf/simulated/floor/plating(T)
				if (!(cx == doorx && cy == doory))
					holds_items = 1
				else
					new /obj/machinery/door/airlock/external(T)
			new /area/station/hallway/secondary/construction(T)
			if (holds_items)
				if (cx == manx && length(manufacturers))
					var/object = pick(manufacturers)
					manufacturers -= object
					new object(T)
				else
					if (prob(5))
						var/obj/artifact/lamp/L = new /obj/artifact/lamp(T)
						SPAWN(1 SECOND)
							L.ArtifactActivated()
					if (prob(100 / (picks + 1)))
						new /obj/item/mining_tool(T)
						picks++
					var/count = pick(prob(50); 0, 1, prob(25); 2, prob(10); 3)
					for (var/i = 0; i < count; i++)
						var/item_class = pick(1, prob(50); 2, prob(25); 3, prob(10); 4)
						switch (item_class)
							if (1)
								var/itemt = pick(item_class_1)
								var/obj/item/I = new itemt(T)
								if (itemt in amounted)
									I.amount = 10
							if (2)
								var/itemt = pick(item_class_2)
								var/obj/item/I = new itemt(T)
								if (itemt in amounted)
									I.amount = 25
							if (3)
								var/itemt = pick(item_class_3)
								var/obj/item/I = new itemt(T)
								if (itemt in amounted)
									I.amount = 50
							if (4)
								var/itemt = pick(item_class_4)
								var/obj/item/I = new itemt(T)
								if (itemt in amounted)
									I.amount = 100

	for (var/i = 0, i < rand(8,11), i++)
		spawn_edge_asteroid(2)

	for (var/i = 0, i < rand(21,30), i++)
		spawn_edge_asteroid(1)


	boutput(world, "<B>A supply post is located to the [supply_loc]. Establish your station using the supplies you might find in there.</B>")
	starttime = ticker.round_elapsed_ticks
	round_length = 12 * 60 * 60 * 10 + 30 * 60 * 10
	in_setup = 0
	return 1

/proc/spawn_edge_asteroid(var/grade)
	var/list/borders = list("N", "E", "S", "W")
	var/list/common_ores
	var/list/rare_ores
	var/gems = rand(2,6)

	switch (grade)
		if (1)
			common_ores = list(/datum/ore/pharosium, /datum/ore/molitz, /datum/ore/mauxite)
			rare_ores = list(/datum/ore/claretine, /datum/ore/bohrum)

		if (2)
			common_ores = list(/datum/ore/claretine, /datum/ore/bohrum, /datum/ore/viscerite, /datum/ore/koshmarite)
			rare_ores = list(/datum/ore/plasmastone, /datum/ore/cobryl)

		else
			common_ores = list(/datum/ore/pharosium, /datum/ore/molitz, /datum/ore/mauxite)
			rare_ores = list(/datum/ore/claretine, /datum/ore/bohrum)

	var/ax = 0
	var/ay = 0
	var/border = pick(borders)
	switch (border)
		if ("N")
			ay = rand(275, 292)
			ax = rand(8, 292)
		if ("S")
			ay = rand(8, 25)
			ax = rand(8, 292)
		if ("E")
			ax = rand(275, 292)
			ay = rand(8, 292)
		if ("W")
			ax = rand(8, 25)
			ay = rand(8, 292)
	var/valid = 1
	for (var/cx = ax - 5, cx <= ax + 5, cx++)
		for (var/cy = ay - 5, cy <= ay + 5, cy++)
			var/turf/space/T = locate(cx, cy, 1)
			if (!istype(T))
				valid = 0
				break
		if (!valid)
			break
	if (!valid)
		return

	var/major_ore = mining_controls.get_ore_from_path(pick(common_ores))
	var/minor_ores = list()
	switch (rand(1,4))
		if (1 to 2)
			minor_ores += mining_controls.get_ore_from_path(pick(common_ores))
			minor_ores += mining_controls.get_ore_from_path(pick(common_ores))
		if (3)
			minor_ores += mining_controls.get_ore_from_path(pick(rare_ores))
		if (4)
			minor_ores += mining_controls.get_ore_from_path(pick(common_ores))
			minor_ores += mining_controls.get_ore_from_path(pick(rare_ores))
	var/datum/generation_marker/initial = new
	logTheThing(LOG_DEBUG, null, "<B>Marquesas/Construction:</B> Generating asteroid at [showCoords(ax, ay, 1)].")
	initial.x = ax
	initial.y = ay
	initial.z = 1
	initial.probability = 100
	var/list/tiles = list(initial)
	var/list/processing = list(locate(ax, ay, 1))
	while (tiles.len)
		var/datum/generation_marker/marker = tiles[1]
		tiles -= marker
		var/turf/T = locate(marker.x, marker.y, marker.z)
		processing -= T
		var/turf/simulated/wall/auto/asteroid/AST = new /turf/simulated/wall/auto/asteroid(T)
		processing += T
		var/datum/ore/ORE = null
		switch (rand(1, 5))
			if (1 to 2)
				ORE = major_ore
			if (3)
				ORE = pick(minor_ores)
			else
				; // default
		if (ORE)
			AST.ore = ORE
			AST.hardness += ORE.hardness_mod
			AST.amount = rand(ORE.amount_per_tile_min,ORE.amount_per_tile_max)
			AST.ClearAllOverlays() // i know theres probably a better way to handle this
			AST.UpdateIcon()
			var/image/ore_overlay = image('icons/turf/walls/asteroid.dmi',"[ORE.name][AST.orenumber]")
			ore_overlay.filters += filter(type="alpha", icon=icon('icons/turf/walls/asteroid.dmi',"mask-side_[AST.icon_state]"))
			ore_overlay.layer = ASTEROID_TOP_OVERLAY_LAYER // so meson goggle nerds can still nerd away
			AST.AddOverlays(ore_overlay, "ast_ore")

#ifndef UNDERWATER_MAP // We don't want fullbright ore underwater.
			AST.AddOverlays(new /image/fullbright, "fullbright")
#endif

			ORE.onGenerate(AST)
			AST.mining_health = ORE.mining_health
			AST.mining_max_health = ORE.mining_health
			if (gems && prob(25))
				gems--
				var/datum/ore/event/gem/gem_event = new()
				gem_event.set_up(ORE)
				AST.set_event(gem_event)

		T = locate(marker.x - 1, marker.y, marker.z)
		if (T)
			if (!(T in processing) && prob(marker.probability))
				processing += T
				var/datum/generation_marker/M = new
				M.x = marker.x - 1
				M.y = marker.y
				M.z = marker.z
				M.probability = marker.probability * 0.75
				tiles += M

		T = locate(marker.x + 1, marker.y, marker.z)
		if (T)
			if (!(T in processing) && prob(marker.probability))
				processing += T
				var/datum/generation_marker/M = new
				M.x = marker.x + 1
				M.y = marker.y
				M.z = marker.z
				M.probability = marker.probability * 0.75
				tiles += M

		T = locate(marker.x, marker.y - 1, marker.z)
		if (T)
			if (!(T in processing) && prob(marker.probability))
				processing += T
				var/datum/generation_marker/M = new
				M.x = marker.x
				M.y = marker.y - 1
				M.z = marker.z
				M.probability = marker.probability * 0.75
				tiles += M

		T = locate(marker.x, marker.y + 1, marker.z)
		if (T)
			if (!(T in processing) && prob(marker.probability))
				processing += T
				var/datum/generation_marker/M = new
				M.x = marker.x
				M.y = marker.y + 1
				M.z = marker.z
				M.probability = marker.probability * 0.75
				tiles += M
	for (var/turf/simulated/wall/auto/asteroid/AST in processing)
		AST.space_overlays()


/proc/dstohms(var/ds)
	var/hours = round(ds / (10 * 60 * 60))
	var/minutes = round((ds - (hours * 10 * 60 * 60)) / (10 * 60))
	var/seconds = round((ds - (hours * 10 * 60 * 60) - (minutes * 10 * 60)) / 10)
	if (hours < 0)
		hours = 0
	if (minutes < 0)
		minutes = 0
	if (seconds < 0)
		seconds = 0
	if (hours < 10 && hours)
		hours = "0[hours]"
	if (minutes < 10)
		minutes = "0[minutes]"
	if (seconds < 10)
		seconds = "0[seconds]"
	if (hours)
		return "[hours]:[minutes]:[seconds]"
	return "[minutes]:[seconds]"

/datum/game_mode/construction/process()
	var/diff = ticker.round_elapsed_ticks - starttime
	var/remaining = round_length - diff
	human_time_left = dstohms(remaining)

	for (var/datum/supply_control/S in special_supply_control)
		if (S.current_stock >= S.maximum_stock)
			S.next_resupply_at = 0
			S.next_resupply_text = null
			S.current_stock = S.maximum_stock
		if (S.next_resupply_at && ticker.round_elapsed_ticks > S.next_resupply_at && S.maximum_stock > S.current_stock)
			S.current_stock++
			if (S.maximum_stock > S.current_stock)
				S.next_resupply_at = ticker.round_elapsed_ticks + S.replenishment_time
			else
				S.next_resupply_at = 0
				S.next_resupply_text = null
		S.update_resupply_text()

	for (var/datum/demand_control/D in special_demand_control)
		if (ticker.round_elapsed_ticks - D.last_demand_change > D.demand_change_interval)
			D.fluctuate()
			D.last_demand_change = ticker.round_elapsed_ticks
		D.demand_change_text = dstohms(D.demand_change_interval - (ticker.round_elapsed_ticks - D.last_demand_change))

	if (ticker.round_elapsed_ticks > next_progress_check_at)
		for (var/datum/progress/P in src.milestones)
			if (P.periodical_check)
				P.process()
		next_progress_check_at = ticker.round_elapsed_ticks + 6000

	events.process()

/datum/game_mode/construction/check_finished()
	if (ticker.round_elapsed_ticks - starttime > round_length)
		return 1
	return 0

/datum/game_mode/construction/declare_completion()
	boutput(world, "<b><span color='red'>The construction is over. There will be some obscure scoring shit here.</span></b>")

/datum/game_mode/construction/post_setup()
	wagesystem.station_budget = 0
	wagesystem.shipping_budget = 7000
	wagesystem.research_budget = 0
	random_events.events_enabled = 0
	random_events.minor_events_enabled = 0
	for (var/tp in childrentypesof(/datum/supply_control))
		var/datum/supply_control/S = new tp()
		if (S.current_stock < S.maximum_stock && S.replenishment_time)
			S.next_resupply_at = S.replenishment_time + ticker.round_elapsed_ticks
		special_supply_control += S
	for (var/tp in childrentypesof(/datum/demand_control))
		var/datum/demand_control/D = new tp()
		D.last_demand_change = ticker.round_elapsed_ticks
		special_demand_control += D
	for (var/pt in childrentypesof(/datum/progress))
		var/datum/progress/P = new pt()
		if (P.is_abstract)
			qdel(P)
			continue
		milestones += P
	for (var/datum/progress/P in milestones)
		if (P.parent)
			var/datum/progress/Q = locate(P.parent) in milestones
			if (Q)
				P.parent = Q
			else
				P.parent = null
	next_progress_check_at = starttime + 6000
	events = new
	events.event_delay = 36000 // grace period: 1 hour

/datum/game_mode/construction/post_post_setup()
	abandon_allowed = 1
	boutput(world, "<B>You may now respawn.</B>")
	machines_may_use_wired_power = 1
	makepowernets()

/proc/debug_supply_pack()
	var/thepath = input("Path", "Path", "/datum/supply_packs") as text
	if (!length(thepath))
		return
	var/therealpath = text2path(thepath)
	if (therealpath)
		var/datum/supply_packs/S = new therealpath()
		if (istype(S))
			S.create(get_turf(usr))
