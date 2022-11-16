/area/tutorial/flock
	name = "Flock Tutorial Zone"
	icon_state = "yellow"

/datum/tutorial_base/regional/flock
	name = "Flock tutorial"
	var/mob/living/intangible/flock/flockmind/fowner = null
	region_type = /datum/mapPrefab/allocated/flock_tutorial
	var/obj/landmark/center = null

	New(mob/M)
		. = ..()
		src.AddStep(new /datum/tutorialStep/flock/deploy)
		src.AddStep(new /datum/tutorialStep/flock/gatecrash)
		src.AddStep(new /datum/tutorialStep/flock/move)
		src.AddStep(new /datum/tutorialStep/flock/control)
		src.AddStep(new /datum/tutorialStep/flock/gather)
		src.AddStep(new /datum/tutorialStep/flock/convert_window)
		src.AddStep(new /datum/tutorialStep/flock/floorrun)
		src.AddStep(new /datum/tutorialStep/flock/release_drone)
		src.AddStep(new /datum/tutorialStep/flock/kill)
		src.AddStep(new /datum/tutorialStep/flock/place_sentinel)
		src.AddStep(new /datum/tutorialStep/flock/deposit_sentinel)
		src.AddStep(new /datum/tutorialStep/flock/build_thing/finish_sentinel)
		src.AddStep(new /datum/tutorialStep/flock/build_thing/interceptor)
		src.AddStep(new /datum/tutorialStep/flock/turret_demo)
		src.AddStep(new /datum/tutorialStep/flock/showcase)
		src.exit_point = pick_landmark(LANDMARK_LATEJOIN)
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_FLOCK_CONVERSION])
			if(src.region.turf_in_region(T))
				center = T
				break
		if (!center)
			CRASH("Okay who removed the goddamn [LANDMARK_TUTORIAL_FLOCK_CONVERSION] landmark")
		src.fowner = M

	Start()
		. = ..()
		for (var/mob/living/intangible/flock/trace/trace as anything in src.fowner.flock.traces)
			boutput(trace, "<span class='notice'>You have joined your Flockmind in the tutorial, you will not be able to interact with anything while they complete it.</span>")
			trace.set_loc(get_turf(src.fowner))

	Finish()
		. = ..()
		if (!.)
			return FALSE
		fowner.reset()
		fowner.flock.perish(FALSE)
		fowner.flock.enemies = list()
		fowner.flock.reset_stats()
		fowner.tutorial = null
		for (var/mob/living/intangible/flock/trace/trace as anything in src.fowner.flock.traces)
			trace.set_loc(get_turf(src.fowner))

	proc/make_maptext(atom/target, msg)
		msg = "<span class=\"ol vga c\" style=\"font-size:9pt\">[msg]</span>"
		var/obj/dummy = new(get_turf(target))
		var/image/chat_maptext/text = make_chat_maptext(dummy, msg, force = TRUE, time = INFINITY)
		var/mob/actual_mob = src.fowner.abilityHolder.get_controlling_mob() //hunt for the client
		text.show_to(actual_mob.client)

	proc/portal_in(turf/location, type)
		var/obj/portal/portal = new(location)
		sleep(1 SECOND)
		animate_portal_tele(portal)
		playsound(portal.loc, "warp", 50, 1, 0.2, 1.2)
		var/mob/jerk = new type(get_turf(portal))
		step(jerk, SOUTH)
		sleep(1 SECOND)
		qdel(portal)
		return jerk

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "FlockStructures")
			ui.open()

	ui_static_data(mob/user)
		var/list/structures = list()
		var/list/structure_types = concrete_typesof(/obj/flock_structure)
		for (var/type in structure_types)
			var/obj/flock_structure/structure = type //funny type abuse moment (515 please save us)
			if (!initial(structure.show_in_tutorial))
				continue
			structures += list(list(
				"icon" = icon2base64(icon(initial(structure.icon), initial(structure.icon_state), frame = 1)),
				"name" = initial(structure.flock_id),
				"description" = initial(structure.tutorial_desc) || initial(structure.flock_desc), //default to the normal description
				"cost" = initial(structure.resourcecost)
			))
		return list("structures" = structures)

	ui_status(mob/user)
		if(istype(user, /mob/living/intangible/flock/flockmind) || tgui_admin_state.can_use_topic(src, user))
			return UI_INTERACTIVE

