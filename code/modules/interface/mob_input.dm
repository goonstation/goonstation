
/mob/proc/key_down(var/key)
/mob/proc/key_up(var/key)

/mob/proc/click(atom/target, params)
	//moved the 'actions.interrupt(src, INTERRUPT_ACT)' here to on mob/living
	var/used_ability = src.targeting_ability
	if (!used_ability) used_ability = get_ability_hotkey(src, params)

	if (istype(used_ability, /datum/targetable))
		var/datum/targetable/S = used_ability
		if (S.targeted)
			src.targeting_ability = null
			update_cursor()

			if (!S.target_anything && !ismob(target))
				src.show_text("You have to target a person.", "red")
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (!S.target_in_inventory && !isturf(target.loc) && !isturf(target))
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (S.target_in_inventory && (!(BOUNDS_DIST(src, target) == 0) && !isturf(target) && !isturf(target.loc)))
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (S.check_range && !IN_RANGE(src, target, S.max_range))
				src.show_text("You are too far away from the target.", "red") // At least tell them why it failed.
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (!S.target_ghosts && ismob(target) && (!isliving(target) || iswraith(target) || isintangible(target)))
				src.show_text("It would have no effect on this target.", "red")
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (!S.castcheck(src))
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			actions.interrupt(src, INTERRUPT_ACTION)
			SPAWN(0)
				S.handleCast(target, params)
				if(S)
					if((S.ignore_sticky_cooldown && !S.cooldowncheck()) || (S.sticky && S.cooldowncheck()))
						if(src)
							src.targeting_ability = S
							src.update_cursor()
			return 100

	else if (istype(src.targeting_ability, /obj/ability_button))
		var/obj/ability_button/B = src.targeting_ability

		if (!B.target_anything && !ismob(target) && !istype(target, B))
			src.show_text("You have to target a person.", "red")
			src.targeting_ability = null
			src.update_cursor()
			return 100
		if (!isturf(target.loc) && !isturf(target) && !istype(target, B))
			src.targeting_ability = null
			src.update_cursor()
			return 100
		if (!B.ability_allowed())
			src.targeting_ability = null
			src.update_cursor()
			return 100
		if (istype(target, B))
			return 100
		actions.interrupt(src, INTERRUPT_ACTION)
		SPAWN(0)
			B.execute_ability(target, params)
			src.targeting_ability = null
			src.update_cursor()
		return 100

	if (abilityHolder)
		if (abilityHolder.topBarRendered)
			if (abilityHolder.click(target, params))
				return 100
	//Pull cancel 'hotkey'
	if (src.pulling && BOUNDS_DIST(src, target) > 0)
		if (!islist(params))
			params = params2list(params)
		if(params["ctrl"])
			if (src.pulling)
				unpull_particle(src,pulling)
			src.remove_pulling()

	//circumvented by some rude hack in client.dm; uncomment if hack ceases to exist
	//if (istype(target, /atom/movable/screen/ability))
	//	target:clicked(params)
	if (GET_DIST(src, target) > 0 && src.can_turn())
		set_dir(get_dir_accurate(src, target, FALSE)) // Face the direction of the target

/**
 * This proc is called when a mob double clicks on something with the left mouse button.
 * Return TRUE if the click was handled, FALSE otherwise. Handled doubleclicks will suppress the Click() call that follows.
 * (Note that the Click() call for the *first* click always happens.)
 */
/mob/proc/double_click(atom/target, location, control, list/params)
	if(src.client?.check_key(KEY_EXAMINE) && !src.client?.preferences?.help_text_in_examine)
		if(src.help_examine(target))
			return TRUE

/mob/proc/get_final_help_examine(atom/target)
	. = target.get_help_message(GET_DIST(src, target), src)
	var/list/additional_help_messages = list()
	SEND_SIGNAL(target, COMSIG_ATOM_HELP_MESSAGE, src, additional_help_messages)
	if (length(additional_help_messages))
		if (.)
			additional_help_messages = list(.)	+ additional_help_messages
		. = jointext(additional_help_messages, "\n")
	. = replacetext(trimtext(.), "\n", "<br>")

