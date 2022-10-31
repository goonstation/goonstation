/datum/tutorial_base/regional/flock
	name = "Flock tutorial"
	var/mob/living/intangible/flock/flockmind/fowner = null
	region_type = /datum/mapPrefab/allocated/flock_tutorial

	New(mob/M)
		. = ..()
		src.AddStep(new /datum/tutorialStep/flock/deploy)
		src.AddStep(new /datum/tutorialStep/flock/gatecrash)
		src.AddStep(new /datum/tutorialStep/flock/move)
		src.AddStep(new /datum/tutorialStep/flock/control)
		src.AddStep(new /datum/tutorialStep/flock/gather)
		src.AddStep(new /datum/tutorialStep/flock/convert_window)
		src.AddStep(new /datum/tutorialStep/flock/release_drone)
		src.exit_point = pick_landmark(LANDMARK_OBSERVER)
		src.fowner = M

	Finish()
		. = ..()
		if (!.)
			return FALSE
		fowner.reset()
		fowner.tutorial = null


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

/datum/tutorialStep/flock/deploy
	name = "Realizing"
	instructions = "If at any point this tutorial glitches up and leaves in a stuck state, use the emergency tutorial stop verb. Choose a suitable area to spawn your rift. Try to choose an out of the way area with plenty of resources and delicious computers to eat."
	var/turf/must_deploy = null

	SetUp()
		..()
		must_deploy = locate(ftutorial.initial_turf.x, ftutorial.initial_turf.y + 1, ftutorial.initial_turf.z)
		must_deploy.UpdateOverlays(marker,"marker")

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

	PerformSilentAction(action, context)
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

	PerformSilentAction(action, context)
		if (action == "gain resources" && context >= amount)
			src.finished = TRUE
			return TRUE

/datum/tutorialStep/flock/convert_window
	name = "Conversion"
	instructions = "Convert the window in front of you to allow you to pass through it. Convert it by clicking on it with your nanite spray (middle) hand."

	PerformSilentAction(var/action, var/context)
		if (action == "claim turf" && locate(/obj/window) in context)
			finished = TRUE
			return TRUE

/datum/tutorialStep/flock/release_drone
	name = "Release control"
	instructions = "Now use the eject button at the bottom right of your HUD to release control of this drone."

	PerformAction(action, context)
		if (action == "release drone")
			finished = TRUE
			return TRUE

/mob/living/intangible/flock/flockmind/verb/help_my_tutorial_is_being_a_massive_shit()
	set name = "EMERGENCY TUTORIAL STOP"
	if (!tutorial)
		boutput(src, "<span class='alert'>You're not in a tutorial, doofus. It's real. IT'S ALL REAL.</span>")
		return
	src.tutorial.Finish()
	src.tutorial = null
