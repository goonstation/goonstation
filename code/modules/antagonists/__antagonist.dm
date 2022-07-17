ABSTRACT_TYPE(/datum/antagonist)
/datum/antagonist
	/// Internal ID used to track this type of antagonist. This should *always* be unique between types and subtypes.
	var/id = null
	/// Human-readable name for displaying this antagonist for admin menus, round-end summary, etc.
	var/display_name = null
	/// If TRUE, this antagonist has an associated browser window (ideally with the same ID as itself) that will be displayed in do_popup() by default.
	var/has_info_popup = TRUE
	/// If FALSE, this antagonist will not be displayed at the end of the round.
	var/display_at_round_end = TRUE
	/// If TRUE, no other antagonists can be naturally gained if this one is active. Admins can still manually add new ones.
	var/mutually_exclusive = TRUE
	/// The medal unlocked at the end of the round by succeeding as this antagonist.
	var/success_medal = null


	/// The mind of the player that that this antagonist is assigned to.
	var/datum/mind/owner
	/// How this antagonist was created. Displayed at the end of the round.
	var/assigned_by = ANTAGONIST_SOURCE_ROUND_START
	
	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source)
		. = ..()
		if (!istype(new_owner))
			message_admins("Antagonist datum of type [src.type] and usr [usr] attempted to spawn without a mind. This should never happen!!")
			qdel(src)
			return FALSE
		owner = new_owner
		new_owner.special_role = id
		src.setup_antagonist(do_equip, do_objectives, do_relocate, silent, source)

	/// Calls removal procs to soft-remove this antagonist from its owner. Actual movement or deletion of the datum still needs to happen elsewhere.
	proc/remove_self(take_gear, silent)
		if (take_gear)
			src.remove_equipment()
		
		if (!silent)
			src.announce_removal()
		
		if (owner.special_role == id)
			owner.former_antagonist_roles.Add(owner.special_role)
			owner.special_role = null

	/// Returns TRUE if this antagonist can be assigned to the given mind, and FALSE otherwise. This is intended to be overriden by subtypes; mutual exclusivity and other selection logic is not performed here. 
	proc/is_compatible_with(datum/mind/mind)
		return TRUE

	/// Base proc to set up the antagonist. Depending on arguments, it can spawn equipment, assign objectives, move the player (if applicable), and announce itself.
	proc/setup_antagonist(do_equip, do_objectives, do_relocate, silent, source)
		SHOULD_NOT_OVERRIDE(TRUE)

		src.assigned_by = source

		if (!silent)
			src.announce()

		if (do_equip)
			src.give_equipment()

		if (do_objectives)
			src.assign_objectives()
			if (!silent)
				src.announce_objectives()
		
		if (do_relocate)
			src.relocate()
		
		if (!silent)
			src.do_popup()

	/// Equip the antagonist with abilities, custom equipment, and so on.
	proc/give_equipment()
		return
	
	/// The inverse of give_equipment(). Remove things like changeling abilities, etc. Non-innate things like items should probably be kept.
	proc/remove_equipment()
		return

	/// Move the antagonist to their spawn location, if applicable.
	proc/relocate()
		return

	/// Generate objectives for the antagonist and assign them to the mind.
	proc/assign_objectives()
		return

	// Show the player what objectives they have in their mind.
	proc/announce_objectives()
		var/obj_count = 1
		for (var/datum/objective/objective in owner.objectives)
			if (istype(objective, /datum/objective/crew) || istype(objective, /datum/objective/miscreant))
				continue
			boutput(owner.current, "<b>Objective #[obj_count]:</b> [objective.explanation_text]")
			obj_count++

	/// Display a greeting to the player to inform that they're an antagonist. This can be anything, but by default it's just the name.
	proc/announce()
		boutput(owner.current, "<h3><span class='alert'>You are \a [src.display_name]!</span></h3>")

	/// Display something when this antagonist is removed.
	proc/announce_removal()
		boutput(owner.current, "<h3><span class='alert'>You are no longer \a [src.display_name]!</span></h3>")

	/// Show a popup window for this antagonist. Defaults to using the same ID as the antagonist itself.
	proc/do_popup(override)
		if (has_info_popup || override)
			owner.current.show_antag_popup(!override ? id : override)
	
	/// Returns whether or not this antagonist is considered to have succeeded. By default, this checks all antagonist-specific objectives.
	proc/check_success()
		for (var/datum/objective/objective as anything in owner.objectives)
			if (istype(objective, /datum/objective/crew) || istype(objective, /datum/objective/miscreant))
				continue
			if (!objective.check_completion())
				return FALSE
		return TRUE

	/**
	 * Handle special behavior at the end of the round.
	 * This should always return a list of strings if you want something to be displayed. The default (list each objective and its success state) should be enough for most roles, but for more loosely-defined ones you might want to display other stuff instead.
	 * display_at_round_end will prevent the returned info from being displayed, so an override isn't necessary for antagonists that have things like success medals but that shouldn't pop up after the round ends.
	 */
	proc/handle_round_end(log_data = FALSE)
		. = list()
		if (owner.current)
			// we conjugate assigned_by and display_name manually here,
			// so that the text macro doesn't treat null assigned_by values as their own text and thus display weirdly
			. += "<b>[owner.current]</b> (played by <b>[owner.displayed_key]</b>) was \a [assigned_by + display_name]!"
		else
			. += "<b>[owner.displayed_key]</b> (character destroyed) was \a [assigned_by + display_name]!"
		if (length(owner.objectives))
			var/obj_count = 1
			for (var/datum/objective/objective as anything in owner.objectives)
				if (istype(objective, /datum/objective/crew) || istype(objective, /datum/objective/miscreant))
					continue
				if (objective.check_completion())
					. += "<b>Objective #[obj_count]:</b> [objective.explanation_text] <span class='success'><b>Success!</b></span>"
					if (log_data)
						logTheThing("diary", owner, null,"completed objective: [objective.explanation_text]")
						if (!isnull(objective.medal_name) && !isnull(owner.current))
							owner.current.unlock_medal(objective.medal_name, objective.medal_announce)
				else
					. += "<b>Objective #[obj_count]:</b> [objective.explanation_text] <span class='alert'><b>Failure!</b></span>"
					if (log_data)
						logTheThing("diary", owner, null, "failed objective: [objective.explanation_text]. Womp womp.")
				obj_count++
		if (src.check_success())
			. += "<span class='success'><b>\The [src.display_name] has succeeded!</b></span>"
			if (!isnull(success_medal) && log_data)
				owner.current.unlock_medal(success_medal, TRUE)
		else
			. += "<span class='alert'><b>\The [src.display_name] has failed!</b></span>"
