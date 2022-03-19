///Helper. shouldn't be used anywhere other than these defines
#define GET input(user, custom_message || message, custom_title || title)
/// Get raw text from the user in paragraph form
#define GET_TEXT_LONG(title, messsage) {GET as null|message}
/// Get raw text from the user in line form
#define GET_TEXT_SHORT(title, message) {GET as null|text}
/// Get a number from the user
#define GET_NUM(title, message) {GET as null|num}
/// Get a file from the user
#define GET_FILE(title, message) {GET as null|file}
/// Get an icon from the user
#define GET_ICON(title, message) {GET as null|icon}
/// Get a color via color picker
#define GET_COLOR(title, message) {GET as null|color}
/// Get a type (prompts for input in the case of ambiguity)
#define GET_TYPE(title, message) {get_one_match(GET_TEXT_SHORT(title, message))}


/// For inputting data for things like edit-variables, proccall, etc
/// @param allowed_types The types of input which are allowed, which the user selects from. The selected type is returned as part of the data_input_result
/// @param user 		 The client using this. Tied to a client rather than a mob so mob swaps don't prevent use.
/// @param custom_title  If not null, set as the title for the input
///	@param custom_text	 If not null, set as the text for the input
/// @return 			 A data_input_result with the parsed input and the selected input type, or both null if we didn't get any data
proc/input_data(list/allowed_types, client/user, custom_title = null, custom_text = null, default = null, default_type = null)
	. = new data_input_result(null, null) //in case anything goes wrong, return this

	if (!isclient(user)) //attempt to recover
		if (ismob(user))
			user = user.client
		else if (istype(user, /datum/mind))
			user = user.current?.client

	if (!isclient(user)) //rip
		stack_trace("Tried to input data with non-client thing [user] \ref[user] of type [user.type]")
		return

	if (user.holder)
		message_admins("Non-admin client [user.key] somehow tried to input some data. Huh?")
		return

	var/input = null 	// The input from the user- usually text, but might be a file or something.
	var/selected_type = input(user.mob, "Which input type?", "Input Type Selection") as null|text in allowed_types //TODO make this a TGUI list once we can indicate defaults on those

	if (!selected_type)
		return

	switch(selected_type)
		if (DATA_INPUT_NUM)
			input = GET_NUM("Enter number:", null)

		if (DATA_INPUT_TYPE)
			input = GET_TYPE("Enter type:", null)

		if (DATA_INPUT_COLOR)
			input = GET_COLOR("Select color:", null)

		if (DATA_INPUT_TEXT)
			input = GET_TEXT_LONG("Enter text:", null)

		if (DATA_INPUT_ICON)
			input = GET_ICON("Select icon:", null)

		if (DATA_INPUT_LIST)
			//TODO uhhhhhhhh h

		if (DATA_INPUT_FILE)
			input = GET_FILE("Select file:", null)

		if (DATA_INPUT_DIR)
			input = GET_TEXT_SHORT("Enter direction:", "Dir as text (e.g. North), case doesn't matter")
			input = input.uppertext()
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
				else
					boutput(user, "<span class='alert>Invalid dir!</span>")
					return

		if (DATA_INPUT_JSON)
			input = GET_TEXT_SHORT("Enter JSON:", null)
			input = json_decode(input)

		if (DATA_INPUT_REF)
			input = GET_TEXT_SHORT("Enter ref:", "brackets don't matter")
			input = locate(input)
			if (!input)
				input = locate("\[[input]\]")
			if (!input)
				boutput(user, "<span class='alert'>Invalid ref.</span>")
				return

		if (DATA_INPUT_TURF_BY_COORDS)
			var/x = GET_NUM("X coordinate", "Set to turf at \[_, ?, ?\]")
			var/y = GET_NUM("Y coordinate", "Set to turf at \[[x], _, ?\]")
			var/z = GET_NUM("Z coordinate", "Set to turf at \[[x], [y], _\]")
			input = locate(x, y, z)
			if (!input)
				boutput(user, "<span class='alert'>Invalid turf.</span>")
				return

		if (DATA_INPUT_REFPICKER)
			var/datum/promise/promise = new
			var/datum/targetable/refpicker/abil = new
			abil.promise = promise
			user.mob.targeting_ability = abil
			user.mob.update_cursor()
			input = promise.wait_for_value() //TODO timeout? maybe?

		if (DATA_INPUT_NEW_INSTANCE)
			var/type = GET_TYPE("Enter type to instantiate:", null)
			if (!type)
				boutput(user, "<span class='alert'>Cancelled.</span>")
				return
			input = new type

		if (DATA_INPUT_NUM_ADJUST) // identical to num, but caller will treat it differently after we return
			input = GET_NUM("Enter amount to adjust by:", null)

		if (DATA_INPUT_ATOM_ON_CURRENT_TURF) // this is ugly but it's legacy so WHATEVER
			var/list/possible = list()
			var/turf/T = get_turf(user.mob)
			possible += T.loc
			possible += T
			for (var/atom/A in T)
				possible += A
				for (var/atom/B in A)
					possible += B
			input = input("Select reference:","Reference") as null|mob|obj|turf|area in possible

		if (DATA_INPUT_NULL) // this is the one case a null output is allowed- we check to ensure the selected input type is this
			input = null //yes i am aware this is a useless statement. Clarity!!!

		if (DATA_INPUT_RESTORE) // this is meaningless for cases other than varediting, so we just return a dummy value with the input type and let the caller handle it
			input = TRUE

		if (DATA_INPUT_NEW_LIST)
			input = list()

		if (DATA_INPUT_CANCEL) // don't crash, but don't do anything.

		else
			CRASH("Data input called with invalid data input type [selected_type]. How the fuck?")


	if (isnull(input) && selected_type != DATA_INPUT_NULL)
		boutput(user, "<span class='alert'>Cancelled.</span>")

	// Done with the switch. Now we return whatever we have
	var/datum/data_input_result/result = new(input, selected_type)
	return result

/// A datum holding the data we need from the user's input- the input itself and the format the user selected (text, JSON, color, etc etc)
/// Functionally a named tuple.
/datum/data_input_result
	var/output
	var/input_type

	New(var/output, var/input_type)
		..()
		src.output = output
		src.input_type = input_type


/// Refpicker - click thing, get its ref. Tied to the data_input proc via a promise.
/datum/targetable/refpicker
	var/promise/promise = null
	target_anything = TRUE
	targeted = TRUE
	max_range = INFINITY
	can_target_ghosts = TRUE

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return TRUE

	handleCast(var/atom/selected)
		promise.fulfill(selected)

#undef GET
#undef GET_TEXT_LONG
#undef GET_TEXT_SHORT
#undef GET_FILE
#undef GET_COLOR
