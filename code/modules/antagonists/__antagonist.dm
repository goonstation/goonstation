ABSTRACT_TYPE(/datum/antagonist)
/datum/antagonist
	/// Internal ID used to track this type of antagonist. This should *always* be unique between types and subtypes.
	var/id = null
	/// Human-readable name for displaying this antagonist for admin menus, round-end summary, etc.
	var/display_name = null
	/// The icon state that should be used for the antagonist overlay for this antagonist type. Icons may be found in `icons/mob/antag_overlays.dmi`.
	var/image/antagonist_icon = "generic"

	/// If TRUE, this antagonist has an associated browser window (ideally with the same ID as itself) that will be displayed in do_popup() by default.
	var/has_info_popup = TRUE
	/// If TRUE, this antagonist will not have their own entry in the end of round credits antagonists tab, rather they will be displayed in a list below the primary entries.
	var/succinct_end_of_round_antagonist_entry = FALSE
	/// The type of tab that this antagonist type should be displayed under on the admin antagonist panel.
	var/antagonist_panel_tab_type = /datum/antagonist_panel_tab/generic
	/// If TRUE, no other antagonists can be naturally gained if this one is active. Admins can still manually add new ones.
	var/mutually_exclusive = TRUE
	/// The medal unlocked at the end of the round by succeeding as this antagonist.
	var/success_medal = null
	/// If TRUE, the antag status will be removed when the person dies (changeling critters etc.)
	var/remove_on_death = FALSE
	/// If TRUE, the antag status will be removed when the person is cloned (zombies etc.)
	var/remove_on_clone = FALSE
	/// If TRUE, the equipment is not removed on death. Only works if remove_on_death is TRUE.
	var/keep_equipment_on_death = FALSE


	/// The mind of the player that that this antagonist is assigned to.
	var/datum/mind/owner
	/// Does the owner of this antagonist role use their normal name set in character preferences as opposed to being assigned a random or chosen name?
	var/uses_pref_name = TRUE
	/// Whether the addition or removal of this antagonist role is announced to the player.
	var/silent = FALSE
	/// How this antagonist was created. Displayed at the end of the round.
	var/assigned_by = ANTAGONIST_SOURCE_ROUND_START
	/// Pseudo antagonists are not "real" antagonists, as determined by the round. They have the abilities, but do not have objectives and ideally should not considered antagonists for the purposes of griefing rules, etc.
	var/pseudo = FALSE
	/// VR antagonists, similar to pseudo antagonists, are not real antagonists. They lack some exploitative abilities, are not relocated, and are removed on death.
	var/vr = FALSE
	/// The objectives assigned to the player by this specific antagonist role.
	var/list/datum/objective/objectives = list()
	/// The faction given to the player by this antagonist role for AI targeting purposes.
	var/faction = list()
	/// Used in lieu of the id for antag_popups.dm
	var/popup_name_override
	/// Set when the antagonist is in the process of being removed, to prevent double removals.
	var/removing = FALSE
	/// Link to this antagonist's wiki page
	var/wiki_link = null
	/// Saved value of `do_equip` so we know if this antag was spawned with gear
	var/did_equip = FALSE

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup)
		. = ..()
		if (!istype(new_owner))
			message_admins("Antagonist datum of type [src.type] and usr [usr] attempted to spawn without a mind. This should never happen!!")
			qdel(src)
			return FALSE
		if (!src.is_compatible_with(new_owner))
			qdel(src)
			return FALSE
		src.owner = new_owner
		src.pseudo = do_pseudo
		src.vr = do_vr
		if (!do_pseudo && !do_vr) // there is a special place in code hell for mind.special_role
			LAZYLISTADD(antagonists["[src.id]"], src)

			new_owner.special_role = id
			if (source == ANTAGONIST_SOURCE_ADMIN)
				ticker.mode.Agimmicks |= new_owner
			else
				ticker.mode.traitors |= new_owner // same with this variable in particular, but it's necessary for antag HUDs
		if (do_vr)
			src.pseudo = TRUE
			src.remove_on_death = TRUE
			src.remove_on_clone = TRUE
			do_equip = TRUE
			do_objectives = FALSE
			do_relocate = FALSE
			silent = TRUE
		src.setup_antagonist(do_equip, do_objectives, do_relocate, silent, source, late_setup)

		if (QDELETED(src))
			return FALSE
		RegisterSignal(src.owner, COMSIG_MIND_ATTACH_TO_MOB, PROC_REF(mind_attach))
		RegisterSignal(src.owner, COMSIG_MIND_DETACH_FROM_MOB, PROC_REF(mind_detach))
		src.owner.antagonists.Add(src)

	proc/transfer_to(datum/mind/target, take_gear, source, silent = FALSE)
		remove_self(take_gear, source)
		owner.former_antagonist_roles.Add(owner.special_role)

		owner.special_role = null // this isn't ideal, since the system should support multiple antagonists. once special_role is worked around, this won't be an issue
		UnregisterSignal(src.owner, COMSIG_MIND_ATTACH_TO_MOB)
		UnregisterSignal(src.owner, COMSIG_MIND_DETACH_FROM_MOB)

		src.owner = target
		src.owner.special_role = id
		src.setup_antagonist(FALSE, FALSE, FALSE, silent, source, FALSE)
		src.owner.antagonists.Add(src)
		RegisterSignal(src.owner, COMSIG_MIND_ATTACH_TO_MOB, PROC_REF(mind_attach))
		RegisterSignal(src.owner, COMSIG_MIND_DETACH_FROM_MOB, PROC_REF(mind_detach))


	disposing()
		if (owner && !src.pseudo)
			LAZYLISTREMOVE(antagonists["[src.id]"], src)
			if (isnull(antagonists["[src.id]"]))
				antagonists -= "[src.id]"

			owner.former_antagonist_roles.Add(src.id)
			owner.special_role = null // this isn't ideal, since the system should support multiple antagonists. once special_role is worked around, this won't be an issue
			if (src.assigned_by == ANTAGONIST_SOURCE_ADMIN)
				ticker.mode.Agimmicks.Remove(src.owner)
			else
				ticker.mode.traitors.Remove(src.owner)
		..()

	/// Calls removal procs to soft-remove this antagonist from its owner. Actual movement or deletion of the datum still needs to happen elsewhere.
	proc/remove_self(take_gear = TRUE, source)
		src.removing = TRUE
		if (take_gear)
			src.remove_equipment()

		src.remove_objectives()

		if (!src.pseudo)
			src.remove_from_image_groups()

			if (!src.silent)
				src.announce_removal(source)
				src.announce_objectives()

	/// Returns TRUE if this antagonist can be assigned to the given mind, and FALSE otherwise. This is intended to be special logic, overriden by subtypes; mutual exclusivity and other selection logic is not performed here.
	proc/is_compatible_with(datum/mind/mind)
		return TRUE

	/// Base proc to set up the antagonist. Depending on arguments, it can spawn equipment, assign objectives, move the player (if applicable), and announce itself.
	proc/setup_antagonist(do_equip, do_objectives, do_relocate, silent, source, late_setup)
		set waitfor = FALSE
		SHOULD_NOT_OVERRIDE(TRUE)

		src.assigned_by = source
		src.silent = silent

		// Late setup has special logic, and is used for jobs like latejoining traitors that lack uplinks if given their equipment before their job.
		// It will pause the setup proc for up to 60 seconds by sleeping every second, then checking if the owner's assigned role exists.
		// If it does, then the setup will continue. If late setup is still failing after a minute, we message admins to let them know.
		if (late_setup)
			for (var/i in 1 to 60)
				if (QDELETED(src) || !src.owner)
					qdel(src)
					return
				if (src.owner.assigned_role)
					break
				sleep(1 SECOND)
			if (!src.owner.assigned_role)
				message_admins("Antagonist datum of type [src.type] failed to properly late setup after 60 seconds. Report this to a coder.")

		src.did_equip = do_equip
		if (do_equip)
			src.give_equipment()
			if (!src.uses_pref_name)
				src.owner.current.bioHolder.mobAppearance.flavor_text = null
		else
			src.alt_equipment()

		if (src.pseudo) // For pseudo antags, objectives and announcements don't happen
			return

		src.add_to_image_groups()

		if (src.faction)
			LAZYLISTADDUNIQUE(src.owner.current?.faction, src.faction)

		if (!src.silent)
			src.announce()
			src.do_popup()

		if (do_objectives)
			src.assign_objectives()
			if (!src.silent)
				src.announce_objectives()

		if (do_relocate)
			src.relocate()

	proc/unsilence(announce=TRUE)
		src.silent = FALSE
		if (announce)
			src.announce()
			src.do_popup()

	proc/get_antag_icon_image()
		RETURN_TYPE(/image)
		var/image/image = image('icons/mob/antag_overlays.dmi', icon_state = src.antagonist_icon)
		image.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
		image.plane = PLANE_ANTAG_ICONS
		. = image

	proc/add_to_image_groups()
		if (!src.antagonist_icon)
			return

		var/datum/client_image_group/antagonist_image_group = get_image_group(CLIENT_IMAGE_GROUP_ALL_ANTAGONISTS)
		antagonist_image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())

		if (antagonists_see_each_other)
			antagonist_image_group.add_mind(src.owner)

	proc/remove_from_image_groups()
		var/datum/client_image_group/antagonist_image_group = get_image_group(CLIENT_IMAGE_GROUP_ALL_ANTAGONISTS)
		antagonist_image_group.remove_mind_mob_overlay(src.owner)

		if (antagonists_see_each_other)
			antagonist_image_group.remove_mind(src.owner)

	/// Equip the antagonist with abilities, custom equipment, and so on.
	proc/give_equipment()
		return

	/// Fallback in case the antag must have some level of initalization even with no equipment.
	proc/alt_equipment()
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

	/// Handle this antagonist entering cryogenic storage, possibly temporarily.
	proc/handle_cryo()
		return
	/// Handle this antagonist entering cryogenic storage permanently
	proc/handle_perma_cryo()
		return

	/// Remove objectives from the antagonist and the mind.
	proc/remove_objectives()
		for (var/datum/objective/objective in src.objectives)
			src.owner.objectives.Remove(objective)
			src.objectives.Remove(objective)
			qdel(objective)

	// Show the player what objectives they have in their mind.
	proc/announce_objectives()
		var/obj_count = 1
		for (var/datum/objective/objective in owner.objectives)
			boutput(owner.current, "<b>Objective #[obj_count]:</b> [objective.explanation_text]")
			obj_count++

	/// Display a greeting to the player to inform that they're an antagonist. This can be anything, but by default it's just the name.
	proc/announce()
		boutput(owner.current, SPAN_ALERT("<h1 class='system'>You are \a [src.display_name]!</h1>"))

	/// Display something when this antagonist is removed.
	proc/announce_removal(source)
		boutput(owner.current, SPAN_ALERT("<h1 class='system'>You are no longer \a [src.display_name]!</h1>"))

	/// Show a popup window for this antagonist. Defaults to using the same ID as the antagonist itself.
	proc/do_popup()
		if (has_info_popup || popup_name_override)
			owner.current.show_antag_popup(popup_name_override ? popup_name_override : id)

	/// Returns whether or not this antagonist is considered to have succeeded. By default, this checks all antagonist-specific objectives.
	proc/check_success()
		for (var/datum/objective/objective as anything in owner.objectives)
			if (istype(objective, /datum/objective/crew))
				continue
			if (!objective.check_completion())
				return FALSE
		return TRUE

	/// Handle special behavior at the end of the round, such as awarding medals.
	proc/handle_round_end()
		if (!length(src.objectives) || !src.check_success())
			return

		src.owner.current.unlock_medal("MISSION COMPLETE", TRUE)
		if (!isnull(src.success_medal))
			src.owner.current.unlock_medal(src.success_medal, TRUE)

	/**
	 *	Returns a list of data to be passed to the end of round credits pertaining to this antagonist, such as items purchased, units of blood drank, and so forth.
	 *	Should return a list of "name"-"value" associative lists.
	 *	If an item list utilising item icons is to be used, the "type" index should be set to "itemList", and "value" should itself be a list of "iconBase64"-"name" associative lists.
	 */
	proc/get_statistics()
		return

	proc/on_death()
		if (src.remove_on_death)
			src.owner.remove_antagonist(src, ANTAGONIST_REMOVAL_SOURCE_DEATH, !keep_equipment_on_death)

	proc/mind_attach(source, mob/new_mob, mob/old_mob)
		if ((issilicon(new_mob) || isAI(new_mob)) && !(issilicon(old_mob) || isAI(old_mob)))
			src.borged()

	proc/mind_detach(source, mob/old_mob, mob/new_mob)
		if ((issilicon(old_mob) || isAI(old_mob)) && !(issilicon(new_mob) || isAI(new_mob)))
			src.unborged()

	///Called when the player is made into a cyborg or AI
	proc/borged()
		return

	///Called when the player is no longer a cybrorg or AI
	proc/unborged()
		return

//this is stupid, but it's more reliable than trying to keep signals attached to mobs
/mob/death()
	if (src.mind)
		for (var/datum/antagonist/antag in src.mind.antagonists)
			antag.on_death()
	..()
