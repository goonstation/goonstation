///Helper. shouldn't be used anywhere other than these defines
#define GET input(user, custom_message || message, custom_title || title)
/// Get raw text from the user in paragraph form
#define GET_TEXT_LONG(title, messsage)
/// Get raw text from the user in line form
#define GET_TEXT_SHORT(title, message) {GET as null|}
/// Get a number from the user
#define GET_NUM(title, message) {GET as null|num}
/// Get a file from the user
#define GET_FILE(title, message) {GET as null|file}
/// Get a color via color picker
#define GET_COLOR(title, message) {GET as null|color}


/// For inputting data for things like edit-variables, proccall, etc
/// @param allowed_types The types of input which are allowed, which the user selects from. The selected type is returned as part of the data_input_result
/// @param user 		 The client using this. Tied to a client rather than a mob so mob swaps don't prevent use.
/// @param custom_title  If not null, set as the title for the input
///	@param custom_text	 If not null, set as the text for the input
/// @return 			 A data_input_result with the parsed input and the selected input type, or both null if we didn't get any data
proc/input_data(list/allowed_types, client/user, custom_title = null, custom_text = null)
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

	// The raw input from the user- usually text, but might be a file or something.
	var/raw_input = null
	var/selected_type = tgui_input_list(user.mob, "Which input type?", "Input Type Selection", allowed_types, allowIllegal = TRUE)

	if (!selected_type)
		return

	switch(selected_type)
		if (DATA_INPUT_NUM)
			raw_input = GET_NUM("Enter number:", null)

		if (DATA_INPUT_TYPE)
			raw_input =



/// A datum holding the data we need from the user's input- the input itself and the format the user selected (text, JSON, etc etc)
/// Functionally a named tuple.
/datum/data_input_result
	var/data
	var/input_type

	New(var/data, var/input_type)
		..()
		src.data = data
		src.input_type = input_type


/// Refpicker - click thing, get its ref. Tied to the data_input proc via a promise.
/datum/targetable/refpicker
	var/datum/target = null
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
