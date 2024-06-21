/**
 * @file
 * @copyright 2024
 * @author ZeWaka (https://github.com/zewaka)
 * @license MIT
 */

/**
 * Creates a TGUI window with that just displays a plain message to the user.
 *
 * This should be used to display simple messages to the user,
 * in cases where you want to provide more text than you would include in an alert box.
 *
 * Arguments:
 * * user - The user to show the msgbox to.
 * * message - The content of the msgbox, shown in the body of the TGUI window.
 * * title - The title of the msgbox modal, shown on the top of the TGUI window.
 * * sanitize - Whether or not to sanitize the message. DO NOT TRUST USER INPUT. NO.
 * * timeout - The timeout of the msgbox, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * theme - The TGUI theme used for the window.
 */
/proc/tgui_message(mob/user, message, title = "Message", sanitize = TRUE, timeout = 0, theme = null)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	if (!user.client) // No NPCs or they hang Mob AI process
		return

	var/datum/tgui_message/msgbox = new(user, message, title, sanitize, timeout, theme)
	msgbox.ui_interact(user)

/**
 * # tgui_message
 *
 * Datum used for instantiating and using a TGUI-controlled simple message box
 */
/datum/tgui_message
	/// The user of the TGUI window
	var/mob/user
	/// The message displayed in the body of the TGUI window.
	var/message
	/// Whether or not to sanitize the message. DO NOT TRUST USER INPUT. NO.
	var/sanitize
	/// The time at which the tgui_modal was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_message, after which the window will close and delete itself.
	var/timeout
	/// The title of the TGUI window
	var/title
	/// The TGUI theme used for the window.
	var/theme


/datum/tgui_message/New(mob/user, message, title, sanitize, timeout, theme)
	src.user = user
	src.message = message
	src.sanitize = sanitize
	src.title = title
	src.theme = theme
	if (timeout)
		src.timeout = timeout
		start_time = TIME
		SPAWN(timeout)
			qdel(src)
	. = ..()

/datum/tgui_message/disposing(force, ...)
	tgui_process.close_uis(src)
	. = ..()

/datum/tgui_message/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MessageModal")
		ui.open()

/datum/tgui_message/ui_state(mob/user)
	return tgui_always_state

/datum/tgui_message/ui_data(mob/user)
	. = list(
		"message" = message,
		"title" = title,
		"theme" = theme,
		"sanitize" = sanitize,
	)
	if(timeout)
		.["timeout"] = clamp(((timeout - (TIME - start_time) - 1 SECONDS) / (timeout - 1 SECONDS)), 0, 1)

/datum/tgui_message/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("close")
			tgui_process.close_uis(src)
			return TRUE
