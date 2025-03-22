/datum/buildmode/throw
	name = "Throw"
	desc = {"***********************************************************<br>
Left Click on mob/obj             = Select thrown object<br>
Right Click                       = Throw object<br>
Right Click on Buildmode Button   = Select throw flag<br>
***********************************************************"}
	icon_state = "buildmode4"
	var/tmp/throwing = null
	///yes this is manually maintained
	var/list/throwflags = list(
		"THROW_NORMAL" = THROW_NORMAL,\
		"THROW_CHAIRFLIP" = THROW_CHAIRFLIP,\
		"THROW_GUNIMPACT" = THROW_GUNIMPACT,\
		"THROW_SLIP" = THROW_SLIP,\
		"THROW_PEEL_SLIP" = THROW_PEEL_SLIP,\
		"THROW_BASEBALL" = THROW_BASEBALL,\
		"THROW_THROUGH_WALL" = THROW_THROUGH_WALL,\
		"THROW_GIB" = THROW_GIB,\
	 )
	var/throwflag = THROW_NORMAL

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (istype(object, /atom/movable))
			throwing = object
			src.update_button_text()

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		var/atom/movable/M = throwing
		if (istype(M))
			M.throw_at(get_turf(object), 10, 1, allow_anchored = ANCHORED, throw_type = src.throwflag)

	click_mode_right(ctrl, alt, shift)
		var/flag_string = tgui_input_list(usr, "Choose throw flag", "Throw flag", src.throwflags)
		src.throwflag = src.throwflags[flag_string]
		src.update_button_text()

	update_button_text()
		for (var/flag_string in src.throwflags)
			if (src.throwflags[flag_string] == src.throwflag)
				return ..("[src.throwing] - [flag_string]")
