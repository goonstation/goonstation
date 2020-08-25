/area/colosseum
	name = "The Colosseum"
	virtual = 1
	ambient_light = "#bfbfbf"

	Entered(var/atom/A)
		..()
		if (istype(A, /obj/machinery/colosseum_putt))
			if (colosseum_controller.state == 1)
				for (var/obj/machinery/colosseum_putt/P in colosseum_controller.staging)
					return
				for (var/mob/living/L in colosseum_controller.staging)
					return
				colosseum_controller.finishStaging()

/area/colosseum/staging
	name = "Colosseum Staging Area"
	icon_state = "purple"
	virtual = 1

	Entered(var/atom/movable/A)
		..()
		if (isliving(A))
			if (colosseum_controller.state >= 2)
				A:gib()

/mob/proc/is_near_colosseum()
	var/area/A = get_area(src)
	if (istype(A, /area/colosseum) || istype(A, /area/gauntlet/viewing))
		return 1
	if (ismob(eye))
		var/mob/M = eye
		if (M.is_near_colosseum())
			return 1
	else if (istype(eye, /obj/observable/colosseum))
		return 1
	return 0

/mob/proc/is_in_colosseum()
	var/area/A = get_area(src)
	if (A && A.type == /area/colosseum)
		return 1
	return 0

/obj/stagebutton/colosseum
	name = "Colosseum Staging Button"

	attack_hand(var/mob/M)
		if (colosseum_controller.state != 0)
			return
		var/mobn = 0
		for (var/mob/N in colosseum_controller.staging)
			if (ishuman(N) && !isdead(N))
				mobn++
		if (mobn > 4)
			boutput(usr, "<span class='alert'>The Colosseum is for 1-4 players. Sorry!</span>")
			return
		if (ticker.round_elapsed_ticks < 3000 && mobn < 4)
			boutput(usr, "<span class='alert'>You may not initiate the Colosseum before 5 minutes into the round, unless you have a team of 4 people.</span>")
			return
		if (alert("Start the Colosseum? No more players will be given admittance to the staging area!",, "Yes", "No") == "Yes")
			if (colosseum_controller.state != 0)
				return
			colosseum_controller.beginStaging()

