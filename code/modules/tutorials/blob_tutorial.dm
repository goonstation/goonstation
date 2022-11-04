/area/blob/tutorial_zone
	name = "Blob Tutorial Zone"
	icon_state = "yellow"
	sound_group = "blob1"
	dont_log_combat = TRUE

/datum/tutorial_base/blob
	name = "Blob tutorial"
	var/mob/living/intangible/blob_overmind/bowner = null
	var/turf/initial_turf = null
	var/datum/allocated_region/region

	New()
		..()
		AddBlobSteps(src)
		src.region = get_singleton(/datum/mapPrefab/allocated/blob_tutorial).load()
		logTheThing(LOG_DEBUG, usr, "<b>Blob Tutorial</b>: Got bottom left corner [log_loc(src.region.bottom_left)]")
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_START])
			if(region.turf_in_region(T))
				initial_turf = T
				break
		if (!initial_turf)
			logTheThing(LOG_DEBUG, usr, "<b>Blob Tutorial</b>: Tutorial failed setup: missing landmark.")
			throw EXCEPTION("Okay who removed the goddamn blob tutorial landmark")

	Start()
		if (!initial_turf)
			logTheThing(LOG_DEBUG, usr, "<b>Blob Tutorial</b>: Failed setup.")
			boutput(usr, "<span class='alert'><b>Error setting up tutorial!</b></span>")
			qdel(src)
			return
		if (..())
			bowner = owner
			bowner.sight &= ~SEE_TURFS
			bowner.sight &= ~SEE_MOBS
			bowner.sight &= ~SEE_OBJS
			owner.set_loc(initial_turf)
			bowner.add_ability(/datum/blob_ability/tutorial_exit)

	Finish()
		if (..())
			bowner.set_loc(pick_landmark(LANDMARK_OBSERVER))
			bowner.bio_points_max_bonus = initial(bowner.bio_points_max_bonus)
			bowner.started = 0
			for (var/obj/blob/B in bowner.blobs)
				qdel(B)
			bowner.evo_points = initial(bowner.evo_points)
			bowner.next_evo_point = initial(bowner.next_evo_point)
			bowner.gen_rate_bonus = initial(bowner.gen_rate_bonus)
			bowner.abilities = list()
			bowner.upgrades = list()
			bowner.available_upgrades = list()
			bowner.add_ability(/datum/blob_ability/plant_nucleus)
			bowner.add_ability(/datum/blob_ability/set_color)
			bowner.add_ability(/datum/blob_ability/tutorial)
			bowner.add_ability(/datum/blob_ability/help)
			bowner.shift_power = null
			bowner.ctrl_power = null
			bowner.alt_power = null
			bowner.update_buttons()
			bowner.bio_points = initial(bowner.bio_points)
			bowner.bio_points_max = initial(bowner.bio_points_max)
			bowner.lipids = list()
			bowner.nuclei = list()
			bowner.tutorial = null
			bowner.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
			bowner.starter_buff = 1
			qdel(src)

	disposing()
		qdel(src.region)
		landmarks[LANDMARK_TUTORIAL_START] -= src.initial_turf
		..()