/datum/tutorialStep/flock
	name = "Flock tutorial step"
	instructions = "If you see this, tell a coder!!!11"
	var/static/image/marker = null
	var/datum/tutorial_base/regional/flock/ftutorial = null

	New()
		..()
		if (!marker)
			marker = image('icons/effects/VR.dmi', "lightning_marker")
			marker.filters= filter(type="outline", size=1)
	SetUp()
		. = ..()
		src.ftutorial = src.tutorial

	PerformAction(action, context)
		return FALSE //fuck you, no action

/datum/tutorialStep/flock/deploy
	name = "Realizing"
	instructions = "If at any point this tutorial glitches up and leaves you in a stuck state, use the emergency tutorial stop verb (found in the Commands tab top right). <br /> Choose a suitable area to spawn your rift. In the real world you should try to choose an out of the way area with plenty of resources and delicious computers to eat. Here though, just deploy on the marked tile."
	var/turf/must_deploy = null

	SetUp()
		..()
		src.must_deploy = locate(ftutorial.initial_turf.x, ftutorial.initial_turf.y + 1, ftutorial.initial_turf.z)
		src.must_deploy.UpdateOverlays(src.marker,"marker")

	PerformAction(action, context)
		if (action == FLOCK_ACTION_RIFT_SPAWN)
			if (context == src.must_deploy)
				return TRUE
			else
				return "<span class='alert'><b>You must deploy on the marked tile.</b></span>"
		else if (action == FLOCK_ACTION_RIFT_COMPLETE)
			src.finished = TRUE
			return TRUE
		return FALSE

	TearDown()
		src.must_deploy.UpdateOverlays(null, "marker")

/datum/tutorialStep/flock/gatecrash
	name = "Gatecrash"
	instructions = "Your Flockdrone is stuck in this room, use your Gatecrash ability to force the door open."

	PerformAction(action, context)
		if (action == FLOCK_ACTION_GATECRASH)
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/move
	name = "Move"
	instructions = "Now move your Flockdrone through the door by click-dragging it to a visible tile past the door."

	PerformAction(action, context)
		if (action == FLOCK_ACTION_DRAGMOVE)
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/control
	name = "Control drone"
	instructions = "Sometimes you may want to take direct control of a single drone, for combat or fine movement control. Click-drag yourself onto the Flockdrone to take control of it."

	PerformAction(action, context)
		if (action == FLOCK_ACTION_DRONE_CONTROL)
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/gather
	name = "Gather resources"
	instructions = "In order to convert the station around you, you are going to need resources. Pick up some items using your manipulating hand (grip tool) and place them into your disintegration reclaimer (or use equip hotkey) to break them down into resources."
	var/amount = 30

	PerformAction(action, context)
		if (action == FLOCK_ACTION_GAIN_RESOURCES && context >= amount)
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/convert_window
	name = "Conversion"
	instructions = "Convert the window in front of you to allow you to pass through it. Convert it by clicking on it with your nanite spray (middle) hand."

	PerformAction(action, context)
		if (action == FLOCK_ACTION_START_CONVERSION)
			if (locate(/obj/window) in get_turf(context))
				return TRUE
			else
				return "<span class='alert'><b>You must convert a window.</b></span>"
		if (action == FLOCK_ACTION_TURF_CLAIM && locate(/obj/window) in context)
			finished = TRUE
			return TRUE