/datum/arena/colosseumController
	var/area/colosseum/staging/staging
	var/area/gauntlet/viewing/viewing
	var/area/colosseum/colosseum
	var/list/spawnturfs = list()
	var/list/bossturfs = list()
	var/list/pods_claimed = list()

	var/list/possible_waves = list()
	var/list/moblist = list()

	var/list/current_waves = list()
	var/datum/gauntletEvent/current_event = null

	var/current_match_id = 0
	var/difficulty = 0
	var/state = 0
	var/players = 0
	var/current_level = 0
	var/next_level_at = 0
	var/waiting = 0

	var/score = 0
	var/moblist_names = ""

	var/list/icons = list("mini", "nanoputt", "putt_black", "syndiputt")

	var/list/common_drops = list()
	var/list/uncommon_drops = list()
	var/list/rare_drops = list()

	var/boss_counter = 0
	var/boss_count = 1
	var/list/drone_templates = list()
	var/list/bosses = list(/obj/critter/gunbot/drone/helldrone, /obj/critter/gunbot/drone/iridium, /obj/critter/gunbot/drone/iridium/whydrone, /obj/critter/gunbot/drone/iridium/whydrone/horse)
	var/list/current_bosses = null
	var/list/actors = list()

	proc/announceAll(var/message, var/title = "Colosseum update")
		var/rendered = "<span style='font-size: 1.5em; font-weight:bold'>[title]</span><br><br><span style='font-weight:bold;color:blue'>[message]<br>"
		for (var/obj/machinery/colosseum_putt/P in colosseum)
			for (var/mob/M in P)
				boutput(M, rendered)
		for (var/obj/machinery/colosseum_putt/P in staging)
			for (var/mob/M in P)
				boutput(M, rendered)
		for (var/mob/M in staging)
			boutput(M, rendered)
		for (var/mob/M in viewing)
			boutput(M, rendered)
		for (var/mob/M in colosseum)
			boutput(M, rendered)

		for (var/client/C)
			if (!C.mob) continue
			var/mob/M = C.mob

			if (ismob(M.eye) && M.eye != M)
				var/mob/N = M.eye
				if (N.is_near_colosseum())
					boutput(M, rendered)
			else if (istype(M.eye, /obj/observable/colosseum))
				boutput(M, rendered)
			LAGCHECK(LAG_LOW)

	proc/beginStaging()
		if (state != 0)
			return
		state = 1
		for (var/obj/machinery/door/poddoor/buff/staging/S in staging)
			SPAWN_DBG(0)
				S.close()
		var/mobn = 0
		for (var/mob/M in staging)
			if (ishuman(M) && !isdead(M))
				mobn++
				moblist += M
				if (moblist_names != "")
					moblist_names += ", "
				var/thename = M.real_name
				if (istype(M, /mob/living/carbon/human/virtual))
					var/mob/living/L = M:body
					if (L)
						thename = L.real_name
					else
						thename = copytext(M.real_name, 9)
				moblist_names += thename
				if (M.client)
					moblist_names += " ([M.client.key])"
		players = mobn
		difficulty = 1
		var/list/possibles = list()
		for (var/turf/unsimulated/floor/T in staging)
			possibles += T
		var/list/myicons = icons.Copy()
		for (var/i = 1, i <= mobn, i++)
			var/turf/Q = pick(possibles)
			var/obj/machinery/colosseum_putt/C = new /obj/machinery/colosseum_putt(Q)
			if (myicons.len)
				var/icon = pick(myicons)
				myicons -= icon
				C.icon_state = icon
			possibles -= Q
			showswirl(Q)
			Q = pick(possibles)
			new /obj/item/clothing/suit/space(Q)
			new /obj/item/clothing/head/helmet/space(Q)
			new /obj/item/clothing/mask/breath(Q)
			new /obj/item/tank/jetpack(Q)
			new /obj/item/weldingtool(Q)
			possibles -= Q
			showswirl(Q)
		announceAll("The Pod Colosseum Arena has now entered staging phase. No more players may enter the game area. The game will start once all players enter the colosseum space inside a pod.")
		var/spawned_match_id = current_match_id
		for (var/obj/machinery/door/poddoor/buff/gauntlet/S in colosseum)
			SPAWN_DBG(0)
				S.open()
		for (var/obj/machinery/door/poddoor/buff/gauntlet/S in staging)
			SPAWN_DBG(0)
				S.open()
		allow_processing = 1
		SPAWN_DBG(2 MINUTES)
			if (state == 1 && current_match_id == spawned_match_id)
				announceAll("Game did not start after 2 minutes. Resetting arena.")
				resetArena()

	proc/finishStaging()
		if (state == 2)
			return
		state = 2

		for (var/obj/machinery/door/poddoor/buff/gauntlet/S in colosseum)
			SPAWN_DBG(0)
				S.close()
		for (var/obj/machinery/door/poddoor/buff/gauntlet/S in staging)
			SPAWN_DBG(0)
				S.close()
		for (var/mob/living/M in colosseum)
			if (M in moblist || !ishuman(M) || isdead(M))
				continue
			moblist += M
			if (moblist_names != "")
				moblist_names += ", "
			var/thename = M.real_name
			if (istype(M, /mob/living/carbon/human/virtual))
				var/mob/living/L = M:body
				if (L)
					thename = L.real_name
				else
					thename = copytext(M.real_name, 9)
			moblist_names += thename
			if (M.client)
				moblist_names += " ([M.client.key])"
		logTheThing("debug", null, null, "<b>Marquesas/Pod Colosseum</b>: Starting arena game with players: [moblist_names]")
		announceAll("The Pod Colosseum Arena game is now in progress. The fight will begin soon.")
		next_level_at = ticker.round_elapsed_ticks + 300

	// TODO: use these? I guess?
	proc/increaseCritters(var/obj/critter/C)
	proc/decreaseCritters(var/obj/critter/C)
		if (!istype(C, /obj/critter/gunbot/drone))
			return
		var/obj/critter/gunbot/drone/D = C
		score += D.score
		generateDrop(C)

	proc/generateDrop(var/obj/critter/gunbot/drone/C)
		var/obj/colosseum_powerup/P
		var/obj/colosseum_powerup/P2
		var/chance = 0
		var/med_limit = rand(12, 30)
		var/high_limit = rand(80, 120)
		if (C.score < med_limit)
			P = pick(common_drops)
			chance = 50
		else if (C.score < high_limit)
			P = pick(uncommon_drops)
			P2 = pick(common_drops)
			chance = 75
		else
			P = pick(rare_drops)
			P2 = pick(uncommon_drops)
			chance = 50
		if (prob(chance))
			P.clone(get_turf(C))
		else if (P2)
			P2.clone(get_turf(C))

	process()
		if (state == 2)
			if (ticker.round_elapsed_ticks > next_level_at)
				startGame()
		else if (state == 3)
			difficulty += 0.01
			var/livemobs = 0
			for (var/mob/living/M in moblist)
				if (get_area(M) == colosseum)
					livemobs++
			if (!livemobs)
				state = 0
				announceAll("Everyone is dead! Resetting...")
			if (ticker.round_elapsed_ticks > next_level_at)
				setNextDroneTime()
				boss_counter--
				if (boss_counter <= 0)
					spawnBoss()
				else
					spawnDrone()
			for (var/obj/bullethell/O in actors)
				O.process()

		if (state == 0)
			resetArena()

	proc/setNextDroneTime()
		var/frac = (difficulty * 250) % 100
		var/whole = round(difficulty / 2)
		next_level_at = ticker.round_elapsed_ticks + round(max(17,(max(35, 120 - frac) / ((players+1) / 2)) - whole))

	proc/spawnBoss()
		boss_counter = rand(60, 100) * round((players + 1) / 2)
		if (!current_bosses.len)
			boss_count++
			current_bosses = bosses.Copy()
		var/bosst = current_bosses[1]
		current_bosses.Cut(1,2)
		for (var/i = 1, i <= boss_count, i++)
			var/turf/Q = pick(bossturfs)
			new bosst(Q)
			showswirl(Q)
		announceAll("Boss time!")

	proc/spawnDrone()
		var/fallback = /obj/critter/gunbot/drone
		var/choice = null
		var/tries = 0
		while (!choice && tries < 10)
			// this is causing a fucking LIST INDEX OUT OF BOUNDS ERROR. wow.
			//var/obj/critter/gunbot/drone/D = pick(drone_templates)
			var/id = rand(1, drone_templates.len)
			var/obj/critter/gunbot/drone/D = drone_templates[id]
			if (D.score < difficulty * 15 && prob((difficulty * 15 - D.score) * 4))
				choice = D.type
			tries++
		if (!choice)
			choice = fallback
		var/turf/Q = pick(spawnturfs)
		new choice(Q)
		showswirl(Q)

	var/resetting = 0

	proc/resetArena()
		if (resetting)
			return
		resetting = 1
		allow_processing = 0
		pods_claimed = list()
		announceAll("The Pod Colosseum match concluded. Final score: [score].")
		if (score > 10000)
			var/command_report = "A Pod Colosseum match has concluded with score [score]. Congratulations to: [moblist_names]."
			for (var/obj/machinery/communications_dish/C in by_type[/obj/machinery/communications_dish])
				C.add_centcom_report("[command_name()] Update", command_report)

			command_alert(command_report, "Pod Colosseum match finished")
		statlog_gauntlet(moblist_names, score, 0)

		SPAWN_DBG(0)
			for (var/obj/machinery/colosseum_putt/P in staging)
				for (var/mob/living/M in P)
					M.gib()
				qdel(P)
			for (var/obj/machinery/colosseum_putt/P in colosseum)
				for (var/mob/living/M in P)
					M.gib()
				qdel(P)
			for (var/obj/item/I in staging)
				qdel(I)
			for (var/obj/item/I in colosseum)
				qdel(I)
			for (var/obj/artifact/A in colosseum)
				qdel(A)
			for (var/obj/critter/C in colosseum)
				qdel(C)
			for (var/obj/machinery/bot/B in colosseum)
				qdel(B)
			for (var/mob/living/M in colosseum)
				M.gib()
			for (var/mob/living/M in staging)
				M.gib()
			for (var/obj/decal/D in colosseum)
				if (!istype(D, /obj/decal/teleport_swirl))
					qdel(D)

			for (var/obj/machinery/door/poddoor/buff/staging/S in staging)
				SPAWN_DBG(0)
					S.open()
			for (var/obj/machinery/door/poddoor/buff/gauntlet/S in colosseum)
				SPAWN_DBG(0)
					S.close()
			for (var/obj/machinery/door/poddoor/buff/gauntlet/S in staging)
				SPAWN_DBG(0)
					S.close()

		moblist.len = 0
		moblist_names = ""
		score = 0
		state = 0
		players = 0
		resetting = 0

	New()
		SPAWN_DBG(0.5 SECONDS)
			viewing = locate() in world
			staging = locate() in world
			for (var/area/G in world)
				LAGCHECK(LAG_LOW)
				if (G.type == /area/colosseum)
					colosseum = G
					break
			var/minx = 300
			var/miny = 300
			var/maxx = 0
			var/maxy = 0
			for (var/turf/T in colosseum)
				if (!T.density)
					spawnturfs += T
					if (T.x < minx)
						minx = T.x
					if (T.y < miny)
						miny = T.y
					if (T.x > maxx)
						maxx = T.x
					if (T.y > maxy)
						maxy = T.y
			for (var/turf/T in spawnturfs)
				if (T.x > minx + 2 && T.y > miny + 2 && T.x < maxx - 2 && T.y < maxy - 2)
					bossturfs += T

			for (var/PUP in childrentypesof(/obj/colosseum_powerup/stat))
				var/obj/colosseum_powerup/stat/S = new PUP(null, 1)
				switch (S.rarity_class)
					if (1)
						common_drops += S
					if (2)
						uncommon_drops += S
					if (3)
						rare_drops += S
					else
						common_drops += S

			for (var/PUP in childrentypesof(/datum/colosseumSystem))
				var/datum/colosseumSystem/NS = new PUP()
				if (NS.abstract)
					continue
				var/obj/colosseum_powerup/system/S = new(null, 1, NS.type)
				switch (NS.rarity_class)
					if (1)
						common_drops += S
					if (2)
						uncommon_drops += S
					if (3)
						rare_drops += S
					else
						common_drops += S

			for (var/DT in typesof(/obj/critter/gunbot/drone) - bosses)
				if (DT in bosses)
					continue
				var/obj/critter/gunbot/drone/D = new DT()
				D.is_template = 1
				drone_templates += D

	proc/startGame()
		if (state == 3)
			return
		announceAll("The Pod Colosseum fight is starting now.")
		next_level_at = ticker.round_elapsed_ticks + 100
		boss_counter = rand(60, 100)
		boss_count = 1
		current_bosses = bosses.Copy()
		waiting = 5
		state = 3


	proc/Stat()
		stat(null, "")
		stat(null, "--- COLOSSEUM ---")
		switch (state)
			if (0)
				stat(null, "No match is currently in progress.")
			if (1)
				stat(null, "Match is currently in setup stage.")
				stat(null, "Registered players: [players]")
			if (2)
				stat(null, "Fight starts in [dstohms(next_level_at - ticker.round_elapsed_ticks)].")
			if (3)
				stat(null, "Score: [score]")
				stat(null, "Current difficulty level: [difficulty]")
				stat(null, "Spawns left until boss: [boss_counter]")
		stat(null, "--- COLOSSEUM ---")
		stat(null, "")

