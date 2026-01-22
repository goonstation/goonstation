/datum/buildmode/move_area
	name = "Move Area"
	desc = {"<pre>
***********************************************************
RMB on buildmode button                = Begin source area selection

Ctrl-RMB on buildmode button           = Toggle automatically reselect moved area
Shift-RMB on buildmode button          = Set turf type to leave behind
Alt-RMB on buildmode button            = Toggle moving space

Shift-LMB on turf                      = Move area to location
***********************************************************
</pre>"}
	icon_state = "buildmode_grid"
	var/toggle_auto_reselect = TRUE
	var/toggle_skip_space = TRUE
	var/type_turftoleave = /turf/simulated/floor/plating
	var/list/selected_turfs
	var/turf/source_turf
	var/turf/bottom_left_selected
	var/turf/top_right_selected
	var/tmp/image/marker = null
	var/selection_mode = FALSE


	New(datum/buildmode_holder/H)
		. = ..()
		refresh_button_text()
		marker = image('icons/misc/buildmode.dmi', "marker")
		marker.plane = PLANE_OVERLAY_EFFECTS
		marker.layer = NOLIGHT_EFFECTS_LAYER_BASE
		marker.appearance_flags = RESET_ALPHA | RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART | RESET_TRANSFORM | PIXEL_SCALE

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (shift)
			var/user_input = input("Enter a /turf path or partial name.", "Turf to leave behind", /turf/simulated/floor/plating) as null|text
			user_input = get_one_match(user_input, "/turf")
			if (!user_input)
				return
			type_turftoleave = user_input
			refresh_button_text()
			return
		if (ctrl)
			src.toggle_auto_reselect = !src.toggle_auto_reselect
			refresh_button_text()
			return
		if (alt)
			src.toggle_skip_space = !src.toggle_skip_space
			refresh_button_text()
			return

		if (!source_turf)
			selection_mode = TRUE
			update_button_text("Select a corner of your source area")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		. = ..()
		if (selection_mode)
			if (!source_turf)
				source_turf = get_turf(object)
				src.marker.loc = src.source_turf
				src.holder.owner.images += marker
				update_button_text("Select the opposite corner of your source area")
				return
			else
				if (source_turf.z == object.z)
					selected_turfs = block(source_turf, get_turf(object))
					bottom_left_selected = locate(min(source_turf.x, object.x), min(source_turf.y, object.y), source_turf.z)
					top_right_selected = locate(max(source_turf.x, object.x), max(source_turf.y, object.y), source_turf.z)
				selection_mode = FALSE
				source_turf = null
				src.holder.owner.images -= marker
				refresh_button_text()
				return
		if (shift)
			move_contents_to(get_turf(object), type_turftoleave, toggle_skip_space)
			return

	proc/refresh_button_text()
		update_button_text("Ignore Space Turfs: [src.toggle_skip_space] | Auto reselect: [src.toggle_auto_reselect] | Selected turf count: [length(src.selected_turfs) ? length(src.selected_turfs) : "none"] | Type left behind: [type_turftoleave]")


	proc/move_contents_to(var/turf/target, var/turftoleave, skip_space)
		for (var/turf/S in selected_turfs)
			if(istype(S, /turf/space) && skip_space) continue
			var/turf/T = locate(S.x - bottom_left_selected.x + target.x, S.y - bottom_left_selected.y + target.y, target.z)
			T.ReplaceWith(S.type, keep_old_material = 0)
			T.appearance = S.appearance
			T.set_density(S.density)
			T.set_dir(S.dir)

			for (var/atom/movable/AM as anything in S)
				if (istype(AM, /obj/effects/precipitation)) continue
				if (istype(AM, /obj/overlay/tile_effect)) continue
				AM.set_loc(T)
			if(turftoleave)
				S.ReplaceWith(turftoleave, keep_old_material = 0)
			else
				S.ReplaceWithSpaceForce()

		if (toggle_auto_reselect)
			var/turf/new_tr = locate(
				target.x + (top_right_selected.x - bottom_left_selected.x),
				target.y + (top_right_selected.y - bottom_left_selected.y),
				target.z
			)

			selected_turfs = block(target, new_tr)
			bottom_left_selected = target
			top_right_selected = new_tr
