/datum/antagonist/subordinate/mob/intangible/flocktrace
	id = ROLE_FLOCKTRACE
	display_name = "flocktrace"
	uses_pref_name = FALSE
	mob_path = /mob/living/intangible/flock/trace
	wiki_link = "https://wiki.ss13.co/Flockmind#Flocktrace"

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

		. = ..()

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/flock, src)

	announce()
		. = ..()
		boutput(src.owner.current, SPAN_BOLD("You are a Flocktrace, a partition of the Flock's collective computation!"))
		boutput(src.owner.current, SPAN_BOLD("Your loyalty is to the Flock of [src.flock.flockmind.real_name]. Spread drones, convert the station, and aid in the construction of the Relay."))
		boutput(src.owner.current, SPAN_BOLD("In this form, you cannot be harmed, but you can't do anything to the world at large."))
		boutput(src.owner.current, SPAN_ITALIC("Tip: Click-drag yourself onto unoccupied drones to take direct control of them."))
		boutput(src.owner.current, SPAN_NOTICE("You are part of the [SPAN_BOLD("[flock.name]")] flock."))
		src.flock.system_say_source.say("Trace partition [src.owner.current.real_name] has been instantiated.")
