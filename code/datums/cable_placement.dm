/**
 * Advanced cable placement mode
 *
 * While the mode is on, an invisible catcher covers the nine tiles around the user.
 * Each of those tiles is treated as a 3x3 grid whose cells map onto the dirs a cable end can point at.
 * Click one cell to pick the first end, click a second cell to lay the cable.
 */
/obj/ability_button/cable_advanced_placement
	name = "Toggle advanced cable placing"
	desc = "Lay cable by clicking the edges and corners of nearby tiles."
	icon_state = "coil-adv-off"

	execute_ability()
		var/obj/item/cable_coil/C = the_item
		if (!istype(C) || !the_mob)
			return

		src.icon_state = (C.toggle_advanced_placement(the_mob) ? "coil-adv-on" : "coil-adv-off")
		. = ..()

/// Invisible screen object covering the 3x3 tiles around the user
/atom/movable/screen/cable_placement_catcher
	name = ""
	desc = ""
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = HUD_LAYER_UNDER_1
	flags = NOSPLASH | NOFPRINT
	screen_loc = "CENTER-1,CENTER-1 to CENTER+1,CENTER+1"
	/// What this catcher feeds mouse events to.
	var/datum/cable_placement/manager

	clicked(list/params)
		src.manager?.on_click(params)

	MouseMove(location, control, params)
		. = ..()
		src.manager?.on_hover(params2list(params))

	MouseExited(location, control, params)
		. = ..()
		src.manager?.hide_phantom()

	disposing()
		src.manager = null
		..()

/**
 * Drives advanced cable placement for one coil held by one mob.
 * Built on the first toggle and kept while the coil stays in the mob's hand.
 * Toggling the mode is just a `mouse_opacity` flip.
 */
/datum/cable_placement
	/// Whether the catcher is currently swallowing mouse events.
	var/active = FALSE
	var/obj/item/cable_coil/coil
	var/mob/user
	/// The client the catcher and phantom were handed to, kept so teardown works after a logout.
	var/client/attached_client
	var/atom/movable/screen/cable_placement_catcher/catcher
	/// Client-local preview of the cable that would be laid.
	var/image/phantom
	/// Turf the pending cable end sits on, null when nothing is pending.
	var/turf/anchor_turf
	/// Dir of the pending cable end (0 == centre knot), null when nothing is pending.
	var/anchor_dir
	/// Turf under the cursor, refreshed by resolve().
	var/turf/hover_turf
	/// Dir of the 3x3 cell under the cursor, refreshed by resolve().
	var/hover_dir = 0

/datum/cable_placement/New(obj/item/cable_coil/coil, mob/user)
	..()
	src.coil = coil
	src.user = user
	src.attached_client = user.client
	src.phantom = image('icons/obj/power_cond.dmi', null, "0-1[coil.iconmod]")
	src.phantom.plane = PLANE_ABOVE_LIGHTING
	src.phantom.layer = CABLE_LAYER
	src.phantom.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART
	src.phantom.alpha = 160
	src.phantom.color = coil.color
	src.catcher = new(null)
	src.catcher.manager = src
	RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(on_end_signal))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved))
	RegisterSignal(user, COMSIG_LIVING_LIFE_TICK, PROC_REF(on_life_tick))
	RegisterSignal(coil, COMSIG_ITEM_SWAP_AWAY, PROC_REF(on_end_signal))
	RegisterSignal(coil, COMSIG_ITEM_DROPPED, PROC_REF(on_end_signal))
	src.attached_client?.screen |= src.catcher
	src.attached_client?.images |= src.phantom

/datum/cable_placement/proc/set_active(state)
	src.active = state
	src.catcher.mouse_opacity = state ? MOUSE_OPACITY_OPAQUE : MOUSE_OPACITY_TRANSPARENT
	src.clear_preview()
	return src.active

/datum/cable_placement/disposing()
	src.attached_client?.screen -= src.catcher
	src.attached_client?.images -= src.phantom
	src.attached_client = null
	if (src.coil?.placement_manager == src)
		src.coil.placement_manager = null
	qdel(src.catcher)
	src.catcher = null
	src.phantom = null
	src.anchor_turf = null
	src.hover_turf = null
	src.coil = null
	src.user = null
	..()

/datum/cable_placement/proc/on_end_signal()
	if (src.active && src.user)
		boutput(src.user, SPAN_NOTICE("Advanced cable placement disabled."))
	for (var/obj/ability_button/cable_advanced_placement/button in src.coil?.ability_buttons)
		button.icon_state = "coil-adv-off"
	qdel(src)

/datum/cable_placement/proc/on_user_moved()
	if (src.active)
		src.clear_preview()

/datum/cable_placement/proc/on_life_tick(mob/living/user, mult)
	if (src.active && !can_act(user))
		src.on_end_signal()