/mob/proc/help_examine(atom/target)
	var/help = get_final_help_examine(target)
	if (help)
		boutput(src, SPAN_HELPMSG("[help]"))
		return TRUE
	return FALSE

/mob/proc/hotkey(name) //if this gets laggy, look into adding a small spam cooldown like with resting / eating?
	switch (name)
		if ("look_n")
			if(src.can_turn())
				src.set_dir(NORTH)
		if ("look_s")
			if(src.can_turn())
				src.set_dir(SOUTH)
		if ("look_e")
			if(src.can_turn())
				src.set_dir(EAST)
		if ("look_w")
			if(src.can_turn())
				src.set_dir(WEST)
		if ("admin_interact")
			src.admin_interact_verb()
		if ("stop_pull")
			if (src.pulling)
				unpull_particle(src,pulling)
			src.remove_pulling()

/**
	* Return the ability bound to the pressed ability hotkey combination
  */
/mob/proc/get_ability_hotkey(mob/user, parameters)
	if(!parameters["left"]) return
	if(!user?.abilityHolder) return
	if(istype(user.abilityHolder, /datum/abilityHolder/composite))
		var/datum/abilityHolder/composite/holder = user.abilityHolder
		for(var/datum/abilityHolder/H in holder.holders)
			if(parameters["ctrl"] && H.ctrlPower)
				return H.ctrlPower
			if(parameters["alt"] && H.altPower)
				return H.altPower
			if(parameters["shift"] && H.shiftPower)
				return H.shiftPower

	if(parameters["ctrl"] && user.abilityHolder.ctrlPower)
		return user.abilityHolder.ctrlPower
	if(parameters["alt"] && user.abilityHolder.altPower)
		return user.abilityHolder.altPower
	if(parameters["shift"] && user.abilityHolder.shiftPower)
		return user.abilityHolder.shiftPower

/**
	* Additiviely applies keybind styles onto the client's keymap.
	*
	* To be extended upon in children types that want to have special keybind handling.
	*
	* Call this proc first, and then do your specific application of keybind styles.
	*/
/mob/proc/build_keybind_styles(client/C)
	SHOULD_CALL_PARENT(TRUE)

	if (!C.keymap)
		C.keymap = new

	C.apply_keybind("base")

	if (C.preferences?.use_azerty) // runtime : preferences is null? idk why, bandaid for now
		C.apply_keybind("base_azerty")
	if (C.tg_controls)
		C.apply_keybind("base_tg")

/**
	* Applies the client's custom keybind changelist, fetched from the cloud.
	*
	* Called by build_keybind_styles if not resetting the custom keybinds of a u
	*/
/mob/proc/apply_custom_keybinds(client/C)
	PROTECTED_PROC(TRUE)

	if(!C || !C.player)
		//logTheThing(LOG_DEBUG, null, "<B>ZeWaka/Keybinds:</B> Attempted to fetch custom keybinds for [C.ckey] but failed.")
		return

	var/fetched_keylist = C.player?.cloudSaves.getData("custom_keybind_data")
	if (!isnull(fetched_keylist) && fetched_keylist != "") //The client has a list of custom keybinds.
		var/datum/keymap/new_map = new /datum/keymap(json_decode(fetched_keylist))
		C.keymap.overwrite_by_action(new_map)
		C.keymap.on_update(C)

/**
	* Builds the mob's keybind styles, checks for valid movement controllers, and finally sets the keymap.
	*
	* Called on: Login, Vehicle change, WASD/TG/AZERTY toggle, Keybind menu Reset
	*/
/mob/proc/reset_keymap()
	if (src.client)
		src.client.applied_keybind_styles = list() //Reset currently applied styles
		build_keybind_styles(src.client)
		apply_custom_keybinds(src.client)
		var/datum/movement_controller/controller = src.override_movement_controller
		if (controller)
			controller.modify_keymap(src.client)
