/atom/movable/name_tag
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE
	icon = null
	plane = PLANE_EXAMINE
	layer = 42
	mouse_opacity = 0
	maptext_x = -64
	maptext_y = -5
	maptext_width = 160
	maptext_height = 48
	alpha = 180
	var/cur_name = null

	proc/set_visibility(visible)
		src.alpha = visible ? initial(src.alpha) : 0

	proc/set_name(new_name, strip_parentheses=FALSE)
		if(strip_parentheses)
			var/paren_pos = findtext(new_name, "(")
			if(paren_pos)
				new_name = copytext(new_name, 1, paren_pos)
		if(new_name != src.cur_name)
			src.maptext = "<span class='pixel c ol' style='font-size: 6px;'>[new_name]</span>"
			src.cur_name = new_name
