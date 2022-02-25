/image/name_tag_hover
	plane = PLANE_NOSHADOW_ABOVE
	maptext_x = -64
	maptext_y = -5 - 8 // -7 to accomodate extra text
	maptext_width = 160
	maptext_height = 48
	icon = null
	appearance_flags = PIXEL_SCALE

	proc/set_name(name, extra)
		src.maptext = {"<span class='pixel c ol'><span style='font-size: 6px;'>[name]</span><br><span style='font-size: 5px;'>[extra]</span></span>"}

/atom/movable/name_tag
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE
	alpha = 180
	icon = null
	mouse_opacity = 0

/atom/movable/name_tag/outer
	var/atom/movable/name_tag/inner/inner
	var/image/name_tag_hover/hover_image
	var/cur_name = null
	var/cur_extra = null

	New()
		..()
		inner = new
		hover_image = new(null, src)
		src.vis_contents += inner

	disposing()
		dispose(inner)
		dispose(hover_image)
		src.vis_contents -= inner
		inner = null
		..()

	proc/set_visibility(visible)
		src.alpha = visible ? initial(src.alpha) : 0

	proc/set_name(new_name, strip_parentheses=FALSE)
		if(strip_parentheses)
			var/paren_pos = findtext(new_name, "(")
			if(paren_pos)
				new_name = copytext(new_name, 1, paren_pos)
		if(new_name != src.cur_name)
			src.inner.set_name(new_name)
			src.hover_image.set_name(new_name, cur_extra)
			src.cur_name = new_name

	proc/set_extra(new_extra)
		if(new_extra != src.cur_extra)
			src.hover_image.set_name(cur_name, new_extra)
			src.cur_extra = new_extra

	proc/show_hover(client/client)
		client.images |= src.hover_image

	proc/hide_hover(client/client)
		client.images -= src.hover_image

/atom/movable/name_tag/inner
	plane = PLANE_EXAMINE
	maptext_x = -64
	maptext_y = -5
	maptext_width = 160
	maptext_height = 48

	proc/set_name(new_name)
		src.maptext = "<span class='pixel c ol' style='font-size: 6px;'>[new_name]</span>"