/datum/tutorialStep/blob
	name = "Blob tutorial step"
	instructions = "If you see this, tell a coder!!!11"
	var/static/image/marker = null
	var/finished = 0

	New()
		..()
		if (!marker)
			marker = image('icons/effects/VR.dmi', "lightning_marker")
			marker.filters= filter(type="outline", size=1)

	SetUp()
		..()
		finished = 0

	deploy
		name = "Deploying"
		instructions = "If at any point this tutorial glitches up and leaves in a stuck state, use the emergency tutorial stop verb. Choose a suitable area to place your first tile. This is the most crucial choice you will make during your time as a blob. Do not choose areas with early game or constant traffic! To deploy, use your deploy button in the top-left corner. Deploy your blob onto the marked tile to proceed."
		var/turf/must_deploy = null

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			must_deploy = locate(MT.initial_turf.x, MT.initial_turf.y + 1, MT.initial_turf.z)
			must_deploy.UpdateOverlays(marker,"marker")

		PerformAction(var/action, var/context)
			if (action == "deploy" && context == must_deploy)
				finished = 1
				return 1
			if (action == "move")
				return 1
			return 0

		TearDown()
			must_deploy.UpdateOverlays(null,"marker")

		MayAdvance()
			return finished

	spread
		name = "Spreading Out"
		instructions = "While you are small, you are very vulnerable and suffer many penalties. In normal play, your first nucleus will instantly spawn a small amount of blob tiles around itself. In order to spread, use the newly gained button in the top left corner of your screen. Spread to the four marked turfs to continue."
		var/list/must_spread_to = list()

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/turf/T = locate(tx, ty, MT.initial_turf.z)
			for (var/dir in cardinal)
				var/turf/Q = get_step(T, dir)
				Q.UpdateOverlays(marker,"marker")
				must_spread_to += Q

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action != "spread")
				return 0
			if (!(context in must_spread_to))
				return 0
			var/turf/T = context
			T.UpdateOverlays(null,"marker")
			must_spread_to -= context
			return 1

		MayAdvance()
			return must_spread_to.len == 0

	attack
		name = "Destroying obstacles"
		instructions = "You appear to have an inconveniently placed object next to you! While you cannot reliably tear down walls initially, you can get rid of a myriad of objects: doors, fuel tanks, computers. You can attack by using the attack button, the second button from the left by default. Break the various objects around your blob to proceed."
		var/obj/storage/closet/closet
		var/obj/machinery/door/airlock/external/door
		var/obj/storage/crate/crate
		var/obj/window/window

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/turf/T = locate(tx, ty, MT.initial_turf.z)

			closet = new(get_step(get_step(T, NORTH), NORTH))
			door = new(get_step(get_step(T, WEST), WEST))
			crate = new(get_step(get_step(T, EAST), EAST))
			window = new(get_step(get_step(T, SOUTH), SOUTH))

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action != "attack")
				return 0
			var/allowed = 0
			if (crate)
				if (context == get_turf(crate))
					allowed = 1
			if (door)
				if (context == get_turf(door))
					allowed = 1
			if (closet)
				if (context == get_turf(closet))
					allowed = 1
			if (window)
				if (context == get_turf(window))
					allowed = 1
			if (allowed)
				return 1
			return 0

		MayAdvance()
			var/destroyed = 0
			if (!closet)
				destroyed++
			else if (closet.disposed)
				destroyed++
			if (!window)
				destroyed++
			else if (window.disposed)
				destroyed++
			if (!door)
				destroyed++
			else if (door.disposed)
				destroyed++
			if (!crate)
				destroyed++
			else if (crate.disposed)
				destroyed++
			if (destroyed >= 3)
				return 1
			return 0

		TearDown()
			qdel(closet)
			qdel(window)
			qdel(door)
			qdel(crate)

	spread2
		name = "Continuing on"
		instructions = "Spread to the marked turf to continue."
		var/spread_x
		var/spread_max_y
		var/spread_min_y
		var/turf/TT
		finished = 0

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/turf/T = locate(tx, ty, MT.initial_turf.z)
			spread_x = tx
			spread_min_y = ty

			for (var/i = 1, i <= 5, i++)
				T = get_step(T, NORTH)
			spread_max_y = T.y

			T.UpdateOverlays(marker,"marker")
			TT = T

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action != "spread")
				return 0
			var/turf/T = context
			if (T.x == spread_x && T.y >= spread_min_y && T.y <= spread_max_y)
				if (T == TT)
					finished = 1
				return 1
			return 0

		TearDown()
			TT.UpdateOverlays(null,"marker")

		MayAdvance()
			return finished

	cutscene
		name = "Protection from Fire"
		instructions = "Oh no! It's a jerk with a flamethrower. Observe the effects of a flamethrower wielding dude on your blob."

		SetUp()
			..()
			SPAWN(0)
				var/datum/tutorial_base/blob/MT = tutorial
				var/tx = MT.initial_turf.x
				var/ty = MT.initial_turf.y + 1
				var/tz = MT.initial_turf.z
				sleep(2 SECONDS)
				var/mob/blob_tutorial_walker/W = new(locate(tx + 5, ty + 8, tz))
				walk_to(W, locate(tx, ty + 8, tz), 0, 8)
				sleep(5 SECONDS)
				W.set_dir(2)
				sleep(2 SECONDS)
				W.sprayAt(locate(tx, ty + 5, tz), 8)
				sleep(4 SECONDS)
				W.sprayAt(locate(tx, ty + 5, tz), 8)
				sleep(4 SECONDS)
				gibs(get_turf(W), list(), list())
				qdel(W)
				tutorial.Advance()

		PerformAction(var/action, var/context)
			return action == "move"

		MayAdvance()
			return 0

	firewall
		name = "Protection from Fire"
		instructions = "When you are discovered, you will find yourself in a situation where people are using your greatest weakness against you: fire. You are especially vulnerable to flamethrowers, capable of tearing massive chunks out of you in mere moments. Spread up to the marked tile and place a fire resistant membrane there after spreading on it."
		var/spread_x
		var/spread_max_y
		var/spread_min_y
		var/turf/TT
		finished = 0

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/turf/T = locate(tx, ty, MT.initial_turf.z)
			spread_x = tx
			spread_min_y = ty

			for (var/i = 1, i <= 5, i++)
				T = get_step(T, NORTH)
			spread_max_y = T.y

			MT.bowner.bio_points_max_bonus = 50
			MT.bowner.gen_rate_bonus = 9

			T.UpdateOverlays(marker,"marker")
			TT = T

		TearDown()
			TT.UpdateOverlays(null,"marker")

		PerformAction(var/action, var/context)
			if (action == "firewall" && context == TT)
				finished = 1
				return 1
			if (action == "move")
				return 1
			if (action == "spread")
				var/turf/T = context
				if (T.x == spread_x && T.y >= spread_min_y && T.y <= spread_max_y)
					return 1
			return 0

		MayAdvance()
			return finished

	cutscene2
		name = "Protection from Fire"
		instructions = "Observe as the fire resistant membrane protects you from the effects of a flamethrower."

		SetUp()
			..()
			SPAWN(0)
				var/datum/tutorial_base/blob/MT = tutorial
				var/tx = MT.initial_turf.x
				var/ty = MT.initial_turf.y + 1
				var/tz = MT.initial_turf.z
				sleep(2 SECONDS)
				var/mob/blob_tutorial_walker/W = new(locate(tx + 5, ty + 8, tz))
				walk_to(W, locate(tx, ty + 8, tz), 0, 8)
				sleep(5 SECONDS)
				W.set_dir(2)
				sleep(2 SECONDS)
				W.sprayAt(locate(tx, ty + 5, tz), 8)
				sleep(4 SECONDS)
				W.sprayAt(locate(tx, ty + 5, tz), 8)
				sleep(4 SECONDS)
				gibs(get_turf(W), list(), list())
				qdel(W)
				tutorial.Advance()

		PerformAction(var/action, var/context)
			return action == "move"

		MayAdvance()
			return 0

	ribosomes
		name = "Ribosomes"
		instructions = "Your most valuable assets are the ribosomes. Ribosomes increase your biopoint generation, allowing you do do more things, faster. Place a ribosome on the marked blob tile to proceed."
		var/turf/target
		finished = 0

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/tz = MT.initial_turf.z
			target = locate(tx, ty - 1, tz)
			var/obj/blob/B = locate() in target
			B.UpdateOverlays(marker,"marker")

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action == "ribosome" && context == target)
				finished = 1
				return 1
			return 0

		MayAdvance()
			return finished

	clickmove
		name = "Click moving"
		instructions = "Moving around with arrow keys or WASD is vastly inefficient when you need to cover large distances at once. You can also move around by right-clicking a tile, however. Right-click the marked tile to move there and proceed."
		var/turf/target
		finished = 0

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/tz = MT.initial_turf.z
			target = locate(tx + 3, ty + 3, tz)
			target.UpdateOverlays(marker,"marker")

		PerformAction(var/action, var/context)
			var/datum/tutorial_base/blob/MT = tutorial
			if (!MT.region.turf_in_region(get_turf(context)) || !istype(context, /turf/simulated/floor)) //Stop the player from suicide by cordon
				return 0
			else if (action == "clickmove" && context == target)
				finished = 1
				return 1
			return 1 // bad but prevents chat spam which leads to crashes

		TearDown()
			target.UpdateOverlays(null,"marker")

		MayAdvance()
			return finished

	hotkeys
		name = "Repair and Hotkeying"
		instructions = "In hot situations, you will be unable to move around quickly and perform actions at the same time. This is where hotkeying comes in. You may assign up to three abilities to three different hotkey: CTRL+Click, ALT+Click and SHIFT+Click. This lets you perform stuff on the tile you click on! To assign a hotkey, CTRL/ALT/SHIFT-click an ability. Let's try this: assign a hotkey to the repair ability, and repair your damaged cells without moving."
		var/turf/target

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/tz = MT.initial_turf.z
			target = locate(tx, ty, tz)
			var/obj/blob/B = locate() in target
			B.take_damage(5, 1, "brute")
			B.UpdateOverlays(marker,"marker")

		PerformAction(var/action, var/context)
			if (action == "repair" && context == target)
				finished = 1
				return 1
			return 0

		TearDown()
			var/obj/blob/B = locate() in target
			B.UpdateOverlays(null,"marker")

		MayAdvance()
			return finished

	upgrades
		name = "Evolution"
		instructions = "In the beginning, the tools at your disposal are lacking. There are several additional pieces you may evolve. You have been granted free evo points. Use these evo points to unlock the Slime Launcher, the Reflective Membrane, and the Devour Item abilityin the bottom bar."

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			MT.bowner.evo_points = 500

		PerformAction(var/action, var/context)
			if (action == "upgrade-digest" || action == "upgrade-reflective" || action == "upgrade-launcher" || action == "upgrade-replicator")
				return 1
			return 0

		PerformSilentAction(var/action, var/context)
			tutorial.CheckAdvance()
			return 0

		TearDown()
			var/datum/tutorial_base/blob/MT = tutorial
			MT.bowner.evo_points = 0

		MayAdvance()
			var/datum/tutorial_base/blob/MT = tutorial
			return MT.bowner.has_upgrade(/datum/blob_upgrade/launcher) && MT.bowner.has_upgrade(/datum/blob_upgrade/devour_item) && MT.bowner.has_upgrade(/datum/blob_upgrade/reflective)

	digestation
		name = "Getting rid of items"
		instructions = "Now that you can get rid of items, let's see how it works! Some chump left an incendiary grenade right next to one of your blob tiles. Simply use the devour item ability on that tile to destroy it. You may click-drag an item to an adjacent blob piece to devour it. Destroy the grenade to proceed."
		var/obj/item/chem_grenade/incendiary/I

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x + 1
			var/ty = MT.initial_turf.y + 2
			var/tz = MT.initial_turf.z
			I = new(locate(tx, ty, tz))

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action == "devour" && (context == I || context == get_turf(I)))
				return 1

		PerformSilentAction(var/action, var/context)
			tutorial.CheckAdvance()
			return 0

		MayAdvance()
			if (!I)
				return 1
			if (I.disposed)
				return 1
			return 0

	launcher
		name = "Slime Launcher"
		instructions = "Let's turn our attention to a more immediate threat. An assistant has wandered into your vicinity, but isn't close enough to be attacked. Slime launchers can bridge this gap by continuously pummeling nearby humans at the cost of your bio points. Build a slime launcher on the marked blob tile and watch as it slowly kills the assistant."
		var/mob/living/carbon/human/normal/assistant/H
		var/obj/blob/target

		SetUp()
			..()
			var/datum/tutorial_base/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 3
			var/tz = MT.initial_turf.z
			var/turf/T = locate(tx, ty, tz)
			target = locate() in T
			target.UpdateOverlays(marker,"marker")
			tx += 3
			H = new(locate(tx, ty, tz))

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (!target)
				return
			if (action == "launcher" && context == get_turf(target))
				return 1

		TearDown()
			target.UpdateOverlays(null,"marker")
			if (H)
				H.gib()

		PerformSilentAction(var/action, var/context)
			if (action == "blob-life" && istype(context, /obj/blob/launcher))
				return 1
			return 0

		MayAdvance()
			if (!H)
				return 1
			if (isdead(H))
				return 1
			if (H.health < 50)
				return 1



	finished
		name = "Finish up"
		instructions = "Congratulations! You have completed the basic blob tutorial. You will now be returned to the station."

		SetUp()
			..()
			sleep(5 SECONDS)
			tutorial.Advance()