/datum/tutorialStep/flock/floorrun
	name = "Floorrunning"
	instructions = "While controlling a Flockdrone you can press or hold your sprint key to disappear into the newly Flock converted floor, becoming unhittable, and you can pass into nearby Flock floortiles and Flock walls, as long as you have resources. This is referred to as \"Floorrunning.\" Floorrun through the window you just converted. This is possible as a Flock floortile is underneath."

	PerformAction(action, context)
		if (action == FLOCK_ACTION_FLOORRUN)
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/release_drone
	name = "Release control"
	instructions = "Now use the eject button at the bottom right of your HUD to release control of this drone."

	SetUp()
		..()
		var/mob/living/critter/flock/drone/first_drone = src.ftutorial.fowner.flock.units[/mob/living/critter/flock/drone/][1] // lol
		first_drone.set_tutorial_ai(FALSE)
		SPAWN(1 SECOND)
			flock_spiral_conversion(src.ftutorial.center, ftutorial.fowner.flock, 10, 0.1 SECONDS)
		for (var/i = 1 to 4)
			var/mob/living/critter/flock/drone/flockdrone = new(locate(src.ftutorial.center.x + rand(-3, 3), src.ftutorial.center.y + rand(-3, 3), src.ftutorial.center.z), ftutorial.fowner.flock)
			spawn_animation1(flockdrone)
			sleep(0.2 SECONDS)
		for (var/i = 1 to 2)
			var/mob/living/critter/flock/bit/flockdrone = new(locate(src.ftutorial.center.x + rand(-3, 3), src.ftutorial.center.y + rand(-3, 3), src.ftutorial.center.z), ftutorial.fowner.flock)
			spawn_animation1(flockdrone)
			sleep(0.2 SECONDS)
		var/msg = "Human resource containers convert into Flock resource fabricators."
		src.ftutorial.make_maptext(locate(/obj/machinery/vending) in range(10, src.ftutorial.center), msg)

		var/obj/flock_structure/compute/type = /obj/flock_structure/compute/
		msg = "Human computers convert into Flock compute nodes. Each provides [initial(type.compute)] compute."
		src.ftutorial.make_maptext(locate(/obj/machinery/computer) in range(10, src.ftutorial.center), msg)

	PerformAction(action, context)
		if (action == FLOCK_ACTION_DRONE_RELEASE)
			finished = TRUE
			return TRUE

/datum/tutorialStep/flock/kill
	name = "Eliminate threat"
	instructions = "That human has just violated causality to teleport right into your flock! Mark them for elimination using your \"Designate Enemy\" ability and watch as your drones fire at, subdue, and cage them."

	SetUp()
		..()
		var/turf/T = locate(src.ftutorial.center.x, src.ftutorial.center.y + 3, src.ftutorial.center.z)
		src.ftutorial.portal_in(T, /mob/living/carbon/human/normal/assistant)

	PerformAction(action, context)
		if (action == FLOCK_ACTION_MARK_ENEMY || action == FLOCK_ACTION_START_CONVERSION)
			return TRUE
		if (action == FLOCK_ACTION_CAGE)
			finished = TRUE
			return TRUE

/datum/tutorialStep/flock/place_sentinel
	name = "Construct Sentinel"
	instructions = "There may be more humans around, build a Sentinel for protection. Move over the marked turf and use your \"Place Tealprint\" ability to place one."
	var/turf/location = null

	SetUp()
		..()
		src.location = locate(src.ftutorial.center.x, src.ftutorial.center.y - 3, src.ftutorial.center.z)
		src.location.UpdateOverlays(marker, "marker")

	PerformAction(action, context)
		if (action == FLOCK_ACTION_TEALPRINT_PLACE && context == /obj/flock_structure/sentinel)
			if (get_turf(src.ftutorial.fowner) == src.location)
				src.finished = TRUE
				return TRUE
			else
				return "<span class='alert'><b>You must place the tealprint on the marked tile.</b></span>"