var/global/datum/arena/colosseumController/colosseum_controller = new()

/client/proc/debug_colosseum_controller()
	set category = "Debug"
	set name = "Edit Colosseum Controller"

	src.debug_variables(colosseum_controller)

/turf/unsimulated/floor/setpieces/gauntlet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover, /obj/machinery/colosseum_putt))
		return 0
	return ..()

/turf/unsimulated/floor/setpieces/gauntlet/pod
	name = "Colosseum Hangar Floor"
	desc = "You wonder if that little flashing white thing is a pod or a butt."
	icon_state = "gauntfloorPod"
	event_handler_flags = USE_CANPASS

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (istype(mover, /obj/machinery/colosseum_putt))
			return 1
		return ..()

/datum/healthBar
	var/list/barBits = list()
	var/image/health_overlay

	New(var/barLength = 4, var/is_left = 0)
		for (var/i = 1, i <= barLength, i++)
			var/obj/screen/S = new /obj/screen()
			var/edge = is_left ? "WEST" : "EAST"
			S.layer = HUD_LAYER
			S.name = "health"
			S.icon = 'icons/obj/colosseum.dmi'
			if (i == 1)
				S.icon_state = "health_bar_left"
				var/sl = barLength - i
				S.screen_loc = "NORTH+1,[edge]-[sl]"
			else if (i == barLength)
				S.icon_state = "health_bar_right"
				S.screen_loc = "NORTH+1,[edge]"
			else
				S.icon_state = "health_bar_center"
				var/sl = barLength - i
				S.screen_loc = "NORTH+1,[edge]-[sl]"
			barBits += S
		health_overlay = image('icons/obj/colosseum.dmi', "health")

	proc/add_to_hud(var/datum/hud/H)
		for (var/obj/screen/S in barBits)
			H.add_object(S)

	proc/add_to(var/mob/M)
		if (M.client)
			for (var/obj/screen/S in barBits)
				M.client.screen += S

	proc/remove_from(var/mob/M)
		if (M.client)
			for (var/obj/screen/S in barBits)
				M.client.screen -= S

	proc/update_health_overlay(var/health_value, var/health_max, var/shield_value, var/shield_max)
		for (var/obj/screen/S in barBits)
			S.overlays.len = 0
		add_overlay(health_value, health_max, 204, 0, 0, 0, 204, 0)
		if (shield_value > 0)
			add_overlay(shield_value, shield_max, 0, 255, 255, 0, 102, 102)
			add_counter(barBits.len, shield_value, "#000000")
		else
			add_counter(barBits.len, health_value, "#000000")

	proc/add_overlay(value, max_value, r0, g0, b0, r1, g1, b1)
		var/percentage = value / max_value
		var/remaining = round(percentage * 100)
		var/bars = barBits.len
		var/eachBar = 100 / bars
		var/missingBars = 0
		health_overlay.color = rgb(lerp(r0, r1, percentage), lerp(g0, g1, percentage), lerp(b0, b1, percentage))
		while (100 - (missingBars * eachBar) >= remaining && missingBars <= bars)
			missingBars++
		missingBars--

		for (var/i = 1, i <= bars, i++)
			var/obj/screen/S = barBits[i]
			if (i <= missingBars)
				continue
			else if (i == missingBars + 1)
				var/matrix/Mat = matrix()
				var/present = (bars - missingBars - 1) * eachBar
				var/mine = remaining - present
				var/scale = mine / eachBar
				var/move = 16 - (16 * scale)
				Mat.Scale(scale, 1)
				health_overlay.transform = Mat
				health_overlay.pixel_x = move + 1
				S.overlays += health_overlay
				health_overlay.transform = null
				health_overlay.pixel_x = 0
			else
				S.overlays += health_overlay

	proc/add_counter(var/bit, var/value, var/textcolor)
		var/obj/screen/counter = barBits[bit]
		if (value < 0)
			counter.overlays += image('icons/obj/colosseum.dmi', "INF")
		else
			if (value > 999)
				value = 999
			if (value >= 100)
				var/R2 = round(value / 100)
				var/image/left = image('icons/obj/colosseum.dmi', "[R2]")
				left.color = textcolor
				left.pixel_x = -8
				counter.overlays += left
			if (value >= 10)
				var/R1 = round(value / 10) % 10
				var/image/center = image('icons/obj/colosseum.dmi', "[R1]")
				center.color = textcolor
				counter.overlays += center
			var/R0 = round(value % 10)
			var/image/right = image('icons/obj/colosseum.dmi', "[R0]")
			right.color = textcolor
			right.pixel_x = 8
			counter.overlays += right