proc/AddBlobSteps(var/datum/tutorial_base/blob/T)
	T.AddStep(new /datum/tutorialStep/blob/deploy)
	T.AddStep(new /datum/tutorialStep/blob/spread)
	T.AddStep(new /datum/tutorialStep/blob/attack)
	T.AddStep(new /datum/tutorialStep/blob/spread2)
	T.AddStep(new /datum/tutorialStep/blob/cutscene)
	T.AddStep(new /datum/tutorialStep/blob/firewall)
	T.AddStep(new /datum/tutorialStep/blob/cutscene2)
	T.AddStep(new /datum/tutorialStep/blob/clickmove)
	T.AddStep(new /datum/tutorialStep/blob/hotkeys)
	T.AddStep(new /datum/tutorialStep/blob/upgrades)
	T.AddStep(new /datum/tutorialStep/blob/digestation)
	T.AddStep(new /datum/tutorialStep/blob/launcher)
	T.AddStep(new /datum/tutorialStep/blob/finished)

/mob/blob_tutorial_walker
	name = "Pubs McFlamer"
	desc = "Some dork with a flamethrower."
	icon = 'icons/mob/human.dmi'
	icon_state = "body_f"
	var/obj/item/gun/flamethrower/assembled/loaded/L = new

	New()
		..()
		overlays += image('icons/mob/inhand/hand_guns.dmi', "flamethrower1-R")
		L.set_loc(src)
		L.lit = 1

	proc/sprayAt(var/turf/T)
		L.shoot(T, src.loc, src)

	disposing()
		..()
		qdel(L)

/mob/living/intangible/blob_overmind/verb/help_my_tutorial_is_being_a_massive_shit()
	set name = "EMERGENCY TUTORIAL STOP"
	if (!tutorial)
		boutput(src, "<span class='alert'>You're not in a tutorial, doofus. It's real. IT'S ALL REAL.</span>")
		return
	src.tutorial.Finish()
	src.tutorial = null
