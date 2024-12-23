/// For inputting data for things like edit-variables, proccall, etc
/// Generally you should only use the associated defines for allowed_types. However, you CAN display anything as a choice for the user, allowing for
/// custom prompts for specific cases. Just make sure the caller can handle the case!
/// @param allowed_types The types of input which are allowed, which the user selects from. The selected type is returned as part of the data_input_result
/// @param custom_title 		If not null, set as the title for the input
///	@param custom_text			If not null, set as the text for the input
/// @param default				The default value, if default_type is chosen as the input type
/// @param default_type  		The default input type
/// @param custom_type_title 	If not null, set as the title for input type selection
/// @param custom_type_message 	If not null, set as the text for input type selection
/// @return 			 		A data_input_result with the parsed input and the selected input type, or both null if we didn't get any data
/client/proc/input_data(list/allowed_types, custom_title = null, custom_message = null, default = null, custom_type_title = null, custom_type_message = null, default_type = null)
	RETURN_TYPE(/datum/data_input_result)
	. = new /datum/data_input_result(null, null) //in case anything goes wrong, return this. Thus, to check for cancellation, check for a null output_type.

	if (!src.holder)
		message_admins("Non-admin client [src.key] somehow tried to input some data. Huh?")
		logTheThing(LOG_DEBUG, src.mob, "somehow attempted to input data via the input_data proc.")
		return

	// clear out invalid options. TODO might want to datumize these at some point
	if (!islist(default))
		allowed_types -= DATA_INPUT_LIST_EDIT
	if (!isnum(default))
		allowed_types -= DATA_INPUT_NUM_ADJUST
		allowed_types -= DATA_INPUT_BITFIELD

	var/input = null 	// The input from the user- usually text, but might be a file or something.
	var/selected_type
	if (length(allowed_types) == 1)
		selected_type = allowed_types[1]
	else
		selected_type = input(custom_type_title || "Which input type?", custom_type_message || "Input Type Selection", default_type) as null|anything in allowed_types //TODO make this a TGUI list once we can indicate defaults on those

	if (selected_type != default_type && selected_type != "JSON" && selected_type != DATA_INPUT_BITFIELD) //clear the default if we aren't using the suggested type
		default = null

	switch(selected_type)
		if (null)
			return

		if (DATA_INPUT_NUM)
			input = input(custom_message  || "Enter number:", custom_title, default) as null|num

		if (DATA_INPUT_TYPE)
			var/stub
			while (!stub)
				stub = input(custom_message  || "Enter part of type:", custom_title) as null|text
				if (!stub)
					boutput(src, SPAN_ALERT("Cancelled."))
					return
				input = get_one_match(stub, /datum, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
				if (isnull(input))
					alert("No types found matching that string.")
					stub = null


		if (DATA_INPUT_COLOR)
			input = input(custom_message  || "Select color:", custom_title, default) as null|color

		if (DATA_INPUT_TEXT)
			input = input(custom_message  || "Enter text:", custom_title, default) as null|message

		if (DATA_INPUT_ICON)
			input = input(custom_message || "Input dmi path or hit OK with empty input if you want to upload") as null|text
			if(isnull(input))
				return
			else if(input == "")
				input = input(custom_message  || "Select icon:", custom_title) as null|icon
			else
				input = get_cached_file(input)
				if(isnull(input))
					boutput(src, SPAN_ALERT("DMI file [input] not found."))
					return
			if (alert("Would you like to associate an icon_state with the icon?", "icon_state", "Yes", "No") == "Yes")
				var/state = input("Enter icon_state:", "icon_state") as null|text
				if (state)
					input = icon(input, state)

		if (DATA_INPUT_BOOL)
			//lines written by the utterly insane
			input = alert(custom_message  || "True or False?", custom_title + (!isnull(default) ? "(Default: [default ? "True" : "False"])" : null), "True", "False") == "True" ? TRUE : FALSE

		if (DATA_INPUT_BITFIELD)
			input = tgui_input_bitfield(usr, custom_title, default = default, timeout = 0, autofocus = TRUE)

		if (DATA_INPUT_FILE)
			input = input(custom_message  || "Select file:", custom_title) as null|file

		if (DATA_INPUT_DIR)
			input = input(custom_message  || "Pick direction:", custom_title, default) as null|anything in list("NORTH", "SOUTH", "EAST", "WEST", "NORTHEAST", "SOUTHEAST", "NORTHWEST", "SOUTHWEST")
			switch(input)
				if("NORTH")
					input = NORTH
				if("SOUTH")
					input = SOUTH
				if("EAST")
					input = EAST
				if("WEST")
					input = WEST
				if("NORTHEAST")
					input = NORTHEAST
				if("SOUTHEAST")
					input = SOUTHEAST
				if("NORTHWEST")
					input = NORTHWEST
				if("SOUTHWEST")
					input = SOUTHWEST

		if (DATA_INPUT_JSON)
			input = input(custom_message || "Enter JSON:", custom_title, json_encode(default)) as null|text
			if(isnull(input))
				return
			input = json_decode(input)

		if (DATA_INPUT_REF)
			var/reftext = input("brackets don't matter", custom_title || "Enter ref:", null) as null|text
			input = locate(reftext)
			if (!input)
				input = locate("\[[reftext]\]")
			if (!input)
				boutput(src, SPAN_ALERT("Invalid ref."))
				return

		if (DATA_INPUT_TURF_BY_COORDS)
			var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", null) as null|num
			var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", null) as null|num
			var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", null) as null|num
			input = locate(x, y, z)
			if (!input)
				boutput(src, SPAN_ALERT("Invalid turf."))
				return

		if (DATA_INPUT_REFPICKER)
			input = pick_ref(src.mob)

		if (DATA_INPUT_NEW_INSTANCE)
			var/stub = input(custom_message  || "Enter part of type:", custom_title) as null|text
			if (!stub)
				boutput(src, SPAN_ALERT("Cancelled."))
				return
			input = get_one_match(stub, /datum, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
			if(isnull(input))
				boutput(src, SPAN_ALERT("Cancelled."))
				return
			var/list/arglist = src.get_proccall_arglist()
			if(length(arglist))
				input = new input(arglist(arglist))
			else
				input = new input

		if (DATA_INPUT_NUM_ADJUST)
			input = input("Enter amount to adjust by:", custom_title) as null|num

		if (DATA_INPUT_ATOM_ON_CURRENT_TURF) // this is ugly but it's legacy so WHATEVER
			var/list/possible = list()
			var/turf/T = get_turf(src.mob)
			possible += T.loc
			possible += T
			for (var/atom/A in T)
				possible += A
				for (var/atom/B in A)
					possible += B
			input = input(custom_message || "Select reference:", custom_title || "Reference") as null|mob|obj|turf|area in possible

		if (DATA_INPUT_NULL) // this is the one case a null output is allowed- we check to ensure the selected input type is this
			input = null //yes i am aware this is a useless statement. Clarity!!!

		if (DATA_INPUT_LIST_BUILD)
			input = build_list()

		if (DATA_INPUT_LIST_EDIT)
			mod_list(default)
			input = default

		if (DATA_INPUT_MOB_REFERENCE)
			input = input(custom_message || "Select a mob:", custom_title) as null|mob in world

		if (DATA_INPUT_MATRIX)
			var/matrix/M = default
			if (!M) M = matrix()
			default = "[M.a],[M.b],[M.c],[M.d],[M.e],[M.f]"
			input = input("Create a matrix:  (format: \"a,b,c,d,e,f\" without quotes). Must have a leading 0 for decimals:", custom_title, default) as null|message
			if(input == null)
				boutput(src, SPAN_ALERT("Cancelled."))
				return

			var/regex/R = new("(\\w*\\.*\\w+)(,|$)", "gi")
			var/list/MV = list()
			var/i = 1
			while (R.Find(input))
				if (i <= 6)
					var/temp = R.group[1]
					MV.Add(text2num(temp))
					i++

			if (length(MV) >= 6)
				input = matrix(MV[1], MV[2], MV[3], MV[4], MV[5], MV[6])

			else
				boutput(src, SPAN_ALERT("Matrix too short. Cancelled."))
				return

		// anything else, we just return a dummy value with the input type and let the caller handle it
		else
			input = selected_type

	if (isnull(input) && selected_type != DATA_INPUT_NULL)
		boutput(src, SPAN_ALERT("Cancelled."))
		return

	// Done with the switch. Now we return whatever we have
	var/datum/data_input_result/result = new(input, selected_type)
	return result

///Iteratively build a new list, then return it.
/client/proc/build_list()
	. = list()
	var/idx = 0
	var/confirm = TRUE
	while(confirm)
		idx++
		confirm = src.mod_list_add(., "Type of element #[idx]")

	if (alert(src, "Use this list?\n[json_encode(.)]", "Confirmation", "Yes", "No") == "No")
		return null

/// A datum holding the data the caller needs- the formatted output itself and the format the src selected (text, JSON, color, etc etc)
/// Functionally a named tuple.
/datum/data_input_result
	var/output
	var/output_type

	New(var/output, var/output_type)
		..()
		src.output = output
		src.output_type = output_type


/// Get a suggested input type based on the thing you're editing
/// @param var_value The value to evaluate
/// @param varname The name of the variable
/// @return Suggested input type for input_data()
/client/proc/suggest_input_type(var_value, varname = null)
	var/default = null

	if (varname == "particles")
		default = DATA_INPUT_PARTICLE_EDITOR

	else if (varname == "filters")
		default = DATA_INPUT_FILTER_EDITOR

	else if (istype(var_value, /matrix))
		if (varname == "color")
			boutput(src, "Variable appears to be <b>COLOR MATRIX</b>.")
			default = DATA_INPUT_COLOR_MATRIX_EDITOR
		else
			boutput(src, "Variable appears to be <b>MATRIX</b>.")
			default = DATA_INPUT_MATRIX

	else if (isnum(var_value))
		boutput(src, "Variable appears to be <b>NUM</b>.")
		default = DATA_INPUT_NUM

	else if (is_valid_color_string(var_value))
		boutput(src, "Variable appears to be <b>COLOR</b>.")
		default = DATA_INPUT_COLOR

	else if (istext(var_value))
		boutput(src, "Variable appears to be <b>TEXT</b>.")
		default = DATA_INPUT_TEXT

	else if (isicon(var_value))
		boutput(src, "Variable appears to be <b>ICON</b>.")
		default = DATA_INPUT_ICON

	else if (istype(var_value, /datum))
		boutput(src, "Variable appears to be <b>REFERENCE</b>.")
		default = DATA_INPUT_NEW_INSTANCE

	else if (islist(var_value))
		boutput(src, "Variable appears to be <b>LIST</b>.")
		default = DATA_INPUT_LIST_EDIT

	else if (isfile(var_value))
		boutput(src, "Variable appears to be <b>FILE</b>.")
		default = DATA_INPUT_FILE

	else if (ispath(var_value))
		boutput(src, "Variable appears to be <b>TYPE</b>.")
		default = DATA_INPUT_TYPE

	else
		boutput(src, "Unable to determine variable type.")

	boutput(src, "\"<tt>[varname || "Variable"]</tt>\" contains: [var_value]")
	if(default == DATA_INPUT_NUM)
		var/direction
		switch(var_value)
			if(1)
				direction = "NORTH"
			if(2)
				direction = "SOUTH"
			if(4)
				direction = "EAST"
			if(8)
				direction = "WEST"
			if(5)
				direction = "NORTHEAST"
			if(6)
				direction = "SOUTHEAST"
			if(9)
				direction = "NORTHWEST"
			if(10)
				direction = "SOUTHWEST"
			else
				direction = null
		if(direction)
			boutput(src, "If a direction, direction is: [direction]")

	return default

/// Refpicker - click thing, get its ref. Tied to the data_input proc via a promise.
/datum/targetable/refpicker
	var/datum/promise/promise = null
	target_anything = TRUE
	targeted = TRUE
	check_range = FALSE
	target_ghosts = TRUE
	lock_holder = FALSE

	castcheck()
		if (usr.client && usr.client.holder)
			return TRUE

	handleCast(var/atom/selected)
		promise.fulfill(selected)

/datum/targetable/refpicker/nonadmin
	castcheck(var/mob/M)
		return TRUE

///Gives the target mob a reference picker ability and returns the atom picked. Synchronous.
/proc/pick_ref(mob/M)
	var/datum/promise/promise = new
	var/datum/targetable/refpicker/abil = new
	abil.promise = promise
	M.targeting_ability = abil
	M.update_cursor()
	return promise.wait_for_value()
