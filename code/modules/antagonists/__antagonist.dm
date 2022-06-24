/datum/antagonist
	/// Internal ID used to track this type of antagonist. This should *always* be unique between types and subtypes.
	var/id = null
	/// Human-readable name for displaying this antagonist for admin menus, round-end summary, etc.
	var/display_name = "traitor tot"
	/// The mind of the player that that this antagonist is assigned to.
	var/datum/mind/owner
	/// If TRUE, this antagonist has an associated browser window that will be displayed on announce.
	var/has_info_popup = TRUE
	
	New(datum/mind/M, do_equip = TRUE, do_objectives = TRUE, do_relocate = TRUE, silent = FALSE)
		. = ..()
		if (!M)
			DEBUG_MESSAGE("Antagonist datum of type [src.type] and usr [usr] attempted to spawn without a mind. This should never happen!!")
			qdel(src)
			return FALSE
		owner = M
		M.special_role = id
		src.setup_antagonist(do_equip, do_objectives, do_relocate, silent)

	/// Base proc to set up the antagonist. It can call equip procs, assigns objectives, and announces itself to the player.
	proc/setup_antagonist(do_equip, do_objectives, do_relocate, silent)
		SHOULD_NOT_OVERRIDE(TRUE)

		if (!silent)
			src.announce()

		if (do_equip)
			src.give_equipment()

		if (do_objectives)
			src.assign_objectives()
			if (!silent)
				announce_objectives()
		
		if (do_relocate)
			src.relocate()
		
		if (!silent)
			src.do_popup()

	/// Equip the antagonist with abilities, custom equipment, and so on.
	proc/give_equipment()
		return
	
	/// The inverse of give_equipment. Remove things like changeling abilities, etc. Non-innate things like items should probably be kept.
	proc/remove_equipment()
		return

	/// Move the antagonist to their spawn location, if applicable.
	proc/relocate()
		return

	/// Generate objectives for the antagonist and assign them to the mind.
	proc/assign_objectives()
		return

	// Show the player what objectives they have.
	proc/announce_objectives()
		var/obj_count = 1
		for (var/datum/objective/O in owner.objectives)
			boutput(owner.current, "<b>Objective #[obj_count]:</b> [O.explanation_text]")
			obj_count++

	/// Give some preliminary information about this antagonist to the player. By default, this is just the name.
	proc/announce()
		boutput(owner.current, "<h3><span class='alert'>You are \a [src.display_name]!</span></h3>")

	/// Show a defined popup for this antagonist, if there is one.
	proc/do_popup(override)
		if (has_info_popup || override)
			owner.current.show_antag_popup(!override ? id : override)

	/// Display something when this antagonist is removed.
	proc/announce_removal()
		boutput(owner.current, "<h3><span class='alert'>You are no longer \a [src.display_name]!</span></h3>")
		return