/datum/colosseumIndicator
	var/obj/screen/hud/indicated_icon
	var/obj/screen/counter
	var/datum/colosseumSystem/tracking
	var/force_rebuild = 0
	var/data_displayed = null
	var/displayed = -1

	New()
		..()
		indicated_icon = new
		counter = new
		indicated_icon.icon = 'icons/obj/colosseum.dmi'
		indicated_icon.icon_state = "projectile_container"
		indicated_icon.tooltipTheme = "colo-pod"
		counter.icon = 'icons/obj/colosseum.dmi'
		counter.icon_state = "projectile_counter"
		assembleDefault()

	proc/assembleDefault()

	proc/setWest(var/n)
		if (n)
			indicated_icon.screen_loc = "NORTH+1,WEST+[n]"
		counter.screen_loc = "NORTH+1,WEST+[n+1]"

	primary
		New()
			..()
			indicated_icon.screen_loc = "NORTH+1,WEST"
			counter.screen_loc = "NORTH+1,WEST+1"

		assembleDefault()
			..()
			displayed = -1
			indicated_icon.overlays.len = 0
			indicated_icon.overlays += image('icons/obj/projectiles.dmi', "phaser_heavy")
			counter.overlays.len = 0
			counter.overlays += image('icons/obj/colosseum.dmi', "INF")
			indicated_icon.name = "Light Phaser"
			counter.name = "Light Phaser"

	secondary
		New()
			..()
			indicated_icon.screen_loc = "NORTH+1,WEST+2"
			counter.screen_loc = "NORTH+1,WEST+3"

		assembleDefault()
			..()
			displayed = 0
			indicated_icon.overlays.len = 0
			indicated_icon.overlays += image('icons/obj/projectiles.dmi', "none_container")
			counter.overlays.len = 0
			counter.overlays += image('icons/obj/colosseum.dmi', "none_counter")
			indicated_icon.name = "No Secondary Weapon"
			counter.name = "No Secondary Weapon"

	proc/assume_weapon(var/datum/colosseumSystem/S)
		if (!istype(S))
			tracking = null
			assembleDefault()
			return
		tracking = S
		indicated_icon.overlays.len = 0
		indicated_icon.name = tracking.name
		counter.name = tracking.name
		indicated_icon.overlays += image(tracking.icon, tracking.icon_state)
		counter.overlays.len = 0
		force_rebuild = 1
		update_count()

	proc/assume_other(var/dataname, var/icon, var/icon_state, var/value)
		if (data_displayed != dataname)
			indicated_icon.overlays.len = 0
			indicated_icon.name = dataname
			counter.name = dataname
			indicated_icon.overlays += image(icon, icon_state)
			data_displayed = dataname
		set_value(value)

	proc/add_to(var/mob/M)
		if (M.client)
			M.client.screen += indicated_icon
			M.client.screen += counter

	proc/remove_from(var/mob/M)
		if (M.client)
			M.client.screen -= indicated_icon
			M.client.screen -= counter

	proc/set_value(var/value)
		if (displayed != value || force_rebuild)
			force_rebuild = 0
			counter.overlays.len = 0
			if (value < 0)
				displayed = -1
				counter.overlays += image('icons/obj/colosseum.dmi', "INF")
			else
				if (value > 999)
					value = 999
				if (value >= 100)
					var/R2 = round(value / 100)
					var/image/left = image('icons/obj/colosseum.dmi', "[R2]")
					left.color = rgb(rand(128,255), rand(128,255), rand(128,255))
					left.pixel_x = -8
					counter.overlays += left
				if (value >= 10)
					var/R1 = round(value / 10) % 10
					var/image/center = image('icons/obj/colosseum.dmi', "[R1]")
					center.color = rgb(rand(128,255), rand(128,255), rand(128,255))
					counter.overlays += center
				var/R0 = value % 10
				var/image/right = image('icons/obj/colosseum.dmi', "[R0]")
				right.color = rgb(rand(128,255), rand(128,255), rand(128,255))
				right.pixel_x = 8
				counter.overlays += right
				displayed = value

	proc/update_count()
		if (!tracking)
			return
		set_value(tracking.ammo)

/datum/colosseumSystem
	var/name = "Weapon System"
	var/icon = 'icons/obj/colosseum.dmi'
	var/icon_state = "default_container"
	var/ammo = 1
	var/slot = 0
	var/cooldown = 10
	var/rarity_class = 1
	var/abstract = 1

	proc/use(var/obj/machinery/colosseum_putt/C)
		ammo--
		return cooldown

	proc/reapply_overlays()
		return

	primary
		abstract = 1
		slot = 0
		rarity_class = 1
		var/datum/projectile/myProj

		New()
			..()
			if (myProj)
				myProj = new myProj()

		use(var/obj/machinery/colosseum_putt/C)
			. = ..()
			C.shoot_projectile(myProj)

		laser
			name = "Laser"
			myProj = /datum/projectile/laser
			ammo = 40
			abstract = 0
			icon = 'icons/obj/projectiles.dmi'
			icon_state = "laser"

		shotgun
			name = "Ballistic"
			myProj = /datum/projectile/bullet/a12
			ammo = 40
			abstract = 0
			icon = 'icons/obj/items/gun.dmi'
			icon_state = "shotgun"

		aex
			name = "Ballistic (explosive)"
			myProj = /datum/projectile/bullet/aex
			ammo = 20
			abstract = 0
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "aex"
			rarity_class = 2

		drill
			name = "Drill"
			myProj = /datum/projectile/laser/drill
			ammo = 50
			abstract = 0
			cooldown = 3
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "drill"
			rarity_class = 2

		splitter
			name = "Splitter"
			myProj = /datum/projectile/laser/light/split
			ammo = 35
			abstract = 0
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "splitter"

		asslaser
			rarity_class = 2
			name = "Assault Laser"
			myProj = /datum/projectile/laser/asslaser
			ammo = 20
			abstract = 0
			icon = 'icons/obj/projectiles.dmi'
			icon_state = "u_laser"

		quad
			rarity_class = 2
			name = "Quad Laser"
			myProj = /datum/projectile/laser/quad
			ammo = 30
			abstract = 0
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "laser_quad"

		seeker
			name = "Drone Seeker"
			myProj = /datum/projectile/bullet/autocannon/seeker
			ammo = 10
			abstract = 0
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "seeker"
			rarity_class = 3

	secondary
		abstract = 1
		slot = 1

		mines
			name = "Mines"
			rarity_class = 1
			ammo = 10
			abstract = 0
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "mine"

			use(var/obj/machinery/colosseum_putt/C)
				var/turf/T = get_step(get_turf(C), turn(C.facing, 180))
				if (!T.density)
					. = ..()
					new /obj/colosseum_mine/explosive(T)

		forcewall
			name = "Forcewall Surround"
			rarity_class = 1
			ammo = 1
			abstract = 0
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "forcewall"

			use(var/obj/machinery/colosseum_putt/C)
				. = ..()
				var/turf/Q = get_turf(C)
				var/forcewall_time = rand(50, 100)
				var/list/affected = list()
				for (var/turf/T in orange(2, C))
					if (get_dist(T, Q) == 2)
						var/obj/overlay/Wall = new(T)
						Wall.anchored = 1
						Wall.set_density(1)
						Wall.opacity = 0
						Wall.icon = 'icons/effects/effects.dmi'
						Wall.icon_state = "shockwave"
						var/dx = abs(T.x - Q.x)
						var/dy = abs(T.y - Q.y)
						if (dx == dy)
							Wall.dir = get_dir(Q, T)
						else if (dx > dy)
							Wall.dir = 4
						else
							Wall.dir = 1
						affected += Wall
				SPAWN_DBG(forcewall_time)
					for (var/obj/W in affected)
						qdel(W)


		iron_curtain
			rarity_class = 2
			name = "Iron Curtain"
			ammo = 1
			abstract = 0
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "iron_curtain_pickup"

			use(var/obj/machinery/colosseum_putt/C)
				. = ..()
				C.invincible = ticker.round_elapsed_ticks + 50
				C.update_shield()

		shield_repair
			rarity_class = 1
			name = "Shield Jump Charger"
			ammo = 10
			abstract = 0
			icon = 'icons/obj/colosseum.dmi'
			icon_state = "shield_recharge"

			use(var/obj/machinery/colosseum_putt/C)
				. = ..()
				C.shield = min(C.shield + 25, C.max_shield)
				C.update_shield()

		projectile
			var/datum/projectile/myProj

			New()
				..()
				if (myProj)
					myProj = new myProj()

			use(var/obj/machinery/colosseum_putt/C)
				. = ..()
				C.shoot_projectile(myProj)

			artillery
				name = "HE Grenade"
				myProj = /datum/projectile/bullet/autocannon
				ammo = 3
				abstract = 0
				icon = 'icons/obj/projectiles.dmi'
				icon_state = "400mm"
				rarity_class = 1

			hunting_rifle
				name = "30.06 Shots"
				myProj = /datum/projectile/bullet/rifle_3006
				ammo = 6
				abstract = 0
				icon = 'icons/obj/items/gun.dmi'
				icon_state = "hunting_rifle"
				rarity_class = 1

			seeker
				name = "Drone Seeker"
				myProj = /datum/projectile/bullet/autocannon/seeker
				ammo = 5
				abstract = 0
				icon = 'icons/obj/colosseum.dmi'
				icon_state = "seeker"
				rarity_class = 2

