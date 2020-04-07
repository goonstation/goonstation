var/list/dirty_keystates = list()

#define MODIFIER_NONE   0x0000
#define MODIFIER_SHIFT  0x0001
#define MODIFIER_ALT    0x0002
#define MODIFIER_CTRL   0x0004
//o no
//defines in here
//o noooo

/client
	var
		key_state = 0
		last_keys = 0
		keys_dirty = 0
		keys_modifier = 0

		keys_remove_next_process = 0

		datum/keymap/keymap

	verb
		keydown(key as text)
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


		keyup(key as text)
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

		force_keyup(keys as text)
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

	Click(atom/object, location, control, params)
		if(hellbanned && prob(click_drops)) //Drop some of their clicks
			if(prob(2)) fake_lagspike()
			return

		object.RawClick(location, control, params) //Required since atom/Click is effectively broken for some reason, and sometimes you just need it. If you have a better idea let me know.

		var/list/parameters = params2list(params)

		if (src.mob.mob_flags & SEE_THRU_CAMERAS)
			if(isturf(object))
				var/turf/T = object
				if (!length(T.cameras))
					return
				else
					if (parameters["right"])
						object.examine()


		if (parameters["drag"] == "middle") //fixes exploit that basically gave everyone access to an aimbot
			return

		if(findtext( control, "viewport" ))
			var/datum/viewport/vp = getViewportById(control)
			if(vp && vp.clickToMove && object && isturf(object) && (mob.type == /mob/living/intangible/blob_overmind || mob.type == /mob/dead/aieye))//NYI: Replace the typechecks with something Better.
				mob.loc = object
				return
		//In case we receive a dollop of modifier keys with the Click() we should force a keydown immediately.
		if(parameters["ctrl"])
			src.keydown("CTRL")
		if(parameters["alt"])
			src.keydown("ALT")
		if(parameters["shift"])
			src.keydown("SHIFT")

		if(src.buildmode)
			if (src.buildmode.is_active)
				//..() // temp fix for buildmode buttons
				buildmode.build_click(object, location, control, parameters)
				return

		if (parameters["left"])	//Had to move this up into here as the clickbuffer was causing issues.
			var/list/contexts = mob.checkContextActions(object)
			if(contexts.len)
				mob.showContextActions(contexts, object)
				return

		var/mob/user = usr
		// super shit hack for swapping hands over the HUD, please replace this then murder me
		if (istype(object, /obj/screen) && (!parameters["middle"] || istype(object, /obj/screen/ability)) && !istype(user, /mob/dead/target_observer/mentor_mouse_observer))
			if (istype(usr, /mob/dead/target_observer))
				return
			var/obj/screen/S = object
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
				if( get_dist(t, get_turf(mob)) < 5 )
					src.stathover = t
					src.stathover_start = get_turf(mob)

		// if (parameters["left"])	//Had to move this up into here as the clickbuffer was causing issues.
		// 	var/list/contexts = mob.checkContextActions(object)
		// 	if(contexts.len)
		// 		mob.showContextActions(contexts, object)
		// 		return

		if(prob(10) && user.traitHolder && iscarbon(user) && isturf(object.loc) && user.traitHolder.hasTrait("clutz"))
			var/list/filtered = list()
			for(var/atom/movable/A in view(1, src.mob))
				if(A == object || !isturf(A.loc) || !isobj(A) && !ismob(A)) continue
				filtered.Add(A)
			if(filtered.len) object = pick(filtered)

		var/next = user.click(object, parameters, location, control)

		if (isnum(next) && src.preferences.use_click_buffer && src.queued_click != object && next <= max(user.click_delay, user.combat_click_delay))
			src.queued_click = object
			SPAWN_DBG(next+1)
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

	proc/set_keymap(datum/keymap/map)
		src.keymap = map

	proc/setup_macros()

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
			boutput(src, "<span style=\"color:blue\">WASD mode toggled [!wasd ? "on" : "off"]. Note that this setting will not save unless you manually do so in Character Preferences.</style>")
			src.mob.reset_keymap()
			return 1

		return 0

/mob
	var
		move_scheduled = 0
		last_move_ticklag = MIN_TICKLAG //if ticklag changes big inc, can interrupt hold-press. we needa save this to counteract!
	proc
		keys_changed(keys, changed)
			set waitfor = 0 // prevent shitty code from locking up the main input loop

			// stub

		process_move(keys)
			// stub

		attempt_move()
			src.internal_process_move(src.client ? src.client.key_state : 0)

		recheck_keys()
			if (src.client) keys_changed(src.client.key_state, 0xFFFF) //ZeWaka: Fix for null.key_state


		//mbc : so this is fucky : ticklag values of 0.42 and 0.21 just dont work here.
		//i dont understand why. it *must* be a rounding error or math thing. i couldnt find it sorry bro
		//ALSO last_move_ticklag, it compensates for the change in ticklag while we hold a key. It's also not consistent at all values, probably rounding errors again
		//ticklag values that are multiples of 0.2 appear to work best  :)  so i've set the time dilation thing to move in 0.2inc notches.
		internal_process_move(keys)
			var/delay = src.process_move(keys)
			if (isnull(delay))
				return

			var/actual_delay = max(ceil(delay / world.tick_lag), 1) * world.tick_lag
			var/next = world.time + actual_delay
			var/lmt = max(last_move_ticklag - world.tick_lag, 0)

			// Tolerance of 0.01 seconds due to byond float weirdness -Spy
			if ((src.move_scheduled - world.time) <= 0.01 + lmt || src.move_scheduled + lmt > next)

				src.move_scheduled = next
				SPAWN_DBG(max( actual_delay, world.tick_lag-0.01))
					src.internal_process_move(src.client ? src.client.key_state : 0)

			last_move_ticklag = world.tick_lag