/// Resolves a mouse event's screen-loc into `hover_turf` and `hover_dir`. Returns FALSE if it can't
/datum/cable_placement/proc/resolve(list/params)
	src.hover_turf = null
	src.hover_dir = 0
	var/client/C = src.user?.client
	if (!C)
		return FALSE
	var/static/regex/screen_loc_parser = regex(@"^(\d+):(\d*),(\d+):(\d*)$")
	if (!screen_loc_parser.Find(params["screen-loc"]))
		return FALSE
	var/turf/eye = get_turf(C.virtual_eye)
	if (!eye)
		return FALSE
	var/tile_x = text2num(screen_loc_parser.group[1])
	var/pixel_x = text2num(screen_loc_parser.group[2])
	var/tile_y = text2num(screen_loc_parser.group[3])
	var/pixel_y = text2num(screen_loc_parser.group[4])
	// screen-loc columns are viewport tiles, so the centre column depends on how wide the viewport is:
	// client.view is the text "21x15" while widescreen is on, and a plain number otherwise.
	var/view_width = istext(C.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH
	var/turf/T = locate(eye.x + (C.pixel_x / world.icon_size) + (tile_x - 1 - (view_width - 1) / 2),\
		eye.y + (C.pixel_y / world.icon_size) + (tile_y - 1 - (TILE_HEIGHT - 1) / 2),\
		eye.z)
	if (!T)
		return FALSE
	src.hover_turf = T
	src.hover_dir = src.cell_dir(pixel_x, pixel_y)
	return TRUE

/// Maps in-tile pixel coordinates onto the 3x3 cell grid, returning the cable dir that cell stands for.
/datum/cable_placement/proc/cell_dir(pixel_x, pixel_y)
	var/third = world.icon_size / 3
	. = 0
	if (pixel_x <= third)
		. |= WEST
	else if (pixel_x > world.icon_size - third)
		. |= EAST
	if (pixel_y <= third)
		. |= SOUTH
	else if (pixel_y > world.icon_size - third)
		. |= NORTH

/// Returns TRUE if this coil can lay a cable on the arg turf
/datum/cable_placement/proc/can_place_on(turf/T)
	if (!istype(T) || T.intact)
		return FALSE
	if (!istype(T, /turf/simulated/floor) && !istype(T, /turf/space/fluid))
		return FALSE
	if (!isturf(src.user?.loc))
		return FALSE
	return IN_RANGE(src.user, T, 1)

/// Returns the cable end selected by the cursor, mapped onto the anchored turf when hovering a neighbor.
/datum/cable_placement/proc/get_selected_end(turf/T)
	if (T == src.anchor_turf)
		return src.hover_dir
	return get_dir(src.anchor_turf, T) || null

/// Positions the knot preview on an edge or corner, optionally inset from the turf boundary.
/datum/cable_placement/proc/set_phantom_offset(dir, inset = 0)
	var/offset = world.icon_size / 2 - inset
	src.phantom.pixel_x = 0
	src.phantom.pixel_y = 0
	if (dir & WEST)
		src.phantom.pixel_x = -offset
	else if (dir & EAST)
		src.phantom.pixel_x = offset
	if (dir & SOUTH)
		src.phantom.pixel_y = -offset
	else if (dir & NORTH)
		src.phantom.pixel_y = offset

/datum/cable_placement/proc/on_hover(list/params)
	if (!src.resolve(params) || !src.can_place_on(src.hover_turf))
		src.hide_phantom()
		return
	if (isnull(src.anchor_dir))
		src.phantom.icon_state = "0[src.coil.iconmod]"
		src.set_phantom_offset(src.hover_dir, world.icon_size / 16)
		src.phantom.loc = src.hover_turf
		return
	var/d1 = src.anchor_dir
	var/d2 = src.get_selected_end(src.hover_turf)
	if (isnull(d2) || d1 == d2)
		src.hide_phantom()
		return
	src.phantom.icon_state = "[min(d1, d2)]-[max(d1, d2)][src.coil.iconmod]"
	src.phantom.pixel_x = 0
	src.phantom.pixel_y = 0
	src.phantom.loc = src.anchor_turf

/datum/cable_placement/proc/on_click(list/params)
	if (!params["left"])
		src.clear_preview()
		return
	if (is_incapacitated(src.user) || src.user.restrained())
		return
	if (!src.resolve(params))
		return
	var/turf/T = src.hover_turf
	if (!src.can_place_on(T))
		boutput(src.user, SPAN_ALERT("You can't lay cable there."))
		src.clear_preview()
		return
	if (src.user.can_turn())
		src.user.set_dir(get_dir(src.user, T) || src.user.dir)
	// no pending end yet: start from this cell
	if (isnull(src.anchor_dir))
		src.anchor_turf = T
		src.anchor_dir = src.hover_dir
		return
	var/end_dir = src.get_selected_end(T)
	if (isnull(end_dir))
		return
	// clicking the pending end again cancels it
	if (src.anchor_dir == end_dir)
		src.clear_preview()
		return
	var/mob/placer = src.user
	src.place(src.anchor_turf, src.anchor_dir, end_dir)
	if (QDELETED(src))
		boutput(placer, SPAN_ALERT("Your cable coil runs out!"))
		return
	src.clear_preview()
	src.on_hover(params)

/datum/cable_placement/proc/place(turf/T, dir1, dir2)
	var/nd1 = min(dir1, dir2)
	var/nd2 = max(dir1, dir2)
	for (var/obj/cable/C in T)
		if (C.d1 == nd1 && C.d2 == nd2)
			boutput(src.user, SPAN_ALERT("There's already a cable at that position."))
			return
	src.coil.plop_a_cable(T, src.user, nd1, nd2)

/// Drops the pending cable end and hides the preview.
/datum/cable_placement/proc/clear_preview()
	src.hide_phantom()
	if (isnull(src.anchor_dir))
		return
	src.anchor_turf = null
	src.anchor_dir = null

/datum/cable_placement/proc/hide_phantom()
	src.phantom?.loc = null
