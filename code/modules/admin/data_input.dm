/// For inputting data for things like edit-variables, proccall, etc
/// @param allowed_types The types of input which are allowed, which the src selects from. The selected type is returned as part of the data_input_result
/// @param custom_title 		If not null, set as the title for the input
///	@param custom_text			If not null, set as the text for the input
/// @param default				The default value, if default_type is chosen as the input type
/// @param default_type  		The default input type
/// @param custom_type_title 	If not null, set as the title for input type selection
/// @param custom_type_message 	If not null, set as the text for input type selection
/// @return 			 		A data_input_result with the parsed input and the selected input type, or both null if we didn't get any data
/client/proc/input_data(list/allowed_types, custom_title = null, custom_message = null, default = null, custom_type_title = null, custom_type_message = null, default_type = null)
	. = new /datum/data_input_result(null, null) //in case anything goes wrong, return this. Thus, to check for cancellation, check for a null output_type.

	if (!src.holder)
		message_admins("Non-admin client [src.key] somehow tried to input some data. Huh?")
		logTheThing("debug", src.mob, null, "somehow attempted to input data via the input_data proc.")
		return

	var/input = null 	// The input from the src- usually text, but might be a file or something.
	var/selected_type = input(custom_type_title || "Which input type?", custom_type_message || "Input Type Selection", default_type) as null|anything in allowed_types //TODO make this a TGUI list once we can indicate defaults on those

	if (!selected_type)
		return

	if (selected_type != default_type) //clear the default if we aren't using the suggested type
		default = null

	switch(selected_type)
		if (DATA_INPUT_NUM)
			input = input(custom_title || "Enter number:", custom_message, default) as null|num

		if (DATA_INPUT_TYPE)
			var/stub = input(custom_title || "Enter part of type:", custom_message) as null|text
			if (!stub)
				boutput(src, "<span class='alert'>Cancelled.</span>")
				return
			input = get_one_match(stub, /datum, use_concrete_types = FALSE, only_admin_spawnable = FALSE)

		if (DATA_INPUT_COLOR)
			input = input(custom_title || "Select color:", custom_message, default) as null|color

		if (DATA_INPUT_TEXT)
			input = input(custom_title || "Enter text:", custom_message, default) as null|message

		if (DATA_INPUT_ICON)
			input = input(custom_title || "Select icon:", custom_message) as null|icon

		if (DATA_INPUT_BOOL)
			//lines written by the utterly insane
			input = alert(custom_title || "True or False?", custom_message + (!isnull(default) ? "(Default: [default ? "True" : "False"])" : null), "True", "False") == "True" ? TRUE : FALSE

		if (DATA_INPUT_LIST)
			//TODO uhhhhhhhh h

		if (DATA_INPUT_FILE)
			input = input(custom_title || "Select file:", custom_message) as null|file

		if (DATA_INPUT_DIR)
			input = input(custom_title || "Enter direction:", custom_message, default) as null|anything in list("NORTH", "SOUTH", "EAST", "WEST", "NORTHEAST", "SOUTHEAST", "NORTHWEST", "SOUTHWEST")
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
			input = input(custom_title || "Enter JSON:", custom_message, json_encode(default)) as null|text
			input = json_decode(input)

		if (DATA_INPUT_REF)
			input = input(custom_title || "Enter ref:", "brackets don't matter", null) as null|text
			input = locate(input)
			if (!input)
				input = locate("\[[input]\]")
			if (!input)
				boutput(src, "<span class='alert'>Invalid ref.</span>")
				return

		if (DATA_INPUT_TURF_BY_COORDS)
			var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", null) as null|num
			var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", null) as null|num
			var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", null) as null|num
			input = locate(x, y, z)
			if (!input)
				boutput(src, "<span class='alert'>Invalid turf.</span>")
				return

		if (DATA_INPUT_REFPICKER)
			var/datum/promise/promise = new
			var/datum/targetable/refpicker/abil = new
			abil.promise = promise
			src.mob.targeting_ability = abil
			src.mob.update_cursor()
			input = promise.wait_for_value() //TODO timeout? maybe?

		if (DATA_INPUT_NEW_INSTANCE)
			var/stub = input(custom_title || "Enter part of type:", custom_message) as null|text
			if (!stub)
				boutput(src, "<span class='alert'>Cancelled.</span>")
				return
			input = get_one_match(stub, /datum, use_concrete_types = FALSE, only_admin_spawnable = FALSE)

		if (DATA_INPUT_NUM_ADJUST)
			input = input("Enter amount to adjust by:", custom_message) as null|num

		if (DATA_INPUT_ATOM_ON_CURRENT_TURF) // this is ugly but it's legacy so WHATEVER
			var/list/possible = list()
			var/turf/T = get_turf(src.mob)
			possible += T.loc
			possible += T
			for (var/atom/A in T)
				possible += A
				for (var/atom/B in A)
					possible += B
			input = input(custom_title || "Select reference:", custom_message || "Reference") as null|mob|obj|turf|area in possible

		if (DATA_INPUT_NULL) // this is the one case a null output is allowed- we check to ensure the selected input type is this
			input = null //yes i am aware this is a useless statement. Clarity!!!

		if (DATA_INPUT_BUILD_LIST)
			input = build_list()

		if (DATA_INPUT_MOB_REFERENCE)
			input = input(custom_title || "Select a mob:") as null|mob in world

		if (DATA_INPUT_MATRIX)
			input = input("Create a matrix:  (format: \"a,b,c,d,e,f\" without quotes). Must have a leading 0 for decimals:", custom_message, default) as null|message
			if(input == null)
				boutput(src, "<span class='alert'>Cancelled.</span>")
				return

			var/regex/R = new("(\\w*\\.*\\w+)(,|$)", "gi")
			var/list/MV = list()
			var/i = 1
			while (R.Find(input))
				if (i <= 6)
					var/temp = R.group[1]
					MV.Add(text2num(temp))
					i++

			if (MV.len >= 6)
				input = matrix(MV[1], MV[2], MV[3], MV[4], MV[5], MV[6])

			else
				boutput(src, "<span class='alert'>Matrix too short. Cancelled.</span>")
				return

		if (DATA_INPUT_RESTORE, DATA_INPUT_PARTICLE_EDITOR, DATA_INPUT_FILTER_EDITOR) // these are meaningless for cases other than varediting, so we just return a dummy value with the input type and let the caller handle it
			input = TRUE

		else
			CRASH("Data input called with invalid data input type [selected_type]. How the fuck?")


	if (isnull(input) && selected_type != DATA_INPUT_NULL)
		boutput(src, "<span class='alert'>Cancelled.</span>")
		return

	// Done with the switch. Now we return whatever we have
	var/datum/data_input_result/result = new(input, selected_type)
	return result

///Iteratively build a new list, then return it.
/client/proc/build_list()

/// A datum holding the data the caller needs- the formatted output itself and the format the src selected (text, JSON, color, etc etc)
/// Functionally a named tuple.
/datum/data_input_result
	var/output
	var/output_type

	New(var/output, var/output_type)
		..()
		src.output = output
		src.output_type = output_type


/// Refpicker - click thing, get its ref. Tied to the data_input proc via a promise.
/datum/targetable/refpicker
	var/datum/promise/promise = null
	target_anything = TRUE
	targeted = TRUE
	max_range = 3000
	can_target_ghosts = TRUE
	dont_lock_holder = TRUE

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return TRUE

	handleCast(var/atom/selected)
		promise.fulfill(selected)
