var/list/dirty_keystates = list()

/client
	var/key_state = 0
	var/last_keys = 0
	var/keys_dirty = 0
	var/keys_modifier = 0
	var/skip_next_left_click = FALSE

	var/keys_remove_next_process = 0

	var/datum/keymap/keymap

	verb/keydown(key as text)
		set hidden = 1
		set name = ".keydown"
		set instant = 1

		key = uppertext(key)
		//world << key

		if(key == "ALT")
			keys_modifier |= MODIFIER_ALT
			//return
		else if(key == "SHIFT")
			keys_modifier |= MODIFIER_SHIFT
			//return
		else if(key == "CTRL")
			keys_modifier |= MODIFIER_CTRL
			//return

		if (!src.keymap)
			return

		var/mob/M = src.mob
		var/numkey = text2num(key)
		if(!isnull(numkey) && M.abilityHolder)
			if (M.abilityHolder.actionKey(numkey))
				return
		if(!isnull(numkey) && src.buildmode?.is_active)
			if(src.buildmode.number_key_pressed(numkey, keys_modifier))
				return

		var/action = src.keymap.check_keybind(key, keys_modifier)

		if (isnull(action)) // not bound
			return

		if (istext(action)) // action
			if(!do_action(action))
				src.mob.hotkey(action)

		else
			src.key_state |= action
			src.mob.hotkey(key)
			if (!src.keys_dirty)
				dirty_keystates += src
				src.keys_dirty = world.time //1


	verb/keyup(key as text)
		set hidden = 1
		set name = ".keyup"
		set instant = 1
		key = uppertext(key)
		//mark my words
		//this is all getting rewritten again
		//just you wait
		if(key == "ALT")
			keys_modifier &= ~MODIFIER_ALT
			//return
		else if(key == "SHIFT")
			keys_modifier &= ~MODIFIER_SHIFT
			//return
		else if(key == "CTRL")
			keys_modifier &= ~MODIFIER_CTRL
			//return

		if (!src.keymap)
			return

		var/action = src.keymap.check_keybind(key, 0) //We don't care about keying up modifier commands.
		if (isnull(action)) // not bound
			return

		if (!istext(action)) // key
			if (src.keys_dirty == world.time)
				src.keys_remove_next_process |= action
			else
				src.key_state &= ~action
				if (!src.keys_dirty)
					dirty_keystates += src
					src.keys_dirty = world.time //1

	verb/force_keyup(keys as text)
		set hidden = 1
		set name = ".force_keyup"
		set instant = 1
		//Maybe this can unfuck the macro situation? Perhaps. Hopefully!
		keys = uppertext(keys)
		var/list/keylist = splittext(keys, "+")
		for(var/key in keylist)
			src.keyup(key)
		//keys_modifier = 0

	//super heavy load apparently
	//MouseMove(object,location,control,params)
	//	var/mob/user = usr
	//	user.onMouseDrag(object,location,control,params)

	//also heavy and not used for anything other than debug/test items
	/*
	MouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
		var/mob/user = usr
		user.onMouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
		return
	*/

	//also also heavy and not really uesd for anything important
	/*
	MouseDown(object,location,control,params)
		var/mob/user = usr
		user.onMouseDown(object,location,control,params)
		return
	*/

	MouseUp(object,location,control,params)
		var/mob/user = usr
		user.onMouseUp(object,location,control,params)
		SEND_SIGNAL(user, COMSIG_MOB_MOUSEUP, object,location,control,params)


		//If we click a tile we cannot see (object is null), pass along a Click. Ordinarily, Click() does not recieve mouse events from unseen tiles.
		//Handle the null object by finding the turf that lies in the screenloc of the null click.
		//How should we distinguish whether the original click was 'null' later on if we need to? location will == "map", that might be fine to identify with?
		//(this fixes the behavior of guns not firing if you clicked a hidden tile. now you can actually shoot in the dark or in a small tunnel!)
		if (!object && src.mob)
			var/list/l2 = splittext(params2list(params)["screen-loc"],",")
			if (l2.len >= 2)
				var/list/lx = splittext(l2[1],":")
				var/list/ly = splittext(l2[2],":")

				object = locate(src.mob.x + (text2num(lx[2]) + -1 - ((istext(src.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2),\
								src.mob.y + (text2num(ly[1]) + -1 - 7),\
								src.mob.z)
				if (object)
					src.Click(object,location,control,params)

		return

	DblClick(atom/target, location, control, params)
		var/list/paramslist = params2list(params)
		if (paramslist["button"] == "left")
			var/result = src.mob.double_click(target, location, control, paramslist)
			if(result)
				src.skip_next_left_click = TRUE

	Click(atom/object, location, control, params)
		var/list/parameters = params2list(params)

		if(skip_next_left_click && parameters["button"] == "left")
			skip_next_left_click = FALSE
			return

		object.RawClick(location, control, params) //Required since atom/Click is effectively broken for some reason, and sometimes you just need it. If you have a better idea let me know.

		if (admin_intent)
			src.mob.admin_interact(object,parameters)
			return

		if (src.mob.mob_flags & SEE_THRU_CAMERAS)
			if(isturf(object))
				var/turf/T = object
				if (!length(T.camera_coverage_emitters))
					return
				else
					if (parameters["right"])
						src.mob.examine_verb(object)


		if (parameters["drag"] == "middle") //fixes exploit that basically gave everyone access to an aimbot
			return

		if(findtext( control, "viewport" ))
			var/datum/viewport/vp = getViewportById(control)
			if(vp && vp.clickToMove && object && isturf(object) && isintangible(mob))//NYI: Replace the typechecks with something Better.
				mob.set_loc(object)
				return
		//In case we receive a dollop of modifier keys with the Click() we should force a keydown immediately.
		if(parameters["ctrl"])
			src.keydown("CTRL")
		if(parameters["alt"])
			src.keydown("ALT")
		if(parameters["shift"] && !(src.mob.mob_flags & IGNORE_SHIFT_CLICK_MODIFIER))
			src.keydown("SHIFT")

		if(src.buildmode)
			if (src.buildmode.is_active)
				//..() // temp fix for buildmode buttons
				buildmode.build_click(object, location, control, parameters)
				return

		if (parameters["left"])	//Had to move this up into here as the clickbuffer was causing issues.
			var/list/contexts = mob.checkContextActions(object)

			if(length(contexts))
				mob.showContextActions(contexts, object)
				return

		var/mob/user = usr
		// super shit hack for swapping hands over the HUD, please replace this then murder me
		if (istype(object, /atom/movable/screen) && (!parameters["middle"] || istype(object, /atom/movable/screen/ability)) && !istype(user, /mob/dead/target_observer/mentor_mouse_observer))
			if (istype(usr, /mob/dead/target_observer))
				return
			var/atom/movable/screen/S = object
			S.clicked(parameters)
			return


		if(src.keys_modifier) //Perhaps evaluating a heap of keymaps is not the best idea if we're only plain and simply clicking something
			//But we will make "click" available as a bindable thing
			var/action = src.keymap.check_keybind("CLICK", keys_modifier)
			if(istext(action))
				if(src.do_action(action)) return

		//The ugly hack lives for now
		if((src.tg_controls && src.keys_modifier == MODIFIER_ALT ) || \
			(src.keys_modifier == (MODIFIER_ALT | MODIFIER_SHIFT | MODIFIER_CTRL)) )

			if( stathover )
				stathover = null
			else
				var/turf/t = get_turf(object)
				if( GET_DIST(t, get_turf(mob)) < 5 )
					src.stathover = t
					src.stathover_start = get_turf(mob)

		if(prob(10) && user.traitHolder && iscarbon(user) && isturf(object.loc) && user.traitHolder.hasTrait("clutz"))
			var/list/filtered = list()
			for(var/atom/movable/A in view(1, src.mob))
				if(A == object || !isturf(A.loc) || !ismovable(A) || !A.mouse_opacity) continue
				filtered.Add(A)
			if(filtered.len) object = pick(filtered)

		var/next = user.click(object, parameters, location, control)

		if (isnum(next) && src.preferences.use_click_buffer && src.queued_click != object && next <= max(user.click_delay, user.combat_click_delay))
			src.queued_click = object
			SPAWN(next+1)
				if (src.queued_click == object)
					user.click(object, parameters, location, control)
					src.queued_click = 0
		return ..()


	proc/check_key(key)
		//Checks if every input key is pressed
		return (src.key_state & key) == key

	proc/check_any_key(keys)
		//Checks if any of the input keys are pressed
		return (src.key_state & keys)

		// oh god
		/*
		I have removed a heap of commented out shit.
		Just imagine a huge block of convoluted hellcode that would make your toes curl in order to give context to the above and below comments.
		-Spy
		*/
		//hi yes we don't care about you anymore

	proc/do_action(var/action)
		//Calls an action verb on the mob. Returns 1 if it took an action, 0 if it didn't.
		var/verb_ = action_verbs[action]
		if (verb_)
			winset(src, null, "command=\"[verb_]\"")
			//DEBUG_MESSAGE("Sent command \"[verb_]\", mapwindow.map.focus = [winget(src, "mapwindow.map", "focus")]")
			if(winget(src, "mapwindow.map", "focus") == "false")
				//DEBUG_MESSAGE("Forcing keys_modifier to 0")
				keys_modifier = 0

			return 1

		else if (action == "togglewasd")
			// shitty hack, fuck it for now
			var/wasd = src.preferences.use_wasd
			src.preferences.use_wasd = !wasd
			//set_macro(src.preferences.use_wasd ? "macro_wasd" : "macro_arrow")
			boutput(src, "<span class='notice'>WASD mode toggled [!wasd ? "on" : "off"]. Note that this setting will not save unless you manually do so in Character Preferences.</style>")
			src.mob.reset_keymap()
			return 1

		return 0

/mob

	proc/keys_changed(keys, changed)
		set waitfor = 0
		//SHOULD_NOT_SLEEP(TRUE) // prevent shitty code from locking up the main input loop - commenting out for now because out of scope
		// stub

	proc/recheck_keys()
		keys_changed(src.client?.key_state, 0xFFFF) //ZeWaka: Fix for null.key_state

	// returns TRUE if it schedules a move
	proc/internal_process_move(keys)
		. = FALSE
		var/delay = src.process_move(keys)
		if (isnull(delay))
			return FALSE

		if (client) // should prevent stuck directions when reconnecting
			. = TRUE

/proc/process_keystates()
	for (var/client/C in dirty_keystates)
		var/new_state = C.key_state
		if (new_state != C.last_keys) // !?
			var/mob/M = C.mob
			usr = M
			M.keys_changed(new_state, new_state ^ C.last_keys)
			C.last_keys = new_state

		if (C.keys_remove_next_process) //gotta call keys_changed again to read the keyups
			C.key_state &= ~C.keys_remove_next_process
			C.keys_remove_next_process = 0

			var/mob/M = C.mob
			M.keys_changed(C.key_state, C.key_state ^ C.last_keys)
			C.last_keys = C.key_state

		C.keys_dirty = 0
	dirty_keystates.len = 0

/proc/start_input_loop()
	SPAWN(0)
		while (1)
			process_keystates()

			for(var/client/C as anything in clients) // as() is ok here since we nullcheck
				C?.mob?.internal_process_move(C.key_state)

			for(var/datum/aiHolder/ai as anything in ai_move_scheduled) // as() is ok here since we nullcheck
				if (ai?.move_target)
					ai.move_step()

			sleep(world.tick_lag)
