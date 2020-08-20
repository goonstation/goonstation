/area/blob/tutorial_zone_1
	name = "Blob Tutorial Zone 1"
	icon_state = "yellow"
	sound_group = "blob1"

/area/blob/tutorial_zone_2
	name = "Blob Tutorial Zone 2"
	icon_state = "green"
	sound_group = "blob2"

/area/blob/tutorial_zone_3
	name = "Blob Tutorial Zone 3"
	icon_state = "blue"
	sound_group = "blob3"

var/global/list/blob_tutorial_areas = list(/area/blob/tutorial_zone_1, /area/blob/tutorial_zone_2, /area/blob/tutorial_zone_3)

/datum/tutorial/blob
	name = "Blob tutorial"
	var/tutorial_area_type = null
	var/area/tutorial_area = null
	var/mob/living/intangible/blob_overmind/bowner = null
	var/turf/initial_turf = null

	New()
		..()
		AddBlobSteps(src)
		if (blob_tutorial_areas.len)
			tutorial_area_type = pick(blob_tutorial_areas)
			blob_tutorial_areas -= tutorial_area_type
			tutorial_area = locate(tutorial_area_type) in world
			logTheThing("debug", usr, null, "<b>Blob Tutorial</b>: Got area [tutorial_area]")
			if (tutorial_area)
				// var/obj/landmark/tutorial_start/L = locate() in tutorial_area
				// GODDAMNIT LUMMOX
				var/obj/landmark/tutorial_start/L = null
				for (var/obj/landmark/tutorial_start/temp in tutorial_area)
					L = temp
					break
				if (!L)
					logTheThing("debug", usr, null, "<b>Blob Tutorial</b>: Tutorial failed setup: missing landmark.")
					throw EXCEPTION("Okay who removed the goddamn blob tutorial landmark")
				initial_turf = get_turf(L)
				if (!initial_turf)
					logTheThing("debug", usr, null, "<b>Blob Tutorial</b>: Tutorial failed setup: [L], [initial_turf].")

	Start()
		if (!initial_turf)
			logTheThing("debug", usr, null, "<b>Blob Tutorial</b>: Failed setup.")
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
			bowner.set_loc(pick(observer_start))
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

	disposing()
		if (tutorial_area_type)
			blob_tutorial_areas += tutorial_area_type
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

	SetUp()
		..()
		finished = 0

	deploy
		name = "Deploying"
		instructions = "If at any point this tutorial glitches up and leaves in a stuck state, use the emergency tutorial stop verb. Choose a suitable area to place your first tile. This is the most crucial choice you will make during your time as a blob. Do not choose areas with early game or constant traffic! To deploy, use your deploy button in the top-left corner. Deploy your blob onto the marked tile to proceed."
		var/turf/must_deploy = null

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			must_deploy = locate(MT.initial_turf.x, MT.initial_turf.y + 1, MT.initial_turf.z)
			must_deploy.overlays += marker

		PerformAction(var/action, var/context)
			if (action == "deploy" && context == must_deploy)
				finished = 1
				return 1
			if (action == "move")
				return 1
			return 0

		TearDown()
			must_deploy.overlays.len = 0

		MayAdvance()
			return finished

	spread
		name = "Spreading Out"
		instructions = "While you are small, you are very vulnerable and suffer many penalties. In normal play, your first nucleus will instantly spawn a small amount of blob tiles around itself. In order to spread, use the newly gained button in the top left corner of your screen. Spread to the four marked turfs to continue."
		var/list/must_spread_to = list()

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/turf/T = locate(tx, ty, MT.initial_turf.z)
			for (var/dir in cardinal)
				var/turf/Q = get_step(T, dir)
				Q.overlays += marker
				must_spread_to += Q

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action != "spread")
				return 0
			if (!(context in must_spread_to))
				return 0
			var/turf/T = context
			T.overlays.len = 0
			must_spread_to -= context
			return 1

		MayAdvance()
			return must_spread_to.len == 0

	attack
		name = "Destroying obstacles"
		instructions = "You appear to have an inconveniently placed object next to you! While you cannot reliably tear down walls initially, you can get rid of a myriad of objects: doors, fuel tanks, computers. You can attack by using the attack button, the second button from the left by default. Break the various objects around your blob to proceed."
		var/obj/machinery/door/airlock/external/comp
		var/obj/machinery/door/airlock/external/door
		var/obj/reagent_dispensers/fueltank/tank
		var/obj/window/window

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/turf/T = locate(tx, ty, MT.initial_turf.z)

			comp = new(get_step(get_step(T, NORTH), NORTH))
			door = new(get_step(get_step(T, WEST), WEST))
			tank = new(get_step(get_step(T, EAST), EAST))
			window = new(get_step(get_step(T, SOUTH), SOUTH))

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action != "attack")
				return 0
			var/allowed = 0
			if (tank)
				if (context == get_turf(tank))
					allowed = 1
			if (door)
				if (context == get_turf(door))
					allowed = 1
			if (comp)
				if (context == get_turf(comp))
					allowed = 1
			if (window)
				if (context == get_turf(window))
					allowed = 1
			if (allowed)
				return 1
			return 0

		MayAdvance()
			var/destroyed = 0
			if (!comp)
				destroyed++
			else if (!comp.density || comp.disposed)
				destroyed++
			if (!window)
				destroyed++
			else if (window.disposed)
				destroyed++
			if (!door)
				destroyed++
			else if (door.disposed)
				destroyed++
			if (!tank)
				destroyed++
			else if (tank.disposed)
				destroyed++
			if (destroyed >= 3)
				return 1
			return 0

		TearDown()
			qdel(comp)
			qdel(window)
			qdel(door)
			qdel(tank)

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
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/turf/T = locate(tx, ty, MT.initial_turf.z)
			spread_x = tx
			spread_min_y = ty

			for (var/i = 1, i <= 5, i++)
				T = get_step(T, NORTH)
			spread_max_y = T.y

			T.overlays += marker
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
			TT.overlays.len = 0

		MayAdvance()
			return finished

	cutscene
		name = "Protection from Fire"
		instructions = "Oh no! It's a jerk with a flamethrower. Observe the effects of a flamethrower wielding dude on your blob."

		SetUp()
			..()
			SPAWN_DBG(0)
				var/datum/tutorial/blob/MT = tutorial
				var/tx = MT.initial_turf.x
				var/ty = MT.initial_turf.y + 1
				var/tz = MT.initial_turf.z
				sleep(2 SECONDS)
				var/obj/blob_tutorial_walker/W = new(locate(tx + 5, ty + 8, tz))
				walk_to(W, locate(tx, ty + 8, tz), 0, 8)
				sleep(5 SECONDS)
				W.dir = 2
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
			var/datum/tutorial/blob/MT = tutorial
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

			T.overlays += marker
			TT = T

		TearDown()
			TT.overlays.len = 0

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
			SPAWN_DBG(0)
				var/datum/tutorial/blob/MT = tutorial
				var/tx = MT.initial_turf.x
				var/ty = MT.initial_turf.y + 1
				var/tz = MT.initial_turf.z
				sleep(2 SECONDS)
				var/obj/blob_tutorial_walker/W = new(locate(tx + 5, ty + 8, tz))
				walk_to(W, locate(tx, ty + 8, tz), 0, 8)
				sleep(5 SECONDS)
				W.dir = 2
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
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/tz = MT.initial_turf.z
			target = locate(tx, ty - 1, tz)
			var/obj/blob/B = locate() in target
			B.overlays += marker

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
		instructions = "Moving around with arrow keys or WASD is vastly inefficient when you need to cover large distances at once. You can also move around by clicking a tile, however. Click the marked tile to move there and proceed."
		var/turf/target
		finished = 0

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/tz = MT.initial_turf.z
			target = locate(tx + 3, ty + 3, tz)
			target.overlays += marker

		PerformAction(var/action, var/context)
			if (action == "clickmove" && context == target)
				finished = 1
				return 1
			return 0

		TearDown()
			target.overlays.len = 0

		MayAdvance()
			return finished

	hotkeys
		name = "Repair and Hotkeying"
		instructions = "In hot situations, you will be unable to move around quickly and perform actions at the same time. This is where hotkeying comes in. You may assign up to three abilities to three different hotkey: CTRL+Click, ALT+Click and SHIFT+Click. This lets you perform stuff on the tile you click on! To assign a hotkey, CTRL/ALT/SHIFT-click an ability. Let's try this: assign a hotkey to the repair ability, and repair your damaged cells without moving."
		var/turf/target

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 1
			var/tz = MT.initial_turf.z
			target = locate(tx, ty, tz)
			var/obj/blob/B = locate() in target
			B.take_damage(5, 1, "brute")
			B.overlays += marker

		PerformAction(var/action, var/context)
			if (action == "repair" && context == target)
				finished = 1
				return 1
			return 0

		TearDown()
			var/obj/blob/B = locate() in target
			B.overlays.len = 0

		MayAdvance()
			return finished

	upgrades
		name = "Evolution"
		instructions = "In the beginning, the tools at your disposal are lacking. There are several additional pieces you may evolve. You have been granted free evo points. Use these evo points to unlock the Slime Launcher, the Reflective Membrane, the Devour Item ability, and the Replicator upgrade in the bottom bar. The Replicator upgrade requires the Devour Item ability."

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			MT.bowner.evo_points = 500

		PerformAction(var/action, var/context)
			if (action == "upgrade-digest" || action == "upgrade-reflective" || action == "upgrade-launcher" || action == "upgrade-replicator")
				return 1
			return 0

		PerformSilentAction(var/action, var/context)
			tutorial.CheckAdvance()
			return 0

		TearDown()
			var/datum/tutorial/blob/MT = tutorial
			MT.bowner.evo_points = 0

		MayAdvance()
			var/datum/tutorial/blob/MT = tutorial
			return MT.bowner.has_upgrade(/datum/blob_upgrade/launcher) && MT.bowner.has_upgrade(/datum/blob_upgrade/replicator) && MT.bowner.has_upgrade(/datum/blob_upgrade/devour_item) && MT.bowner.has_upgrade(/datum/blob_upgrade/reflective)

	digestation
		name = "Getting rid of items"
		instructions = "Now that you can get rid of items, let's see how it works! Some chump left an incendiary grenade right next to one of your blob tiles. Simply use the devour item ability on that tile to destroy it. You may click-drag an item to an adjacent blob piece to devour it. Destroy the grenade to proceed."
		var/obj/item/chem_grenade/incendiary/I

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
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
			var/datum/tutorial/blob/MT = tutorial
			if (locate(/obj/blob/deposit) in MT.tutorial_area)
				return 1
			return 0

	deposits
		name = "Reagent deposits"
		instructions = "As an additional bonus, devouring items creates a reagent deposit with all the reagents the item contained. That includes reagents in items inside the item! Reagent deposits can be swapped with any non-special blob piece by clickdragging. Click-drag (and thus move) the reagent deposit onto the marked blob piece to proceed."
		var/obj/blob/B

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x + 1
			var/ty = MT.initial_turf.y + 1
			var/tz = MT.initial_turf.z
			var/turf/T = locate(tx, ty, tz)
			B = locate() in T
			if (istype(B, /obj/blob/deposit))
				T = locate(tx - 2, ty, tz)
				B = locate() in T
			B.overlays += marker

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action == "mousedrop")
				var/list/ctx = context
				var/obj/ctx1 = ctx[1]
				if (ctx[2] == B && ctx1.type == /obj/blob/deposit)
					finished = 1
					return 1
			return 0

		TearDown()
			B.overlays -= marker

		MayAdvance()
			return finished

	replicators
		name = "Replicators"
		instructions = "Replicators are a way to control your reagent flow. When placed upon a reagent deposit, it becomes a replicator for the highest volume reagent in the mix. Then, moving any reagent deposits into the replicator will convert it into a deposit of its own reagent at a cost of bio points. Your objective in this step is to use your reagent deposit to create a replicator."

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action == "replicator")
				var/turf/T = context
				if (locate(/obj/blob/deposit) in T)
					finished = 1
				return 1
			return 0

		MayAdvance()
			return finished

	replication
		name = "Replication"
		instructions = "Now that you have a chlorine trifluoride replicator, you can replicate the reagent as long as you keep the replicator safe. Let's try this: devour the fire extinguisher and send the gained firefighting foam into the replicator by clickdragging it."
		var/obj/item/extinguisher/I

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x + 1
			var/ty = MT.initial_turf.y + 2
			var/tz = MT.initial_turf.z
			I = new(locate(tx, ty, tz))

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action == "devour" && (context == I || context == get_turf(I)))
				return 1
			if (action == "mousedrop")
				var/list/ctx = context
				var/obj/blob/ctx1 = ctx[1]
				if (istype(ctx[2], /obj/blob/deposit/replicator) && ctx1.type == /obj/blob/deposit)
					finished = 1
					return 1
			return 0

		PerformSilentAction(var/action, var/context)
			if (action == "blob-life" && istype(context, /obj/blob/deposit/replicator))
				return 1
			return 0

		MayAdvance()
			return finished

	launcher
		name = "Slime Launcher"
		instructions = "While your replicator is working, let's turn our attention to a more immediate threat. An assistant has wandered into your vicinity, but isn't close enough to be attacked. Slime launchers can bridge this gap by continuously pummeling nearby humans at the cost of your bio points. Build a slime launcher on the marked blob tile and watch as it slowly kills the assistant."
		var/mob/living/carbon/human/normal/assistant/H
		var/obj/blob/target

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x
			var/ty = MT.initial_turf.y + 3
			var/tz = MT.initial_turf.z
			var/turf/T = locate(tx, ty, tz)
			target = locate() in T
			target.overlays += marker
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
			if (H)
				H.gib()

		PerformSilentAction(var/action, var/context)
			if (action == "blob-life" && (istype(context, /obj/blob/deposit/replicator) || istype(context, /obj/blob/launcher)))
				return 1
			return 0

		MayAdvance()
			if (target)
				return 0
			if (!H)
				return 1
			if (isdead(H))
				return 1
			if (H.health < 50)
				return 1


	reagent_launcher
		name = "Firing reagents"
		instructions = "Your replicator should be more or less done by now. To remove the reagents from the replicator, simply click-drag it onto any free blob tile. You may do this mid-replication as well to split the replicated contents. Click-drag the reagents out of the replicator, then click-drag the newly created reagent deposit onto the slime launcher to load it for firing."

		PerformAction(var/action, var/context)
			if (action == "move")
				return 1
			if (action == "mousedrop")
				var/list/ctx = context
				var/obj/blob/ctx1 = ctx[1]
				if (istype(ctx[2], /obj/blob/launcher) && ctx1.type == /obj/blob/deposit)
					finished = 1
				return 1

		PerformSilentAction(var/action, var/context)
			if (action == "blob-life" && (istype(context, /obj/blob/deposit/replicator) || istype(context, /obj/blob/launcher)))
				return 1
			return 0

		MayAdvance()
			return finished

	cutscene3
		name = "Firing reagents"
		instructions = "Now that you have loaded your slime launcher with freshly replicated chlorine trifluoride, watch as it wrecks this assistant who just wandered onto your turf."

		var/mob/living/carbon/human/normal/assistant/H

		SetUp()
			..()
			var/datum/tutorial/blob/MT = tutorial
			var/tx = MT.initial_turf.x - 3
			var/ty = MT.initial_turf.y + 3
			var/tz = MT.initial_turf.z
			H = new(locate(tx, ty, tz))

		TearDown()
			if (H)
				H.gib()

		PerformSilentAction(var/action, var/context)
			if (action == "blob-life" && (istype(context, /obj/blob/deposit/replicator) || istype(context, /obj/blob/launcher)))
				return 1
			return 0

		MayAdvance()
			if (!H)
				return 1
			if (isdead(H))
				return 1
			if (H.health < 0)
				return 1

	finished
		name = "Finish up"
		instructions = "Congratulations! You have completed the basic blob tutorial. You will now be returned to the station."

		SetUp()
			..()
			sleep(5 SECONDS)
			tutorial.Advance()

proc/AddBlobSteps(var/datum/tutorial/blob/T)
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
	T.AddStep(new /datum/tutorialStep/blob/deposits)
	T.AddStep(new /datum/tutorialStep/blob/replicators)
	T.AddStep(new /datum/tutorialStep/blob/replication)
	T.AddStep(new /datum/tutorialStep/blob/launcher)
	T.AddStep(new /datum/tutorialStep/blob/reagent_launcher)
	T.AddStep(new /datum/tutorialStep/blob/cutscene3)
	T.AddStep(new /datum/tutorialStep/blob/finished)

/obj/blob_tutorial_walker
	name = "Pubs McFlamer"
	desc = "Some dork with a flamethrower."
	icon = 'icons/mob/human.dmi'
	icon_state = "body_f"
	var/obj/item/flamethrower/assembled/loaded/L = new

	New()
		..()
		overlays += image('icons/mob/inhand/hand_weapons.dmi', "flamethrower1-R")
		L.loc = src
		L.lit = 1

	proc/sprayAt(var/turf/T)
		L.afterattack(T, src, 0)

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
