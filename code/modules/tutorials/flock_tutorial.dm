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
		src.AddStep(new /datum/tutorialStep/flock/build_thing/sentinel)
		src.AddStep(new /datum/tutorialStep/flock/build_thing/interceptor)
		src.AddStep(new /datum/tutorialStep/flock/turret_demo)
		src.AddStep(new /datum/tutorialStep/flock/relay)
		src.exit_point = pick_landmark(LANDMARK_OBSERVER)
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_FLOCKCONVERSION])
			if(src.region.turf_in_region(T))
				center = T
				break
		if (!center)
			throw EXCEPTION("Okay who removed the goddamn [LANDMARK_TUTORIAL_FLOCKCONVERSION] landmark")
		src.fowner = M

	Finish()
		. = ..()
		if (!.)
			return FALSE
		fowner.reset()
		fowner.flock.perish(FALSE)
		fowner.tutorial = null

	proc/make_maptext(var/atom/target, var/msg)
		msg = "<span class=\"ol vga c\" style=\"font-size:9pt\">[msg]</span>"
		var/obj/dummy = new(get_turf(target))
		var/image/chat_maptext/text = make_chat_maptext(dummy, msg, force = TRUE, time = INFINITY)
		var/mob/actual_mob = src.fowner.abilityHolder.get_controlling_mob() //hunt for the client
		text.show_to(actual_mob.client)

	proc/portal_in(var/turf/location, var/type)
		var/obj/portal/portal = new(location)
		sleep(1 SECOND)
		animate_portal_tele(portal)
		playsound(portal.loc, "warp", 50, 1, 0.2, 1.2)
		var/mob/jerk = new type(get_turf(portal))
		step(jerk, SOUTH)
		sleep(1 SECOND)
		qdel(portal)
		return jerk

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
	instructions = "If at any point this tutorial glitches up and leaves in a stuck state, use the emergency tutorial stop verb. Choose a suitable area to spawn your rift. Try to choose an out of the way area with plenty of resources and delicious computers to eat."
	var/turf/must_deploy = null

	SetUp()
		..()
		src.must_deploy = locate(ftutorial.initial_turf.x, ftutorial.initial_turf.y + 1, ftutorial.initial_turf.z)
		src.must_deploy.UpdateOverlays(src.marker,"marker")

	PerformAction(var/action, var/context)
		if (action == "spawn rift" && context == must_deploy)
			return TRUE
		else if (action == "rift complete")
			src.finished = TRUE
			return TRUE
		return FALSE

	TearDown()
		must_deploy.UpdateOverlays(null,"marker")

/datum/tutorialStep/flock/gatecrash
	name = "Gatecrash"
	instructions = "Your flockdrone is stuck in this room, use your Gatecrash ability to force the door open."

	PerformAction(action, context)
		if (action == "gatecrash")
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/move
	name = "Move"
	instructions = "Now move your flockdrone through the door by clicking and dragging it."

	PerformAction(action, context)
		if (action == "click drag move")
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/control
	name = "Control drone"
	instructions = "Sometimes you may want to take direct control of a single drone, for combat or fine movement control. Click drag yourself over the flockdrone to take control of it."

	PerformAction(action, context)
		if (action == "control drone")
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/gather
	name = "Gather resources"
	instructions = "In order to convert the station around you, you are going to need resources. Pick up some items using your manipulator hand and place them into your disintigrator (equip hotkey) to break them down into resources."
	var/amount = 30

	PerformAction(action, context)
		if (action == "gain resources" && context >= amount)
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/convert_window
	name = "Conversion"
	instructions = "Convert the window in front of you to allow you to pass through it. Convert it by clicking on it with your nanite spray (middle) hand."

	PerformAction(var/action, var/context)
		if (action == "start conversion" && locate(/obj/window) in get_turf(context))
			return TRUE
		if (action == "claim turf" && locate(/obj/window) in context)
			finished = TRUE
			return TRUE

/datum/tutorialStep/flock/floorrun
	name = "Floor running"
	instructions = "While controlling a flockdrone you can press your sprint key to disappear into the floor, becoming untargetable and passing through flock walls and windows. Use it to pass through the window you just converted."

	PerformAction(action, context)
		if (action == "floorrun")
			src.finished = TRUE
			return TRUE
