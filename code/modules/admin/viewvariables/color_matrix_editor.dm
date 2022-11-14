/*
 *  Interface originally by Y0SH1M4S73R @ /tg/, licensed to Goonstation exclusively under MIT
 */

/// Nice admin editor for editing color matricies with a preview
/datum/color_matrix_editor
	var/client/owner
	var/datum/weakref/target
	var/datum/movable_preview/preview
	var/list/current_color
	var/closed

/datum/color_matrix_editor/New(user, atom/_target = null)
	owner = user
	if(islist(_target?.color))
		current_color = _target.color
	else if(istext(_target?.color))
		current_color = normalize_color_to_matrix(_target.color)
	else
		current_color = COLOR_MATRIX_IDENTITY

	src.preview = new()
	src.preview.add_background("#000", height_mult=1)
	if(_target)
		target = get_weakref(_target)
		src.preview.preview_thing.appearance = image(_target)
	else
		src.preview.preview_thing.appearance = image('icons/misc/colortest.dmi', "colors")

	src.preview.preview_thing.color = current_color
	. = ..()

/datum/color_matrix_editor/disposing(force, ...)
	qdel(preview)
	preview = null
	return ..()

/datum/color_matrix_editor/ui_state(mob/user)
	return tgui_admin_state

/datum/color_matrix_editor/ui_static_data(mob/user)
	. = list(
		"mapRef" = preview.preview_id
	)

/datum/color_matrix_editor/ui_data(mob/user)
	. = list(
		"currentColor" = current_color
	)

/datum/color_matrix_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ColorMatrixEditor")
		ui.open()

/datum/color_matrix_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("transition_color")
			current_color = params["color"]
			animate(preview.preview_thing, time = 4, color = current_color)
		if("confirm")
			on_confirm()
			tgui_process.close_uis(src)

/datum/color_matrix_editor/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/color_matrix_editor/proc/on_confirm()
	var/atom/target_atom = target.deref()
	if(istype(target_atom))
		target_atom.color = current_color

// Unused Currently, but a decent idea

// /datum/color_matrix_editor/proc/wait()
// 	while (owner && !closed && !QDELETED(src))
// 		sleep(1)

// /client/proc/open_color_matrix_editor(atom/in_atom)
// 	var/datum/color_matrix_editor/editor = new /datum/color_matrix_editor(src, in_atom)
// 	editor.ui_interact(mob)
// 	editor.wait()
// 	. = editor.current_color
// 	qdel(editor)
