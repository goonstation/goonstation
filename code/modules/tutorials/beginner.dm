// VERY VERY WIP

/*
area/tutorial_zone
	name = "Tutorial zone"

/datum/tutorial/beginner
	name = "Beginner's tutorial"
	var/obj/landmark/tutorial_start/start_loc = null
	var/area/tutorial_area = null

	New()
		..()
		AddBeginnerTutorialSteps(src)
		tutorial_area = locate(/area/beginner_tutorial) in world
		var/obj/landmark/tutorial_start/L = null
		for (var/obj/landmark/tutorial_start/temp in tutorial_area)
			L = temp
			break
		if (!L)
			logTheThing("debug", usr, null, "<b>Beginner Tutorial</b>: Tutorial failed setup: missing landmark.")
			throw EXCEPTION("Okay who removed the goddamn beginner tutorial landmark")
		start_loc = get_turf(L)
		if (!start_loc)
			logTheThing("debug", usr, null, "<b>Blob Tutorial</b>: Tutorial failed setup: [L], [initial_turf].")


	Start()
		if (!start_loc)
			logTheThing("debug", usr, null, "<b>Beginner Tutorial</b>: Failed setup.")
			boutput(usr, "<span class='alert'><b>Error setting up tutorial!</b></span>")
			qdel(src)
			return
		..()
		owner.set_loc(start_loc)

	Finish()

/datum/tutorialStep/beginner
	name = "Beginner tutorial step"
	instructions = "If you see this, tell a coder!!!11"

	welcome

	charSetup

	movement

	hands

	intents

	targeting

	toggles

	inventory

	equipping

	indicators

	access

	speech

	radio

	combat

	rules

	mentorhelp

	jobs

proc/AddBeginnerTutorialSteps(var/datum/tutorial/beginner/T)
	T.AddStep(new /datum/tutorialStep/beginner/charSetup)

	*/