/datum/tutorialStep/flock/release_drone
	name = "Release control"
	instructions = "Now use the eject button at the bottom right of your HUD to release control of this drone."

	SetUp()
		..()
		var/mob/living/critter/flock/drone/first_drone = src.ftutorial.fowner.flock.units[/mob/living/critter/flock/drone/][1] // lol
		first_drone.set_stupid(FALSE)
		SPAWN(1 SECOND)
			flock_spiral_conversion(src.ftutorial.center, ftutorial.fowner.flock, 0.1 SECONDS)
		for (var/i = 1 to 4)
			var/mob/living/critter/flock/drone/flockdrone = new(locate(src.ftutorial.center.x + rand(-3,3), src.ftutorial.center.y + rand(-3,3), src.ftutorial.center.z), ftutorial.fowner.flock)
			spawn_animation1(flockdrone)
			sleep(0.2 SECONDS)
		for (var/i = 1 to 2)
			var/mob/living/critter/flock/bit/flockdrone = new(locate(src.ftutorial.center.x + rand(-3,3), src.ftutorial.center.y + rand(-3,3), src.ftutorial.center.z), ftutorial.fowner.flock)
			spawn_animation1(flockdrone)
			sleep(0.2 SECONDS)
		var/msg = "Human resource containers convert into Flock resource Fabricators."
		src.ftutorial.make_maptext(locate(/obj/machinery/vending) in range(10, src.ftutorial.center), msg)

		msg = "Human computers convert into Flock compute nodes. Each provides 60 compute."
		src.ftutorial.make_maptext(locate(/obj/machinery/computer) in range(10, src.ftutorial.center), msg)

	PerformAction(action, context)
		if (action == "release drone")
			finished = TRUE
			return TRUE

/atom/proc/maptext_test()
	var/image/chat_maptext/text = make_chat_maptext(src, "Vending machine", force = TRUE, time = INFINITY)
	text.show_to(usr.client)

/datum/tutorialStep/flock/kill
	name = "Eliminate threat"
	instructions = "That human has just violated causality to teleport right into your flock! Mark them for elimination using your \"designate enemy\" ability and watch as your drones attack."

	SetUp()
		..()
		var/turf/T = locate(src.ftutorial.center.x, src.ftutorial.center.y + 3, src.ftutorial.center.z)
		src.ftutorial.portal_in(T, /mob/living/carbon/human/normal/assistant)

	PerformAction(action, context)
		if (action == "designate enemy" || action == "start conversion")
			return TRUE
		if (action == "cage")
			finished = TRUE
			return TRUE

/datum/tutorialStep/flock/build_thing
	var/turf/location = null
	var/structure_type = null

	PerformAction(action, context)
		if (action == "start conversion")
			return TRUE
		if (action == "place tealprint" && context == src.structure_type && get_turf(src.ftutorial.fowner) == src.location)
			return TRUE
		if (action == "building complete")
			var/obj/flock_structure/struct = context
			struct.process(200) //force a high mult process to immediately charge the structure if it needs it
			src.finished = TRUE
			src.location.UpdateOverlays(null, "marker")
			return TRUE

/datum/tutorialStep/flock/build_thing/sentinel
	name = "Construct Sentinel"
	//TODO: add instruction about using click controls to order deposit after #11654 is merged
	instructions = "There may be more humans around, build a Sentinel for protection. Move over the marked turf and use your \"place tealprint\" ability to place one, then direct your drones to construct it. Sentinels are powerful electric stun turrets, effective at making any humans who come into your lair go horizontal."
	structure_type = /obj/flock_structure/sentinel

	SetUp()
		..()
		src.location = locate(src.ftutorial.center.x, src.ftutorial.center.y - 3, src.ftutorial.center.z)
		src.location.UpdateOverlays(marker, "marker")

/datum/tutorialStep/flock/build_thing/interceptor
	name = "Construct Interceptor"
	instructions = "As you can see, humans often carry guns that can be very harmful to our drones. Construct an Interceptor to destroy their bullets in mid air."
	structure_type = /obj/flock_structure/interceptor

	SetUp()
		..()
		src.ftutorial.fowner.flock.achieve(FLOCK_ACHIEVEMENT_BULLETS_HIT)
		src.ftutorial.portal_in(get_turf(src.ftutorial.center), /mob/living/carbon/human/normal/chef/shoot_gun_person/)
		src.location = locate(src.ftutorial.center.x - 1, src.ftutorial.center.y - 3, src.ftutorial.center.z)
		location.UpdateOverlays(marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "building complete")
			var/obj/flock_structure/interceptor/struct = context
			OVERRIDE_COOLDOWN(struct, "bolt_gen_time", 0 SECONDS)
			struct.power_projectile_checkers(TRUE)

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
		src.instructions = "This is the Relay, your ultimate goal. Unlocked at [FLOCK_RELAY_COMPUTE_COST] compute, when complete it will allow you to transmit the Signal and cast the Flock out towards our next target."
		..()

	SetUp()
		..()
		var/turf/T = get_turf(src.ftutorial.center)
		for (var/obj/flock_structure/cage/cage in range(3, T))
			qdel(cage.occupant)
			qdel(cage)
		var/obj/flock_structure/ghost/tealprint = new(T, src.ftutorial.fowner.flock, /obj/flock_structure/relay)
		tealprint.fake = TRUE
		SPAWN(15 SECONDS)
			src.ftutorial.Advance()

/mob/living/intangible/flock/flockmind/verb/help_my_tutorial_is_being_a_massive_shit()
	set name = "EMERGENCY TUTORIAL STOP"
	if (!src.tutorial)
		boutput(src, "<span class='alert'>You're not in a tutorial, doofus. It's real. IT'S ALL REAL.</span>")
		return
	src.tutorial.Finish()
	src.tutorial = null

/mob/living/intangible/flock/flockmind/verb/skip_tutorial_step()
	set name = "SKIP TUTORIAL STEP"
	src.tutorial.Advance()

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