/obj/screen/colosseumHelp
	name = "Help"
	icon = 'icons/mob/blob_ui.dmi'
	icon_state = "blob-help0"
	screen_loc = "SOUTH,EAST"

	clicked(params)
		..()
		boutput(usr, "<span class='hint'>Press Page Down (or C in WASD mode) to fire your primary weapon.</span>")
		boutput(usr, "<span class='hint'>Press Page Up (or E in WASD mode) to fire your secondary weapon.</span>")
		boutput(usr, "<span class='hint'>Press Insert (or Q in WASD mode) to stop the ship.</span>")
		boutput(usr, "<span class='hint'>Click the ship to get out.</span>")

#define INDICATOR_PRIMARY 1
#define INDICATOR_SECONDARY 2
#define INDICATOR_HEALTH 4
#define INDICATOR_ARMOR 8
#define INDICATOR_FIRERES 16
#define INDICATOR_SHIELDGEN 32
#define INDICATOR_SHOTCOUNT 64
#define INDICATOR_SHOTDAMAGE 128
#define INDICATOR_ALL 255

#define OVERLAY_SHIELD 1
#define OVERLAY_IRON_CURTAIN 2

proc/get_colosseum_message(var/name, var/message)
	return "<span style='color:#cc7d00;'><strong>\[ARENA\] [name]</strong> broadcasts, \"[message]\"</span>"