/datum/tutorialStep/flock/deposit_sentinel
	name = "Direct drones to construct"
	instructions = "Nearby AI controlled drones will automatically deposit their resources into tealprints, but you can also order them to do so directly. Click on a drone to select it, then click on the tealprint to target it. The same works to order a drone to convert, attack, cage, and so on depending what you click on."

	PerformAction(action, context)
		if (action == FLOCK_ACTION_DRONE_SELECT)
			return TRUE
		if (action == FLOCK_ACTION_DRONE_ORDER && context == /datum/aiTask/sequence/goalbased/flock/deposit/targetable)
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/build_thing
	var/turf/location = null
	var/structure_type = null

	PerformAction(action, context)
		if (action in list(FLOCK_ACTION_START_CONVERSION, FLOCK_ACTION_DRONE_SELECT, FLOCK_ACTION_DRONE_ORDER))
			return TRUE
		if (action == FLOCK_ACTION_TEALPRINT_PLACE && context == src.structure_type)
			if (get_turf(src.ftutorial.fowner) == src.location)
				return TRUE
			else
				return "<span class='alert'><b>You must place the tealprint on the marked tile.</b></span>"
		if (action == FLOCK_ACTION_TEALPRINT_COMPLETE)
			var/obj/flock_structure/struct = context
			struct.process(200) //force a high mult process to immediately charge the structure if it needs it
			src.finished = TRUE
			src.location.UpdateOverlays(null, "marker")
			return TRUE

/datum/tutorialStep/flock/build_thing/finish_sentinel
	name = "Construct Sentinel"
	instructions = "Direct your drones to complete the tealprint. You can see how many resources a drone has by examining it."
	structure_type = /obj/flock_structure/sentinel

	SetUp()
		..()
		src.location = locate(src.ftutorial.center.x, src.ftutorial.center.y - 3, src.ftutorial.center.z)

/datum/tutorialStep/flock/build_thing/interceptor
	name = "Construct Interceptor"
	instructions = "As you can see, humans often carry guns that can be very harmful to our drones. Construct an Interceptor to destroy their bullets in midair."
	structure_type = /obj/flock_structure/interceptor

	SetUp()
		..()
		src.ftutorial.fowner.flock.achieve(FLOCK_ACHIEVEMENT_BULLETS_HIT)
		src.ftutorial.portal_in(get_turf(src.ftutorial.center), /mob/living/carbon/human/normal/chef/shoot_gun_person/)
		src.location = locate(src.ftutorial.center.x - 1, src.ftutorial.center.y - 3, src.ftutorial.center.z)
		location.UpdateOverlays(marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == FLOCK_ACTION_TEALPRINT_COMPLETE)
			var/obj/flock_structure/interceptor/struct = context
			OVERRIDE_COOLDOWN(struct, "bolt_gen_time", 0 SECONDS)
			struct.process(1)

/datum/tutorialStep/flock/turret_demo
	name = "Intercept"
	instructions = "Watch the Interceptor destroy a bullet."
	SetUp()
		..()
		var/turf/T = locate(src.ftutorial.center.x, src.ftutorial.center.y - 6, src.ftutorial.center.z)
		var/obj/deployable_turret/riot/turret = new(T)
		turret.set_angle(0)
		turret.set_projectile()
		sleep(1 SECOND)
		muzzle_flash_any(turret, 0, "muzzle_flash")
		shoot_projectile_ST_pixel_spread(turret, turret.current_projectile, src.ftutorial.center, 0, 0 , turret.spread)
		SPAWN(10 SECONDS)
			src.ftutorial.Advance()

/datum/tutorialStep/flock/relay
	name = "The Relay"
	New()
		src.instructions = "This is the Relay, your ultimate goal. Unlocked at [FLOCK_RELAY_COMPUTE_COST] compute, when complete it will allow you to transmit the Signal and cast the Flock out towards the Source."
		..()

	SetUp()
		..()
		var/turf/T = get_turf(src.ftutorial.center)
		for (var/obj/flock_structure/cage/cage in range(3, T))
			qdel(cage.occupant)
			qdel(cage)
		var/obj/flock_structure/ghost/tealprint = new(T, src.ftutorial.fowner.flock, /obj/flock_structure/relay)
		tealprint.fake = TRUE

