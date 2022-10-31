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
		AddStep(var/datum/tutorialStep/T)
			steps += T
			T.tutorial = src

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
			if (T.PerformAction(action, context))
				SPAWN(0)
					CheckAdvance()
				return 1
			else
				ShowStep()
				boutput(owner, "<span class='alert'><b>You cannot do that currently.</b></span>")
				return 0

		PerformSilentAction(var/action, var/context)
			if (!current_step || current_step > steps.len)
				boutput(owner, "<span class='alert'><b>Invalid tutorial state, please notify `An Admin`.</b></span>")
				qdel(src)
				return 1
			var/datum/tutorialStep/T = steps[current_step]
			if (T.PerformSilentAction(action, context))
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
		src.region = get_singleton(src.region_type).load()
		logTheThing(LOG_DEBUG, usr, "<b>[src.name]</b>: Got bottom left corner [log_loc(src.region.bottom_left)]")
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_START])
			if(region.turf_in_region(T))
				initial_turf = T
				break

	Start()
		. = ..()
		if (!.)
			return
		if (!initial_turf)
			logTheThing(LOG_DEBUG, usr, "<b>[src.name]</b>: Tutorial failed setup: missing landmark.")
			throw EXCEPTION("Okay who removed the goddamn [src.name] landmark")
		owner.set_loc(initial_turf)

	Finish()
		. = ..()
		if (.)
			src.owner.set_loc(src.exit_point)

	disposing()
		qdel(src.region)
		landmarks[LANDMARK_TUTORIAL_START] -= src.initial_turf
		..()

/datum/tutorialStep
	var/name = "Tutorial Step"
	var/instructions = "Do something"
	var/datum/tutorial_base/tutorial = null
	var/finished = FALSE

	proc
		SetUp()
			src.finished = FALSE
		TearDown()
		PerformAction(var/action, var/context)
			return TRUE
		PerformSilentAction(var/action, var/context)
			return FALSE
		MayAdvance()
			return src.finished