// I know.
// I'll probably get a lot of flak for this.
// Like, not now, but 3 years from now when I'm declared mport over this by the future generation.
// But /obj/machinery/vehicle looks dumb.
/obj/machinery/colosseum_putt
	name = "Colosseum Putt"
	icon = 'icons/obj/ship.dmi'
	icon_state = "miniputt"
	density = 1
	anchored = 1
	var/owner = null
	var/mob/living/carbon/human/piloting = null
	var/flying = 0
	var/speed = 8
	var/facing = 2
	var/datum/projectile/laser/light/upgradeable/simple
	var/datum/colosseumSystem/primary/primary
	var/datum/colosseumSystem/secondary/secondary
	var/datum/colosseumIndicator/primary/p_indicator
	var/datum/colosseumIndicator/secondary/s_indicator
	var/datum/colosseumIndicator/armor_indicator
	var/datum/colosseumIndicator/fireres_indicator
	var/datum/colosseumIndicator/shieldgen_indicator
	var/datum/colosseumIndicator/shotcount_indicator
	var/datum/colosseumIndicator/shotdamage_indicator
	var/datum/healthBar/health_bar
	var/obj/screen/colosseumHelp/help
	var/obj/colosseum_radio/radio = null
	var/next_fire_primary = 0
	var/next_fire_secondary = 0
	var/may_exit = 1
	var/obj/item/tank/atmostank = null
	var/static/image/fire_overlay = null

	var/armor = 0
	var/armor_sqrt = 0
	var/fireres = 0
	var/fire_sqrt = 0
	var/health = 100
	var/max_health = 100
	var/shield = 50
	var/max_shield = 100
	var/shield_regen = 1
	var/next_shield_regen = 0
	var/has_overlays = 0
	var/image/shield_overlay
	var/image/invincible_overlay
	var/invincible = 0
	var/dying = 0
	var/on_fire = 0

	var/obj/machinery/camera/cam
	var/datum/movement_controller/colosseum_putt/movement_controller
	New()
		..()
		if (!fire_overlay)
			fire_overlay = image('icons/obj/ship.dmi', "minputt_fire")
		help = new()
		simple = new /datum/projectile/laser/light/upgradeable()
		p_indicator = new()
		s_indicator = new()
		armor_indicator = new()
		armor_indicator.assume_other("Armor", 'icons/obj/colosseum.dmi', "armor", armor)
		armor_indicator.setWest(4)
		fireres_indicator = new()
		fireres_indicator.assume_other("Fire Resistance", 'icons/obj/colosseum.dmi', "fireres", fireres)
		fireres_indicator.setWest(6)
		shieldgen_indicator = new()
		shieldgen_indicator.assume_other("Shield Regeneration Rate", 'icons/obj/colosseum.dmi', "shield_genrate", shield_regen)
		shieldgen_indicator.setWest(8)
		shotcount_indicator = new()
		shotcount_indicator.assume_other("Default Phaser Shot Count", 'icons/obj/colosseum.dmi', "default_weapon_count", simple.count)
		shotcount_indicator.setWest(10)
		shotdamage_indicator = new()
		shotdamage_indicator.assume_other("Default Phaser Shot Damage", 'icons/obj/colosseum.dmi', "default_weapon_damage", simple.power)
		shotdamage_indicator.setWest(12)
		atmostank = new /obj/item/tank/air
		health_bar = new(4)
		update_health_overlay()
		shield_overlay = image('icons/effects/effects.dmi', "enshield")
		invincible_overlay = image('icons/obj/colosseum.dmi', "iron_curtain")
		update_shield()
		src.cam = new /obj/machinery/camera(src)
		src.cam.c_tag = src.name
		src.cam.network = "Zeta"
		radio = new(src)

		movement_controller = new(src)

	get_movement_controller()
		return movement_controller

	proc/on_damage()
		next_shield_regen = ticker.round_elapsed_ticks + 50

	proc/update_health_overlay()
		health_bar.update_health_overlay(health, max_health, shield, max_shield)

	process()
		var/shield_update_needed = 0
		var/health_update_needed = 1
		if (invincible && ticker.round_elapsed_ticks > invincible)
			invincible = 0
			shield_update_needed = 1
		if (ticker.round_elapsed_ticks > next_shield_regen)
			if (shield < max_shield)
				shield = min(max_shield, shield + shield_regen * 3)
				shield_update_needed = 1
				health_update_needed = 1
		if (on_fire)
			if (prob(25))
				take_damage(3, 1, 1)
				health_update_needed = 0
				shield_update_needed = 0
		if (health_update_needed)
			update_indicators(INDICATOR_HEALTH)
		if (shield_update_needed)
			update_shield()

	remove_air(amount as num)
		atmostank.air_contents.oxygen += amount / 5
		atmostank.air_contents.nitrogen += 4 * amount / 5
		atmostank.air_contents.temperature = T0C + 36
		if (atmostank.air_contents.carbon_dioxide > 0)
			atmostank.air_contents.carbon_dioxide -= HUMAN_NEEDED_OXYGEN * 2
			atmostank.air_contents.carbon_dioxide = max(atmostank.air_contents.carbon_dioxide, 0)
		return atmostank.remove_air(amount)

	proc/shoot_projectile(var/datum/projectile/Pr)
		var/shoot_dir = facing
		if (!(shoot_dir in cardinal))
			shoot_dir &= 3
		var/xo = 0
		var/yo = 0
		switch (shoot_dir)
			if (1)
				yo = 1
			if (2)
				yo = -1
			if (4)
				xo = 1
			if (8)
				xo = -1

		var/obj/projectile/P = initialize_projectile(get_turf(src), Pr, xo, yo, src)
		P.launch()

	proc/fire_primary()
		if (ticker.round_elapsed_ticks < next_fire_primary)
			return
		if (primary)
			next_fire_primary = ticker.round_elapsed_ticks + primary.use(src)
			if (!primary.ammo)
				primary = null
		else
			next_fire_primary = ticker.round_elapsed_ticks + 10
			shoot_projectile(simple)
		update_indicators(INDICATOR_PRIMARY)

	proc/fire_secondary()
		if (ticker.round_elapsed_ticks < next_fire_secondary)
			return
		if (secondary)
			next_fire_secondary = ticker.round_elapsed_ticks + secondary.use(src)
			if (!secondary.ammo)
				secondary = null
		else
			boutput(usr, "<span class='alert'>You currently have no secondary weapon.</span>")
		update_indicators(INDICATOR_SECONDARY)

	Bump(atom/A)
		//walk(src, 0)
		flying = 0
		dir = facing

	/*override_southeast(mob/user)
		if (piloting != user)
			return
		fire_primary()
		return 1

	hotkey(mob/user, var/key)
		if (key == "space")
			override_southeast(user)

	override_northeast(mob/user)
		if (piloting != user)
			return
		fire_secondary()
		return 1

	override_northwest(mob/user)
		if (piloting != user)
			return
		walk(src, 0)
		flying = 0
		return 1*/

	attack_hand(mob/user)
		if (!user.ckey) // how does this happen?
			return
		if (piloting)
			return
		if (!owner)
			if (user.ckey in colosseum_controller.pods_claimed)
				boutput(user, "<span class='alert'>You already own a colosseum putt you greedy fuck.</span>")
				return
			else
				user.set_loc(src)
				boutput(user, "<span class='notice'>You claim the Colosseum Putt. Get ready to fight!</span>")
				colosseum_controller.pods_claimed += user.ckey
				colosseum_controller.pods_claimed[user.ckey] = user
				owner = user.ckey
				var/mob/living/carbon/human/virtual/V = user
				if (istype(V) && V.body)
					name = V.body.real_name
				else
					name = V.real_name
				piloting = user
				cam.c_tag = "[initial(name)] ([name])"
				on_board(user)
		else if (owner == user.ckey)
			boutput(user, "<span class='notice'>You board your Colosseum Putt.</span>")
			user.set_loc(src)
			piloting = user
			on_board(user)
		else
			boutput(user, "<span class='alert'>This pod is claimed by somebody else.</span>")

	Click(location, control, params)
		if (!may_exit)
			return
		if (usr in src.contents)
			usr.set_loc(src.loc)
			boutput(usr, "<span class='notice'>You exit the Colosseum Putt.</span>")
			piloting = null
			on_exit(usr)
	/*
	relaymove(mob/user as mob, direction)
		if (user.stat)
			return

		if ((user in src) && (user == piloting))
			src.facing = direction
			if (src.dir == direction)
				if(flying == turn(src.dir,180))
					walk(src, 0)
					flying = 0
				else
					walk(src, src.dir, speed)
					flying = src.dir
			else
				src.dir = direction

	*/
	proc/broadcast(var/message)
		radio.hear_talk(piloting, message)

	proc/on_board(var/mob/M)
		update_indicators(INDICATOR_ALL)
		add_indicators(M)
		may_exit = 0
		SPAWN_DBG(1 SECOND)
			may_exit = 1

	proc/on_exit(var/mob/M)
		M.client.view = M.client.reset_view()
		remove_indicators(M)

	client_login(var/mob/user)
		update_indicators(INDICATOR_ALL)
		add_indicators(user)

	proc/add_indicators(var/mob/M)
		p_indicator.add_to(M)
		s_indicator.add_to(M)
		armor_indicator.add_to(M)
		fireres_indicator.add_to(M)
		shieldgen_indicator.add_to(M)
		health_bar.add_to(M)
		shotcount_indicator.add_to(M)
		shotdamage_indicator.add_to(M)
		if (M.client)
			M.client.screen += help

	proc/update_indicators(var/ind_flags = 127)
		if (ind_flags & INDICATOR_PRIMARY)
			p_indicator.assume_weapon(primary)
		if (ind_flags & INDICATOR_SECONDARY)
			s_indicator.assume_weapon(secondary)
		if (ind_flags & INDICATOR_HEALTH)
			update_health_overlay()
		if (ind_flags & INDICATOR_ARMOR)
			armor_indicator.set_value(armor)
		if (ind_flags & INDICATOR_FIRERES)
			fireres_indicator.set_value(fireres)
		if (ind_flags & INDICATOR_SHIELDGEN)
			shieldgen_indicator.set_value(shield_regen)
		if (ind_flags & INDICATOR_SHOTCOUNT)
			shotcount_indicator.set_value(simple.count)
		if (ind_flags & INDICATOR_SHOTDAMAGE)
			shotdamage_indicator.set_value(simple.power)

	proc/remove_indicators(var/mob/M)
		p_indicator.remove_from(M)
		s_indicator.remove_from(M)
		armor_indicator.remove_from(M)
		fireres_indicator.remove_from(M)
		shieldgen_indicator.remove_from(M)
		health_bar.remove_from(M)
		shotcount_indicator.remove_from(M)
		shotdamage_indicator.remove_from(M)
		if (M.client)
			M.client.screen -= help

	proc/message_pilot(var/message, var/type = 0)
		if (piloting)
			switch (type)
				if (0)
					boutput(piloting, "<span class='notice'>[message]</span>")
				if (1)
					boutput(piloting, "<span class='alert'><b>[message]</b></span>")
				else
					boutput(piloting, message)

	proc/activate_system(var/datum/colosseumSystem/S)
		if (S.slot)
			if (!secondary || secondary.type != S.type)
				secondary = S
			else
				secondary.ammo += S.ammo
			update_indicators(INDICATOR_SECONDARY)
		else
			if (!primary || primary.type != S.type)
				primary = S
			else
				primary.ammo += S.ammo
			update_indicators(INDICATOR_PRIMARY)

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		// set return value to default
		. = ..(NewLoc,Dir,step_x,step_y)

		if (flying && facing != flying)
			dir = facing

	proc/update_shield()
		if (has_overlays & OVERLAY_SHIELD)
			if (!shield || invincible)
				overlays -= shield_overlay
				has_overlays &= ~OVERLAY_SHIELD
		if (has_overlays & OVERLAY_IRON_CURTAIN && !invincible)
			overlays -= invincible_overlay
			has_overlays &= ~OVERLAY_IRON_CURTAIN
		if (invincible && !(has_overlays & OVERLAY_IRON_CURTAIN))
			overlays += invincible_overlay
			has_overlays |= OVERLAY_IRON_CURTAIN
		if (!invincible && shield && !(has_overlays & OVERLAY_SHIELD))
			overlays += shield_overlay
			has_overlays |= OVERLAY_SHIELD

	bullet_act(var/obj/projectile/P)
		if (dying)
			return
		if(P.shooter == src)
			return
		if (!P.proj_data)
			return
		log_shot(P, src)

		if(src.material) src.material.triggerOnBullet(src, src, P)

		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		var/atype = 0
		var/damtype = 0
		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				damage /= 2
			if(D_ENERGY)
				damage /= 1.7
				atype = 1
				damtype = 1
			if(D_SLASHING)
				damage /= 3
			if(D_BURNING)
				if(src.material)
					src.material.triggerTemp(src, 5000)
				damage /= 2
				damtype = 1
		damage *= rand(75, 125) * 0.01
		take_damage(damage, atype, damtype)

	// damtype 0: brute, 1: fire, 2: mixed, attack type 0: kinetic, 1: energy, 2: mixed
	proc/take_damage(var/damage, var/atype, var/damtype)
		if (invincible)
			return
		if (shield)
			var/shield_damage = atype ? damage : (damage / 2)
			if (shield < shield_damage)
				shield_damage -= shield
				shield = 0
				if (!atype)
					damage = shield_damage * 2
			else
				shield -= shield_damage
				damage = 0
		if (damage)
			if (damtype == 2)
				var/d1 = damage / 2
				var/d2 = damage - d1
				d1 -= fire_sqrt / 2
				d2 -= armor_sqrt / 2

			else
				var/reduction = damtype ? fire_sqrt : armor_sqrt
				damage -= reduction
				if (atype == 1)
					damage /= 2
				health -= damage
		on_damage()
		update_health()
		update_shield()
		update_indicators(INDICATOR_HEALTH)

	ex_act(var/severity)
		var/actual_severity = max(min(4 - severity, 3), 1)
		var/multiplier = actual_severity * actual_severity
		var/damage = rand(25, 75) * 0.1 * multiplier
		take_damage(damage, 2, 2)

	meteorhit()
		var/damage = rand(20, 40)
		take_damage(damage, 2, 2)

	proc/do_sound(var/sound/S)
		playsound(src, S, 50, 1)
		if (piloting)
			piloting << S

	proc/update_health()
		if(health <= 0)
			die_now()
		else if(health < 25 && !shield)
			if(!on_fire)
				particleMaster.SpawnSystem(new /datum/particleSystem/areaSmoke("#CCCCCC", 50, src))
				on_fire = 1
				src.overlays += fire_overlay
				message_pilot("The cabin bursts into flames!", 1)
				do_sound(sound('sound/machines/engine_alert1.ogg'))
		else if (on_fire && health > 25)
			on_fire = 0
			overlays -= fire_overlay

	proc/die_now()
		if(dying)
			return
		dying = 1
		SPAWN_DBG(1 DECI SECOND)
			src.visible_message("<b>[src] is breaking apart!</b>")
			new /obj/effects/explosion (src.loc)
			var/sound/expl_sound = sound('sound/effects/Explosion1.ogg')
			do_sound(expl_sound)
			sleep(3 SECONDS)
			if (health > 0)
				dying = 0
				return
			message_pilot("Everything is on fire!", 1)
			if (piloting)
				piloting.update_burning(35)
			do_sound(sound('sound/machines/engine_alert1.ogg'))
			sleep(2.5 SECONDS)
			if (health > 0)
				dying = 0
				return
			do_sound(sound('sound/machines/pod_alarm.ogg'))
			do_sound(expl_sound)
			sleep(1.5 SECONDS)
			if (health > 0)
				dying = 0
				return
			do_sound(expl_sound)
			if (piloting)
				var/turf/Q = src.loc
				message_pilot("You are ejected from the pod!", 1)
				var/mob/M = piloting
				remove_indicators(piloting)
				piloting = null
				M.set_loc(Q)
				SPAWN_DBG(0.2 SECONDS)
					var/dx = rand(-10, 10)
					var/dy = rand(-10, 10)
					var/turf/T = locate(Q.x + dx, Q.y + dy, Q.z)
					if (T && M)
						M.throw_at(T, 10, 2)
			sleep(0.2 SECONDS)
			var/turf/T = get_turf(src.loc)
			if(T)
				src.visible_message("<b>[src] explodes!</b>")
				explosion_new(src, T, 5)
			for(T in range(src,1))
				make_cleanable(/obj/decal/cleanable/machine_debris, T)
				var/obj/decal/cleanable/machine_debris/C = unpool(/obj/decal/cleanable/machine_debris)
				C.setup(T)

			qdel(src)

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (isweldingtool(W))
			if (health >= max_health)
				boutput(user, "<span class='alert'>That putt is already at full health!</span>")
				return
			if (W:try_weld(user, 1))
				visible_message("<span class='notice'><b>[user]</b> repairs some dents on [src]!</span>")
				message_pilot("<b>[user]</b> repairs some dents on [src]!")
				repair_by(10)

	proc/add_armor(var/value)
		armor += value
		if (armor > 0)
			armor_sqrt = sqrt(armor)
		else
			armor_sqrt = 0
		update_indicators(INDICATOR_ARMOR)

	proc/add_fireres(var/value)
		fireres += value
		if (fireres > 0)
			fire_sqrt = sqrt(fireres)
		else
			fire_sqrt = 0
		update_indicators(INDICATOR_FIRERES)

	proc/add_shield_regen(var/amount)
		shield_regen += amount
		update_indicators(INDICATOR_SHIELDGEN)

	proc/repair_by(var/amount)
		health = min(health + amount, max_health)
		update_health()
		update_indicators(INDICATOR_HEALTH)

	proc/regenerate_shield(var/amount)
		shield = min(shield + amount, max_shield)
		update_indicators(INDICATOR_HEALTH)

	damage_corrosive(var/amount)
		take_damage(amount * 0.7, 2, 2)

