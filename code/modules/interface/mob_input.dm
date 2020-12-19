
/mob/proc/key_down(var/key)
/mob/proc/key_up(var/key)

/mob/proc/click(atom/target, params)
	//moved the 'actions.interrupt(src, INTERRUPT_ACT)' here to on mob/living

	if (src.targeting_ability)
		if (istype(src.targeting_ability, /datum/targetable))
			var/datum/targetable/S = src.targeting_ability
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
			if (S.target_in_inventory && ( get_dist(src, target) > 1 && !isturf(target) && !isturf(target.loc)))
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (S.check_range && (get_dist(src, target) > S.max_range))
				src.show_text("You are too far away from the target.", "red") // At least tell them why it failed.
				if(S.sticky)
					src.targeting_ability = S
					update_cursor()
				return 100
			if (!S.can_target_ghosts && ismob(target) && (!isliving(target) || iswraith(target) || isintangible(target)))
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
			SPAWN_DBG(0)
				S.handleCast(target)
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
			SPAWN_DBG(0)
				B.execute_ability(target)
				src.targeting_ability = null
				src.update_cursor()
			return 100

	if (abilityHolder)
		if (abilityHolder.topBarRendered)
			if (abilityHolder.click(target, params))
				return 100
	if(SEND_SIGNAL(src, COMSIG_MOB_CLICK, target, params) & RETURN_CANCEL_CLICK)
		return 100
	//Pull cancel 'hotkey'
	if (src.pulling && get_dist(src,target) > 1)
		if (!islist(params))
			params = params2list(params)
		if(params["ctrl"])
			if (src.pulling)
				unpull_particle(src,pulling)
			src.pulling = null

	//circumvented by some rude hack in client.dm; uncomment if hack ceases to exist
	//if (istype(target, /obj/screen/ability))
	//	target:clicked(params)
	if (get_dist(src, target) > 0)
		if(!src.dir_locked)
			set_dir(get_dir(src, target))
			if(dir & (dir-1))
				if (dir & EAST)
					set_dir(EAST)
				else if (dir & WEST)
					set_dir(WEST)

/mob/proc/hotkey(name) //if this gets laggy, look into adding a small spam cooldown like with resting / eating?
	switch (name)
		if ("look_n")
			if(!dir_locked)
				src.set_dir(NORTH)
		if ("look_s")
			if(!dir_locked)
				src.set_dir(SOUTH)
		if ("look_e")
			if(!dir_locked)
				src.set_dir(EAST)
		if ("look_w")
			if(!dir_locked)
				src.set_dir(WEST)
		if ("admin_interact")
			src.admin_interact_verb()
		if ("stop_pull")
			if (src.pulling)
				unpull_particle(src,pulling)
			src.pulling = null

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

	if(!C || !C.cloud_available())
		//logTheThing("debug", null, null, "<B>ZeWaka/Keybinds:</B> Attempted to fetch custom keybinds for [C.ckey] but failed.")
		return

	var/fetched_keylist = C.cloud_get("custom_keybind_data")
	if (!isnull(fetched_keylist)) //The client has a list of custom keybinds.
		var/datum/keymap/new_map = new /datum/keymap(json_decode(fetched_keylist))
		C.keymap.overwrite_by_action(new_map)

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
		if (src.use_movement_controller)
			var/datum/movement_controller/controller = src.use_movement_controller.get_movement_controller()
			if (controller)
				controller.modify_keymap(src.client)
