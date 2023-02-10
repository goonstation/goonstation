/area/tutorial
	allowed_restricted_z = TRUE
	dont_log_combat = TRUE

/datum/tutorial_base
	var/name = "Tutorial"
	var/mob/owner = null
	var/list/steps = list()
	var/current_step = 0
	var/finished = FALSE

	New(var/mob/M)
		..()
		owner = M

	proc
		AddStep(step_type)
			steps += new step_type(src)

		ShowStep()
			if (!current_step || current_step > steps.len)
				boutput(owner, "<span class='alert'><b>Invalid tutorial state, please notify `An Admin`.</b></span>")
				qdel(src)
				return
			var/datum/tutorialStep/T = steps[current_step]
			boutput(owner, "<span class='notice'><b>Tutorial step #[current_step]: [T.name]</b></span>")
			boutput(owner, "<span class='notice'>[T.instructions]</span>")

		Start()
			if (!owner)
				return 0
			if (current_step > 0)
				return 0
			current_step = 1
			var/datum/tutorialStep/T = steps[current_step]
			ShowStep()
			T.SetUp()
			return 1

		Advance()
			playsound(get_turf(owner), 'sound/machines/ping.ogg', 50, pitch = 0.5)
			if (current_step > steps.len)
				return
			var/datum/tutorialStep/T = steps[current_step]
			T.TearDown()
			current_step++
			if (current_step > steps.len)
				Finish()
				return
			T = steps[current_step]
			ShowStep()
			T.SetUp()

		Finish()
			if (finished)
				return 0
			finished = 1
			if (current_step <= steps.len)
				var/datum/tutorialStep/T = steps[current_step]
				T.TearDown()
			boutput(owner, "<span class='notice'><b>The tutorial is finished!</b></span>")
			return 1

		CheckAdvance()
			if (!current_step || current_step > steps.len)
				return
			var/datum/tutorialStep/T = steps[current_step]
			if (T.MayAdvance())
				if (T == steps[current_step])
					Advance()

		PerformAction(var/action, var/context)
			if (!current_step || current_step > steps.len)
				boutput(owner, "<span class='alert'><b>Invalid tutorial state, please notify `An Admin`.</b></span>")
				qdel(src)
				return 1
			var/datum/tutorialStep/T = steps[current_step]
			var/result = T.PerformAction(action, context)
			if (!result || istext(result)) //if text is returned it's an error message
				ShowStep()
				boutput(owner, result || "<span class='alert'><b>You cannot do that currently.</b></span>")
				return FALSE
			else
				SPAWN(0)
					CheckAdvance()
				return TRUE


		PerformSilentAction(var/action, var/context)
			if (!current_step || current_step > steps.len)
				boutput(owner, "<span class='alert'><b>Invalid tutorial state, please notify `An Admin`.</b></span>")
				qdel(src)
				return 1
			var/datum/tutorialStep/T = steps[current_step]
			if (T.PerformAction(action, context))
				SPAWN(0)
					CheckAdvance()
				return 1
			else
				return 0

/datum/tutorial_base/regional
	var/turf/initial_turf = null
	var/datum/allocated_region/region = null
	var/region_type = null
	var/turf/exit_point = null

	New(mob/M)
		. = ..()
		var/datum/mapPrefab/allocated/prefab = get_singleton(src.region_type)
		src.region = prefab.load()
		logTheThing(LOG_DEBUG, usr, "<b>[src.name]</b>: Got bottom left corner [log_loc(src.region.bottom_left)]")
		for(var/turf/T as anything in landmarks[LANDMARK_TUTORIAL_START])
			if(region.turf_in_region(T))
				initial_turf = T
				break

	Start()
		. = ..()
		if (!.)
			return
		if (!initial_turf)
			logTheThing(LOG_DEBUG, usr, "<b>[src.name]</b>: Tutorial failed setup: missing landmark.")
			CRASH("Okay who removed the goddamn [src.name] landmark")
		owner.set_loc(initial_turf)

	Finish()
		. = ..()
		if (.)
			src.owner.set_loc(src.exit_point)

	disposing()
		qdel(src.region)
		src.region = null
		landmarks[LANDMARK_TUTORIAL_START] -= src.initial_turf
		..()

/datum/tutorialStep
	var/name = "Tutorial Step"
	var/instructions = "Do something"
	var/datum/tutorial_base/tutorial = null
	var/finished = FALSE

	New(datum/tutorial_base/tutorial)
		. = ..()
		src.tutorial = tutorial

	proc
		SetUp()
			src.finished = FALSE
		TearDown()
		PerformAction(var/action, var/context)
			return TRUE
		MayAdvance()
			return src.finished
