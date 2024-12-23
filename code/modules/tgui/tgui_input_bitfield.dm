/**
 * Copyright (c) 2024 @Azrun
 * SPDX-License-Identifier: MIT
 */

/proc/tgui_input_bitfield(mob/user, message, title, default = 0, timeout = 0, autofocus = TRUE)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return

	var/datum/tgui_input_bitfield/picker = new(user, message, title, default, timeout, autofocus)
	picker.ui_interact(user)
	picker.wait()
	if (picker)
		. = picker.entry
		qdel(picker)

/**
 * # tgui_input_bitfield
 *
 * Datum used for instantiating and using a TGUI-controlled bitfield editor.
 */
/datum/tgui_input_bitfield
	/// The title of the TGUI window
	var/title
	/// The message to show the user
	var/message
	/// The default (or current) value, used if there is an existing value
	var/default
	/// The value the user selected, null if no selection has been made
	var/entry
	/// The time at which the tgui_input_bitfield was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_input_bitfield, after which the window will close and delete itself.
	var/timeout
	/// The bool that controls if this modal should grab window focus
	var/autofocus
	/// Boolean field describing if the tgui_input_bitfield was closed by the user.
	var/closed

/datum/tgui_input_bitfield/New(mob/user, message, title = "Bit Field", default, timeout, autofocus)
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

/datum/tgui_input_bitfield/disposing(force, ...)
	tgui_process.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_input_bitfield's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_bitfield/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		sleep(1)

/datum/tgui_input_bitfield/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BitfieldInputModal")
		ui.open()
		ui.set_autoupdate(timeout > 0)

/datum/tgui_input_bitfield/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_input_bitfield/ui_state(mob/user)
	return tgui_always_state

/datum/tgui_input_bitfield/ui_static_data(mob/user)
	. = list(
		"autofocus" = autofocus,
		"title" = title,
		"message" = message
	)

/datum/tgui_input_bitfield/ui_data(mob/user)
	. = list("timeout" = null,
			 "default_value" = default)
	if(timeout)
		.["timeout"] = clamp(((timeout - (TIME - start_time) - 1 SECONDS) / (timeout - 1 SECONDS)), 0, 1)

/datum/tgui_input_bitfield/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("modify_value")
			src.default = params["value"]
			return TRUE

		if("submit")
			var/input_num = params["entry"]
			if (!input_num)
				return
			set_entry(input_num)

			closed = TRUE
			tgui_process.close_uis(src)
			return TRUE

		if("cancel")
			closed = TRUE
			tgui_process.close_uis(src)
			return TRUE

/datum/tgui_input_bitfield/proc/set_entry(entry)
	src.entry = entry

/**
 * # async tgui_input_bitfield
 *
 * An asynchronous version of tgui_input_bitfield to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_input_bitfield/async
	/// The callback to be invoked by the tgui_input_bitfield upon having a choice made.
	var/datum/callback/callback

/datum/tgui_input_bitfield/async/New(mob/user, message, title, default, callback, timeout, autofocus)
	..(user, message, title, default, timeout, autofocus)
	src.callback = callback

/datum/tgui_input_bitfield/async/disposing(force, ...)
	qdel(callback)
	callback = null
	. = ..()

/datum/tgui_input_bitfield/async/set_entry(entry)
	. = ..()
	if(!isnull(src.entry))
		callback?.InvokeAsync(src.entry)

/datum/tgui_input_bitfield/async/wait()
	return
