ABSTRACT_TYPE(/datum/antagonist/subordinate)
/datum/antagonist/subordinate
	mutually_exclusive = FALSE
	succinct_end_of_round_antagonist_entry = TRUE
	antagonist_panel_tab_type = null

	/// The mind of this antagonist's master, leader, and so forth.
	var/datum/mind/master

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		if (master && istype(master, /datum/mind))
			src.master = master
			src.master.subordinate_antagonists += src
		. = ..()

	remove_self()
		src.master.subordinate_antagonists -= src

		. = ..()