/obj/colosseum_powerup
	name = "Powerup"
	desc = "Cross this with your vehicle to pick it up and boost your power!"
	icon = 'icons/obj/colosseum.dmi'
	New(var/L, var/is_template = 0)
		..()

		if (!is_template)
			SPAWN_DBG(rand(150, 300))
				icon = null
				qdel(src)

	system
		var/datum/colosseumSystem/system

		New(var/L, var/is_template, var/systemType)
			..()
			if (!systemType)
				systemType = pick(typesof(/datum/colosseumSystem) - list(/datum/colosseumSystem, /datum/colosseumSystem/primary, /datum/colosseumSystem/secondary, /datum/colosseumSystem/secondary/projectile))

			system = new systemType()
			overlays += image(system.icon, system.icon_state)
			if (system.slot)
				icon_state = "powerup_secondary"
			else
				icon_state = "powerup_primary"

		Crossed(var/atom/A)
			if (disposed)
				return
			if (istype(A, /obj/machinery/colosseum_putt))
				var/obj/machinery/colosseum_putt/P = A
				P.activate_system(src.system)
				P.message_pilot("You picked up a [system] [system.slot ? "secondary" : "primary"] weapon.")
				icon = null
				qdel(src)

		clone()
			var/obj/colosseum_powerup/system/S = ..()
			S.system = new src.system.type()
			S.overlays.len = 0
			S.overlays += image(S.system.icon, S.system.icon_state)
			return S

	stat
		var/rarity_class = 1
		var/amount = 1
		icon_state = "powerup_stat"
		var/stat_name
		var/stat_icon = 'icons/obj/colosseum.dmi'
		var/stat_icon_state

		New()
			..()
			overlays += image(stat_icon, stat_icon_state)

		proc/activate(var/obj/machinery/colosseum_putt/C)
		proc/check_conditions(var/obj/machinery/colosseum_putt/C)
			return 1

		Crossed(var/atom/A)
			if (disposed)
				return
			if (istype(A, /obj/machinery/colosseum_putt))
				var/obj/machinery/colosseum_putt/P = A
				if (check_conditions(P))
					activate(P)
					P.message_pilot("You picked up \a [stat_name] kit.")
					icon = null
					qdel(src)

		repair
			rarity_class = 2
			stat_name = "repair"
			stat_icon_state = "repair"
			amount = 25

			check_conditions(var/obj/machinery/colosseum_putt/C)
				return C.health < C.max_health

			activate(var/obj/machinery/colosseum_putt/C)
				C.repair_by(amount)

		shield_charge
			stat_name = "shield recharge"
			stat_icon_state = "shield_recharge"
			amount = 30

			check_conditions(var/obj/machinery/colosseum_putt/C)
				return C.shield < C.max_shield

			activate(var/obj/machinery/colosseum_putt/C)
				C.regenerate_shield(amount)

		shield_generator
			rarity_class = 2
			stat_name = "shield generator"
			stat_icon = "shield_genrate"
			amount = 1

			activate(var/obj/machinery/colosseum_putt/C)
				C.add_shield_regen(amount)

		shield_capacity
			rarity_class = 1
			stat_name = "shield capacity"
			stat_icon = "shield_capacity"
			amount = 25

			activate(var/obj/machinery/colosseum_putt/C)
				C.max_shield += amount
				C.update_indicators(INDICATOR_HEALTH)

		armor
			stat_name = "armor"
			stat_icon_state = "armor"
			amount = 1

			activate(var/obj/machinery/colosseum_putt/C)
				C.add_armor(amount)

		fireres
			stat_name = "fire resistance"
			stat_icon_state = "fireres"
			amount = 1

			activate(var/obj/machinery/colosseum_putt/C)
				C.add_fireres(amount)

		iron_curtain
			stat_name = "iron curtain"
			amount = 1
			stat_icon_state = "iron_curtain_pickup"

			check_conditions(var/obj/machinery/colosseum_putt/C)
				return !C.invincible

			activate(var/obj/machinery/colosseum_putt/C)
				. = ..()
				C.invincible = ticker.round_elapsed_ticks + 50
				C.update_shield()

		phaser_damage
			stat_name = "phaser damage"
			amount = 2
			stat_icon_state = "default_weapon_damage"
			rarity_class = 1

			activate(var/obj/machinery/colosseum_putt/C)
				. = ..()
				C.simple.power += amount
				C.update_indicators(INDICATOR_SHOTDAMAGE)
				C.simple.update_icon()

			t2
				amount = 4
				rarity_class = 2
				stat_icon_state = "default_weapon_damage_two"

		phaser_count
			stat_name = "phaser shot count"
			amount = 1
			stat_icon_state = "default_weapon_count"
			rarity_class = 2

			check_conditions(var/obj/machinery/colosseum_putt/C)
				return C.simple.count < 10

			activate(var/obj/machinery/colosseum_putt/C)
				. = ..()
				C.simple.count = min(C.simple.count + amount, 10)
				C.update_indicators(INDICATOR_SHOTCOUNT)

