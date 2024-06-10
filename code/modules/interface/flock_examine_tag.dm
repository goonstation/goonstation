/atom/movable/name_tag/flock_examine_tag
	var/image/name_tag_examine/flock_info_tag_examine/examine_tag
	var/image/name_tag_examine_hover/flock_info_tag_examine_hover/examine_hover_tag
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE
	alpha = 180
	icon = null
	mouse_opacity = 0

	New()
		..()
		src.examine_tag = new (null, src)
		src.examine_hover_tag = new (null, src)
		qdel(src.ex_image)
		src.ex_image = null
		qdel(src.ex_hover_image)
		src.ex_hover_image = null

	disposing()
		dispose(src.examine_tag)
		dispose(src.examine_hover_tag)
		..()

	set_name(new_name, strip_parentheses = null)
		src.cur_name = new_name
		src.examine_tag.set_name(src.cur_name)
		src.examine_hover_tag.set_info_tag(src.cur_name)

	set_info_tag(info)
		src.examine_hover_tag.set_info_tag(src.cur_name, info)

	set_visibility()
		return

	show_images(client/client, ex, ex_hover)
		if (ex)
			client.images |= src.examine_tag
		else
			client.images -= src.examine_tag

		if (ex_hover)
			client.images |= src.examine_hover_tag
		else
			client.images -= src.examine_hover_tag

	proc/set_tag_offset(x, y)
		if (x)
			src.examine_tag.maptext_x += x
			src.examine_hover_tag.maptext_x += x
		if (y)
			src.examine_tag.offset_y(y)
			src.examine_hover_tag.offset_y(y)

/image/name_tag_examine/flock_info_tag_examine
	plane = PLANE_NOSHADOW_ABOVE
	maptext_x = -64
	maptext_y = -6
	maptext_width = 160
	maptext_height = 48
	icon = null
	appearance_flags = PIXEL_SCALE

	set_name(name)
		src.maptext = "<span class='pixel c ol' style='font-size: 6px;'>[name]</span>"

	proc/offset_y(y)
		src.maptext_y += y

/image/name_tag_examine_hover/flock_info_tag_examine_hover
	plane = PLANE_NOSHADOW_ABOVE
	maptext_x = -64
	maptext_y = -6 - 7 // -7 to accomodate extra text
	maptext_width = 160
	maptext_height = 48
	icon = null
	appearance_flags = PIXEL_SCALE
	var/y_offset = 0

	set_info_tag(name, info)
		if (info)
			src.maptext_y = initial(src.maptext_y) + src.y_offset
		else
			src.maptext_y = -6 + src.y_offset
		src.maptext = {"<span class='pixel c ol'><span style='font-size: 6px;'>[name]</span><br><span style='font-size: 5px;'>[info || ""]</span></span>"}

	proc/offset_y(y)
		src.y_offset = y
		src.maptext_y += src.y_offset
