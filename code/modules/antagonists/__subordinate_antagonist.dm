ABSTRACT_TYPE(/datum/antagonist/subordinate)
/datum/antagonist/subordinate
	mutually_exclusive = FALSE
	display_at_round_end = FALSE
	/// The mind of this antagonist's master, leader, and so forth.
	var/datum/mind/master

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		if (master && istype(master, /datum/mind))
			src.master = master
			// Remove mind.master when it has been superseded by subordinate antagonist roles.
			src.owner = new_owner
			src.owner.master = src.master.ckey
		. = ..()

	disposing()
		src.owner.master = null
		. = ..()