#undef OVERLAY_IRON_CURTAIN
#undef OVERLAY_SHIELD

#undef INDICATOR_SHOTDAMAGE
#undef INDICATOR_SHOTCOUNT
#undef INDICATOR_PRIMARY
#undef INDICATOR_SECONDARY
#undef INDICATOR_HEALTH
#undef INDICATOR_ARMOR
#undef INDICATOR_FIRERES
#undef INDICATOR_SHIELDGEN
#undef INDICATOR_ALL

/obj/colosseum_radio
	name = "Colosseum Intercom"
	icon = 'icons/effects/VR.dmi'
	icon_state = "intercom"
	desc = "A special virtual radio that immediately distributes messages to all virtual hearers."
	anchored = 1
	density = 0
	opacity = 0

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	hear_talk(var/mob/living/M, var/messages)
		if (!istype(M))
			return
		var/rendered = get_colosseum_message(M.real_name, messages[1])
		for (var/X in by_type[/obj/colosseum_radio])
			var/obj/colosseum_radio/R = X
			R.receive(rendered)

	proc/receive(var/rendered)
		if (isturf(loc))
			for (var/mob/M in hearers(7, src))
				boutput(M, rendered)
		else if (istype(loc, /obj/machinery/colosseum_putt))
			var/obj/machinery/colosseum_putt/C = loc
			C.message_pilot(rendered, 2)

/obj/colosseum_mine
	name = "Mine"
	desc = "You should probably not ram this."
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/obj/colosseum.dmi'
	icon_state = "mine"

	proc/mine_effect(var/atom/A)

	explosive
		mine_effect(var/atom/A)
			explosion_new(src, get_turf(src), 5)

	Crossed(var/atom/A)
		if (disposed)
			return
		if (istype(A, /obj/machinery/colosseum_putt) || istype(A, /obj/critter/gunbot/drone))
			mine_effect(A)
			qdel(src)