/datum/tutorialStep/flock/showcase
	name = "Structure showcase"
	instructions = "Here are all the Flock structures you can create, along with a shadow of the Relay, your ultimate goal. Click the exit tutorial button in the bottom right corner to exit the tutorial."
	SetUp()
		..()
		src.ftutorial.fowner.abilityHolder.addAbility(/datum/targetable/flockmindAbility/tutorial_exit)
		var/datum/mapPrefab/allocated/prefab = get_singleton(/datum/mapPrefab/allocated/flock_showcase)
		var/datum/allocated_region/region = prefab.load()
		for (var/turf/T in REGION_TILES(region))
			var/obj/spawner/flock_structure/structure_spawner = locate() in T
			structure_spawner?.spawn_structure(ftutorial.fowner.flock)
			var/mob/living/carbon/human/bad_immortal/fake_tdummy = locate() in T
			if (fake_tdummy)
				src.ftutorial.fowner.flock.updateEnemy(fake_tdummy)
		var/turf/landmark = null
		for(var/turf/T as anything in landmarks[LANDMARK_TUTORIAL_START])
			if(region.turf_in_region(T))
				landmark = T
				break
		if (!landmark)
			CRASH("No flock showcase landmark found, aaaaa")
		src.ftutorial.fowner.set_loc(landmark)
		src.ftutorial.ui_interact(src.ftutorial.fowner)
		for (var/mob/living/intangible/flock/trace/trace as anything in src.ftutorial.fowner.flock.traces)
			trace.set_loc(get_turf(src.ftutorial.fowner))
			src.ftutorial.ui_interact(trace)

/mob/living/intangible/flock/flockmind/verb/help_my_tutorial_is_being_a_massive_shit()
	set name = "EMERGENCY TUTORIAL STOP"
	if (!src.tutorial)
		boutput(src, "<span class='alert'>You're not in a tutorial, doofus. It's real. IT'S ALL REAL.</span>")
		return
	src.tutorial.Finish()
	src.tutorial = null

/mob/living/critter/flock/drone/verb/help_my_tutorial_is_being_a_massive_shit()
	set name = "EMERGENCY TUTORIAL STOP"
	if (istype(src.controller, /mob/living/intangible/flock/flockmind))
		var/mob/living/intangible/flock/flockmind/flockmind = src.controller
		src.release_control()
		flockmind.help_my_tutorial_is_being_a_massive_shit()

//for debug, do not enable on live or it will cause runtimes and break everything
// /mob/living/intangible/flock/flockmind/verb/skip_tutorial_step()
// 	set name = "SKIP TUTORIAL STEP"
// 	src.tutorial.Advance()

/obj/machinery/junk_spawner
	var/stuff = list(/obj/item/extinguisher, /obj/item/crowbar, /obj/item/wrench)
	process(mult)
		if (!(locate(/obj/item) in get_turf(src)))
			var/type = pick(src.stuff)
			new type(src.loc)

/mob/living/carbon/human/normal/chef/shoot_gun_person
	New()
		..()
		var/obj/item/gun/kinetic/zipgun/gun = new(src)
		gun.failure_chance = 0
		src.put_in_hand(gun)
		SPAWN(0)
			while(TRUE)
				for (var/dir in modulo_angle_to_dir)
					if (is_incapacitated(src))
						return
					src.set_dir(dir)
					gun.ammo.amount_left = 2
					var/turf/target = get_step(src, dir)
					gun.shoot(target, src.loc, src)
					sleep(1.5 SECONDS)

/mob/living/carbon/human/bad_immortal
	real_name = "Target dummy"
	Life(datum/controller/process/mobs/parent)
		. = ..()
		for (var/obj/item/implant/I in implant) //no infinite item stacks
			if (istype(I, /obj/item/implant/projectile))
				I.on_remove(src)
				implant.Remove(I)
				qdel(I)

		src.full_heal()

/obj/spawner/flock_structure
	name = "flock structure"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	var/structure_type = null
	var/ghost = FALSE

	proc/spawn_structure(datum/flock/flock)
		if (!ispath(src.structure_type))
			return
		if (src.ghost)
			var/obj/flock_structure/ghost/ghost = new(get_turf(src), flock, src.structure_type)
			ghost.fake = TRUE
		else
			new src.structure_type(get_turf(src), flock)
		qdel(src)
