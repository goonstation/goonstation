/**
 * Creates a Message Modal window used as a simple wrapper to TGUI'fy legacy UI's
 *
 * Arguments:
 * * user - The user to show the modal to.
 * * message - The content of the modal, shown in the body of the TGUI window.
 * * title - The title of the modal, shown on the top of the TGUI window.
 * * timeout - The timeout of the modal, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * theme - The TGUI theme used for the window.
 * * sanitize - Toggle the html sanitization safety feature on or off. See MessageModal.tsx for allowed tags.
 */
/proc/message_modal(mob/user, message, title, timeout, width, height, theme, sanitize = TRUE)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	if (!user?.client) // No NPCs or they hang Mob AI process
		return
	var/datum/message_modal/message_modal = new(user, message, title, timeout, width, height, theme, sanitize)
	message_modal.ui_interact(user)

/datum/message_modal
	/// The textual body of the TGUI window
	var/message
	/// The title of the TGUI window
	var/title
	/// The lifespan of the tgui_input_pin, after which the window will close and delete itself.
	var/timeout = 0
	/// The width of the window, if left at 0 defaults to 300px
	var/width = 0
	/// The height of the window, if left at 0 window will autosize to show as much content as possible
	var/height = 0
	/// The TGUI theme used for the window
	var/theme
	/// The bool that controls if this modal should sanitize
	var/sanitize

/datum/message_modal/New(mob/user, message, title, timeout, width, height, theme, sanitize = TRUE)
	src.message = message
	src.title = title
	src.theme = theme
	src.sanitize = sanitize
	src.height = height
	src.width = width
	if (timeout)
		src.timeout = timeout
		SPAWN(timeout)
			qdel(src)
	. = ..()

/datum/message_modal/ui_state(mob/user)
	. = tgui_always_state

/datum/message_modal/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MessageModal")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/message_modal/ui_data(mob/user)
	. = list(
		"message" = message,
		"title" = title,
		"timeout" = timeout,
		"height" = height,
		"width" = width,
		"theme" = theme,
		"sanitize" = sanitize,
	)

