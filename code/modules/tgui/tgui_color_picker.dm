/*
 * @file
 * @copyright 2023
 * @author itsmeow (https://github.com/itsmeow)
 * @license MIT
 */

/**
 * Creates a TGUI color picker window and returns the user's response.
 *
 * This proc should be used to create a color picker that the caller will wait for a response from.
 * Arguments:
 * * user - The user to show the picker to.
 * * title - The of the picker modal, shown on the top of the TGUI window.
 * * timeout - The timeout of the picker, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * autofocus - The bool that controls if this picker should grab window focus.
 */
/proc/tgui_color_picker(mob/user, message, title, default = "#000000", timeout = 0, autofocus = TRUE)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return

	var/datum/tgui_color_picker/picker = new(user, message, title, default, timeout, autofocus)
	picker.ui_interact(user)
	picker.wait()
	if (picker)
		. = picker.choice
		qdel(picker)

/**
 * Creates an asynchronous TGUI color picker window with an associated callback.
 *
 * This proc should be used to create a color picker that invokes a callback with the user's chosen option.
 * Arguments:
 * * user - The user to show the picker to.
 * * title - The of the picker modal, shown on the top of the TGUI window.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the picker, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * autofocus - The bool that controls if this picker should grab window focus.
 */
/proc/tgui_color_picker_async(mob/user, message, title, default = "#000000", datum/callback/callback, timeout = 0, autofocus = TRUE)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return

	var/datum/tgui_color_picker/async/picker = new(user, message, title, default, callback, timeout, autofocus)
	picker.ui_interact(user)

/**
 * # tgui_color_picker
 *
 * Datum used for instantiating and using a TGUI-controlled color picker.
 */
/datum/tgui_color_picker
	/// The title of the TGUI window
	var/title
	/// The message to show the user
	var/message
	/// The default choice, used if there is an existing value
	var/default
	/// The color the user selected, null if no selection has been made
	var/choice
	/// The time at which the tgui_color_picker was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_color_picker, after which the window will close and delete itself.
	var/timeout
	/// The bool that controls if this modal should grab window focus
	var/autofocus
	/// Boolean field describing if the tgui_color_picker was closed by the user.
	var/closed

/datum/tgui_color_picker/New(mob/user, message, title, default, timeout, autofocus)
	src.autofocus = autofocus
	src.title = title
	src.default = default
	src.message = message
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		SPAWN(timeout)
			qdel(src)
	. = ..()

/datum/tgui_color_picker/disposing(force, ...)
	tgui_process.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_color_picker's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_color_picker/proc/wait()
	while (!choice && !closed && !QDELETED(src))
		sleep(1)

/datum/tgui_color_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ColorPickerModal")
		ui.open()
		ui.set_autoupdate(timeout > 0)

/datum/tgui_color_picker/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_color_picker/ui_state(mob/user)
	return tgui_always_state

/datum/tgui_color_picker/ui_static_data(mob/user)
	. = list(
		"autofocus" = autofocus,
		"title" = title,
		"default_color" = default,
		"message" = message
	)

/datum/tgui_color_picker/ui_data(mob/user)
	. = list("timeout" = null)

	if(timeout)
		.["timeout"] = clamp(((timeout - (TIME - start_time) - 1 SECONDS) / (timeout - 1 SECONDS)), 0, 1)

/datum/tgui_color_picker/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			var/raw_data = lowertext(params["entry"])
			var/hex = sanitize_hexcolor(raw_data, desired_format = 6, include_crunch = TRUE)
			if (!hex)
				return
			set_choice(hex)
			closed = TRUE
			tgui_process.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			tgui_process.close_uis(src)
			return TRUE

/// Return `color` if it is a valid hex color, otherwise `default`
/datum/tgui_color_picker/proc/sanitize_hexcolor(color, desired_format = 3, include_crunch = FALSE, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// Used for conversion between RGBA hex formats.
	var/format_input_ratio = "[desired_format]:[length_char(color)-(start-1)]"

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		i += length(char)
		switch(text2ascii(char))
			if(48 to 57)		//numbers 0 to 9
				. += char
			if(97 to 102)		//letters a to f
				. += char
			if(65 to 70)		//letters A to F
				char = lowertext(char)
				. += char
			else
				break
		switch(format_input_ratio)
			if("3:8", "4:8", "3:6", "4:6") //skip next one. RRGGBB(AA) -> RGB(A)
				i += length(color[i])
			if("6:4", "6:3", "8:4", "8:3") //add current char again. RGB(A) -> RRGGBB(AA)
				. += char

	if(length_char(.) == desired_format)
		return crunch + .
	switch(format_input_ratio) //add or remove alpha channel depending on desired format.
		if("3:8", "3:4", "6:4")
			return crunch + copytext(., 1, desired_format+1)
		if("4:6", "4:3", "8:3")
			return crunch + . + ((desired_format == 4) ? "f" : "ff")
		else //not a supported hex color format.
			return default ? default : crunch + repeat_string(desired_format, "0")

/// Returns `string` repeated `times` times
/datum/tgui_color_picker/proc/repeat_string(times, string="")
	. = ""
	for(var/i in 1 to times)
		. += string

/datum/tgui_color_picker/proc/set_choice(choice)
	src.choice = choice

/**
 * # async tgui_color_picker
 *
 * An asynchronous version of tgui_color_picker to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_color_picker/async
	/// The callback to be invoked by the tgui_color_picker upon having a choice made.
	var/datum/callback/callback

/datum/tgui_color_picker/async/New(mob/user, message, title, default, callback, timeout, autofocus)
	..(user, message, title, default, timeout, autofocus)
	src.callback = callback

/datum/tgui_color_picker/async/disposing(force, ...)
	qdel(callback)
	callback = null
	. = ..()

/datum/tgui_color_picker/async/set_choice(choice)
	. = ..()
	if(!isnull(src.choice))
		callback?.InvokeAsync(src.choice)

/datum/tgui_color_picker/async/wait()
	return
