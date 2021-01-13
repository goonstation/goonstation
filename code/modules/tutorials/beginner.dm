// VERY VERY WIP

/*
area/tutorial_zone
	name = "Tutorial zone"

/datum/tutorial/beginner
	name = "Beginner's tutorial"
	var/area/tutorial_area = null

	New()
		..()
		AddBeginnerTutorialSteps(src)
		tutorial_area = locate(/area/beginner_tutorial) in world
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_START])
			if(T.loc == tutorial_area)
				initial_turf = T
				break
		if (!initial_turf)
			logTheThing("debug", usr, null, "<b>Beginner Tutorial</b>: Tutorial failed setup: missing landmark.")
			throw EXCEPTION("Okay who removed the goddamn beginner tutorial landmark")


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