/datum/keymap
	var/list/keys = list()

	New(data)
		if (data)
			for (var/key in data)
				keys[parse_keybind(key)] = data[key]

	proc/merge(datum/keymap/other)
		for (var/key in other.keys)
			src.keys[key] = other.keys[key]

	proc/overwrite_by_action(datum/keymap/writer)
		if (!writer) return
		for (var/key in writer.keys)
			var/new_key = key
			var/act = writer.keys[key]

			src.keys[new_key] = act
			message_coders("added: [new_key]: [act]")

			for (var/oldkey in src.keys)
				var/k = src.keys[oldkey]
				message_coders("key: [k], [act]")
				if (text2num(act))
					if (src.keys[oldkey] == text2num(act))
						message_coders("rem1: [k], [act]")
						src.keys.Remove(oldkey)
						break
				else
					if (src.keys[oldkey] == act)
						message_coders("rem2: [k], [act]")
						src.keys.Remove(oldkey)
						break

			var/t2n = text2num(act)
			if (t2n)
				src.keys[new_key] = t2n
			else
				src.keys[new_key] = act

	proc/parse_keybind(keybind)
		//Checks the input key and converts it to a usable format
		//Wants input in the format "CTRL+F", as an example.
		var/req_modifier = 0 //The modifier(s) associated with this key
		var/bound_key //The final key that should be bound
		var/list/keys = splittext(keybind, "+")

		if(keys.len > 1)
			//We have multiple keys (modifiers + normal ones)
			for(var/key in keys)
				//If it's a modifier key, then change the required modifier
				switch(key)
					if("ALT")
						req_modifier |= MODIFIER_ALT
					if("SHIFT")
						req_modifier |= MODIFIER_SHIFT
					if("CTRL")
						req_modifier |= MODIFIER_CTRL
					else
						//If it's not a modifier then use that as the target to bind
						bound_key = key
		else
			//Only one key. Force it to be a command
			bound_key = keybind

		ASSERT(bound_key) //If we didn't get a bound key something hecked the heck up.

		return uppertext("[req_modifier][bound_key]")

	proc/unparse_keybind(keytext)
		//Converts the given usable format to a readable format
		//Wants input in the format "0NORTH" or "5D", as an example.
		var/bound_key = ""
		var/modifier = text2num(copytext(keytext, 1, 2)) //The modifier(s) associated with this key (NUM/BITFLAG ONLY)
		var/modifier_string = ""

		if(modifier & MODIFIER_CTRL)
			modifier_string += "CTRL+"
		if(modifier & MODIFIER_ALT)
			modifier_string += "ALT+"
		if(modifier & MODIFIER_SHIFT)
			modifier_string += "SHIFT+"

		bound_key = copytext(keytext, 2)

		ASSERT(bound_key) //If we didn't get a bound key something hecked the heck up.

		return uppertext("[modifier_string][bound_key]")

	proc/parse_action(action)
		if (isnum(action)) //for bitflag actions (KEY_BOLT)
			return key_bitflag_to_stringdesc(action)
		else //must be a string
			return key_string_to_desc(action)

	proc/key_string_to_desc(string)
		//Converts from code-readable action names to human-readable
		//Example: "l_arm" to "Target Left Arm"
		for (var/key in action_names)
			if (string == key)
				return action_names[key]
		//must be a dastardly action verb
		for (var/key in action_verbs)
			if (string == key)
				return action_verbs[key]
		return "not a string in action_names/verbs you fucko"

	proc/key_bitflag_to_stringdesc(bitflag)
		//Converts from bitflag to a human-readable description
		//Assuming we're not passed a combination, because fuck that
		bitflag = num2text(bitflag)
		for (var/key in key_names)
			if (bitflag == key)
				return key_names[key]
		return "not a bitflag in key_names you fucko"

	proc/check_keybind(pressed_key, modifier)
		//If there is a modifier command on this key, then use that
		var/command = keys[uppertext("[modifier][pressed_key]")]
		//Otherwise fall back on the default behaviour
		if(!command) command = keys[uppertext("0[pressed_key]")]
		//DEBUG_MESSAGE("Check keybind for [usr]. Key: [pressed_key], modifier: [modifier]. Found command: [command ? command : "-none-"]")
		return command

/proc/process_keystates()
	for (var/client/C in dirty_keystates)
		var/new_state = C.key_state
		if(C.hellbanned && prob(C.move_drops))
			if(prob(1) && prob(25)) C.fake_lagspike()
			new_state = C.last_keys // lol

		if (new_state != C.last_keys) // !?
			var/mob/M = C.mob
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
	SPAWN_DBG(0)
		while (1)
			process_keystates()
			sleep(world.tick_lag)

/client/Move()
	// you'll be missed
	// -- absolutely noone

	// fuck you.

/datum/bind_set
	var
		name = ""

		keys = 0
		actions = list()
