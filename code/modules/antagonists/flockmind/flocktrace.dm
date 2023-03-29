/datum/antagonist/subordinate/flocktrace
	id = ROLE_FLOCKTRACE
	display_name = "flocktrace"

	/// The flock that this flocktrace belongs to.
	var/datum/flock/flock

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		src.master = master
		if (!isflockmob(src.master.current))
			return

		var/mob/living/intangible/flock/flockmob = src.master.current
		src.flock = flockmob.flock

		. = ..()

	give_equipment()
		var/free = TRUE
		// If this flocktrace has been created by a flockmind, ensure that the flocktrace is not free.
		// Late spawning flockminds will receive a free flocktrace as part of the latejoin or random event.
		// Likewise, Admin spawned flocktraces will also be free.
		if (src.assigned_by == ANTAGONIST_SOURCE_SUMMONED)
			free = FALSE

		var/mob/current_mob = src.owner.current
		var/mob/living/intangible/flock/trace/flocktrace_mob = new/mob/living/intangible/flock/trace(get_turf(current_mob), src.flock, free)
		src.owner.transfer_to(flocktrace_mob)
		qdel(current_mob)

		src.flock.trace_minds[flocktrace_mob.name] = src.owner

	remove_equipment()
		src.flock.traces -= src.owner.current
		src.flock.trace_minds -= src.owner.current.name

		var/mob/current_mob = src.owner.current
		src.owner.current.ghostize()
		qdel(current_mob)

	relocate()
		var/turf/T = get_turf(src.master.current)
		if (!(T && isturf(T)) || (T.z != Z_LEVEL_STATION))
			var/spawn_loc = pick_landmark(LANDMARK_LATEJOIN, locate(1, 1, Z_LEVEL_STATION))
			if (spawn_loc)
				src.owner.current.set_loc(spawn_loc)
			else
				src.owner.current.z = Z_LEVEL_STATION
		else
			src.owner.current.set_loc(T)

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/flock, src)

	announce()
		. = ..()
		boutput(src.owner.current, "<span class='bold'>You are a Flocktrace, a partition of the Flock's collective computation!</span>")
		boutput(src.owner.current, "<span class='bold'>Your loyalty is to the Flock of [src.flock.flockmind.real_name]. Spread drones, convert the station, and aid in the construction of the Relay.</span>")
		boutput(src.owner.current, "<span class='bold'>In this form, you cannot be harmed, but you can't do anything to the world at large.</span>")
		boutput(src.owner.current, "<span class='italic'>Tip: Click-drag yourself onto unoccupied drones to take direct control of them.</span>")
		boutput(src.owner.current, "<span class='notice'>You are part of the <span class='bold'>[flock.name]</span> flock.</span>")
		flock_speak(null, "Trace partition [src.owner.current.real_name] has been instantiated.", src.flock)
