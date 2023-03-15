ABSTRACT_TYPE(/datum/antagonist/subordinate)
/datum/antagonist/subordinate
	mutually_exclusive = FALSE
	/// The mind of this antagonist's master, leader, and so forth.
	var/datum/mind/master

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		src.master = master
		. = ..()
