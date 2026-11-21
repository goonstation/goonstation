#define CLASSIFIER_LABEL_GAP_X 6
#define CLASSIFIER_LABEL_GAP_Y 1
#define CLASSIFIER_GLYPH_WIDTH 6
#define CLASSIFIER_GLYPH_BLEED 2
#define CLASSIFIER_GLITCH_TRACKS 6

/datum/client_image_group/classifier_bracket
	var/static/list/by_target = list()
	var/image/classifier_frame/bracket
	var/category
	var/users = 0 // Count scanners, since one mob can have two.

	New(datum/classifier_callout/marker)
		..(null)
		src.category = marker.category
		src.bracket = new
		src.bracket.loc = marker.target
		src.bracket.icon_state = "brackets"
		src.bracket.color = marker.tint
		src.bracket.appearance_flags = marker.frame_flags
		src.add_image(src.bracket)
		LAZYLISTADD(src.by_target[marker.target], src)

	proc/matches(datum/classifier_callout/marker)
		return src.category == marker.category && src.bracket.color == marker.tint && src.bracket.appearance_flags == marker.frame_flags

	proc/release(client/viewer)
		if (viewer && src.subscribed_clients_with_subcount[viewer])
			src.remove_client(viewer)
		if (--src.users == 0)
			qdel(src)

	disposing()
		var/atom/target = src.bracket.loc
		var/list/groups = src.by_target[target]
		groups -= src
		if (!length(groups))
			src.by_target -= target
		// remove_image() needs bracket.loc to unregister its signal.
		src.remove_image(src.bracket)
		qdel(src.bracket)
		src.bracket = null
		. = ..()

/image/classifier_frame
	icon = 'icons/effects/classifier_brackets.dmi'
	plane = PLANE_ABOVE_LIGHTING
	layer = EFFECTS_LAYER_1
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	mouse_opacity = 0

/datum/classifier_callout
	var/atom/movable/target
	var/tint
	var/frame_flags = /image/classifier_frame::appearance_flags
	var/offset_x = 0
	var/offset_y = 0
	var/image/classifier_frame/private_image
	var/category
	var/side
	var/locked
	var/caption
	/// One bit per character.
	var/glitch_mask = 0
	var/tile_left
	var/tile_bottom
	var/frame_width
	var/frame_height
	var/overflow_dirs = 0
	var/frame_changed = TRUE
	var/tile_count
	var/measured_icon
	var/sprite_width
	var/sprite_height
	var/datum/client_image_group/classifier_bracket/shared_group
	var/delivery_changed = TRUE

	proc/use_shared_bracket(client/viewer)
		if (src.shared_group?.matches(src))
			return
		src.hide_from(viewer)
		for (var/datum/client_image_group/classifier_bracket/group as anything in /datum/client_image_group/classifier_bracket::by_target[src.target])
			if (group.matches(src))
				src.shared_group = group
				break
		if (!src.shared_group)
			src.shared_group = new(src)
		src.shared_group.users++
		src.shared_group.add_client(viewer)

	proc/hide_from(client/viewer)
		if (src.shared_group)
			src.shared_group.release(viewer)
			src.shared_group = null
		if (src.private_image)
			viewer?.images -= src.private_image
			qdel(src.private_image)
			src.private_image = null

	/// Returns TRUE if label placement needs another pass.
	proc/measure(atom/movable/target, datum/classifier_spill/spill, mob/wearer, max_size)
		var/tile_size = world.icon_size
		var/origin_x = target.step_x + target.pixel_x + target.pixel_w
		var/origin_y = target.step_y + target.pixel_y + target.pixel_z
		var/left
		var/bottom
		var/width
		var/height
		if (spill)
			src.tile_count = spill.tile_count
			left = (spill.min_x - target.x) * tile_size
			bottom = (spill.min_y - target.y) * tile_size
			width = (spill.max_x - spill.min_x + 1) * tile_size
			height = (spill.max_y - spill.min_y + 1) * tile_size
		else
			if (src.measured_icon != target.icon)
				src.measure_sprite(target)
			left = origin_x - target.icon_w
			bottom = origin_y - target.icon_z
			width = src.sprite_width
			height = src.sprite_height
			var/matrix/pose = target.transform
			if (pose && (pose.a != 1 || pose.e != 1 || pose.b || pose.c || pose.d || pose.f))
				var/half_width = (abs(pose.a) * width + abs(pose.b) * height) / 2
				var/half_height = (abs(pose.d) * width + abs(pose.e) * height) / 2
				var/center_x = left + width / 2 + pose.c
				var/center_y = bottom + height / 2 + pose.f
				left = floor(center_x - half_width)
				bottom = floor(center_y - half_height)
				width = ceil(center_x + half_width) - left
				height = ceil(center_y + half_height) - bottom
			if (target.bound_width > tile_size || target.bound_height > tile_size || target.bound_x || target.bound_y)
				var/pixloc/hull = bound_pixloc(target, SOUTHWEST)
				var/hull_x = hull.x - ((target.x - 1) * tile_size + 1)
				var/hull_y = hull.y - ((target.y - 1) * tile_size + 1)
				var/right = max(left + width, hull_x + target.bound_width)
				var/top = max(bottom + height, hull_y + target.bound_height)
				left = min(left, hull_x)
				bottom = min(bottom, hull_y)
				width = right - left
				height = top - bottom
			left -= floor(max(0, tile_size - width) / 2)
			bottom -= floor(max(0, tile_size - height) / 2)
			width = max(width, tile_size)
			height = max(height, tile_size)

		var/overflow = 0
		if (width > max_size || height > max_size)
			var/atom/center = spill ? spill.sample : wearer
			var/half_span = (max_size - tile_size) / 2
			if (width > max_size)
				var/right = left + width
				var/start_x = clamp((center.x - target.x) * tile_size - half_span, left, right - max_size)
				if (start_x > left)
					overflow |= WEST
				if (start_x + max_size < right)
					overflow |= EAST
				left = start_x
				width = max_size
			if (height > max_size)
				var/top = bottom + height
				var/start_y = clamp((center.y - target.y) * tile_size - half_span, bottom, top - max_size)
				if (start_y > bottom)
					overflow |= SOUTH
				if (start_y + max_size < top)
					overflow |= NORTH
				bottom = start_y
				height = max_size

		var/moved = src.tile_left != left || src.tile_bottom != bottom
		src.tile_left = left
		src.tile_bottom = bottom
		// The target already supplies its own pixel offsets.
		if (src.offset_x != left - origin_x || src.offset_y != bottom - origin_y)
			src.offset_x = left - origin_x
			src.offset_y = bottom - origin_y
			src.delivery_changed = TRUE
		if (src.frame_width == width && src.frame_height == height && src.overflow_dirs == overflow)
			return moved
		src.frame_width = width
		src.frame_height = height
		src.overflow_dirs = overflow
		src.frame_changed = TRUE
		return TRUE

	proc/measure_sprite(atom/movable/target)
		var/static/list/file_sizes = list()
		src.measured_icon = target.icon
		var/list/size = file_sizes[target.icon]
		if (!size)
			var/icon/frame = icon(target.icon, target.icon_state, target.dir, 1)
			size = list(frame.Width(), frame.Height())
			// Custom icons can be unique to a single mob.
			if (target.icon == initial(target.icon))
				file_sizes[target.icon] = size
		src.sprite_width = size[1]
		src.sprite_height = size[2]

	proc/label_left(corner)
		return (corner & EAST) ? src.frame_width + CLASSIFIER_LABEL_GAP_X : -CLASSIFIER_LABEL_GAP_X - CLASSIFIER_LABEL_WIDTH

	proc/label_bottom(corner)
		return (corner & NORTH) ? src.frame_height + CLASSIFIER_LABEL_GAP_Y : -CLASSIFIER_LABEL_GAP_Y - CLASSIFIER_LABEL_HEIGHT

	proc/present(client/viewer, new_side, new_locked, new_caption, glitch_chance, obj/overlay/classifier_projection/projection)
		var/redraw = src.frame_changed || src.side != new_side || src.locked != new_locked || src.caption != new_caption
		var/new_projection = projection && !projection.icon
		if (!redraw && !src.delivery_changed && !new_projection)
			return
		src.frame_changed = FALSE
		src.delivery_changed = FALSE
		if (new_side && (!src.side || src.caption != new_caption))
			src.glitch_mask = src.roll_glitches(new_caption, glitch_chance)
		src.side = new_side
		src.locked = new_locked
		src.caption = new_caption
		var/standard_frame = src.frame_width == world.icon_size && src.frame_height == world.icon_size && !src.offset_x && !src.offset_y
		if (standard_frame && !src.side && !src.locked && !src.overflow_dirs)
			src.use_shared_bracket(viewer)
			return
		if (!src.private_image)
			src.hide_from(viewer)
			src.private_image = new
			redraw = TRUE
		// The wearer can already see the projection.
		if (projection && src.private_image.loc)
			viewer.images -= src.private_image
			src.private_image.loc = null
		else if (!projection && !src.private_image.loc)
			src.private_image.loc = src.target
			viewer?.images += src.private_image
		src.private_image.color = src.tint
		src.private_image.appearance_flags = src.frame_flags
		src.private_image.pixel_x = src.offset_x
		src.private_image.pixel_y = src.offset_y
		if (redraw)
			src.draw_frame()
			if (src.side)
				src.add_label()
		if (projection)
			projection.appearance = src.private_image.appearance

	proc/draw_frame()
		src.private_image.overlays.Cut()
		var/style = src.locked ? "locked" : "brackets"
		if (src.frame_width == world.icon_size && src.frame_height == world.icon_size)
			src.private_image.icon_state = style
		else
			src.private_image.icon_state = "blank"
			var/static/list/frame_corners = list(NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST)
			for (var/corner in frame_corners)
				var/mutable_appearance/edge = mutable_appearance(src.private_image.icon, "[style]_[dir2text(corner)]", FLOAT_LAYER)
				edge.pixel_x = (corner & EAST) ? src.frame_width - world.icon_size : 0
				edge.pixel_y = (corner & NORTH) ? src.frame_height - world.icon_size : 0
				edge.mouse_opacity = 0
				src.private_image.overlays += edge
		if (src.overflow_dirs)
			var/travel_x = src.frame_width - world.icon_size
			var/travel_y = src.frame_height - world.icon_size
			for (var/direction in cardinal)
				if (!(src.overflow_dirs & direction))
					continue
				var/mutable_appearance/arrow = mutable_appearance(src.private_image.icon, "more_[dir2text(direction)]", FLOAT_LAYER)
				if (direction & (EAST | WEST))
					arrow.pixel_x = direction == EAST ? travel_x : 0
					arrow.pixel_y = floor(travel_y / 2)
				else
					arrow.pixel_x = floor(travel_x / 2)
					arrow.pixel_y = direction == NORTH ? travel_y : 0
				arrow.mouse_opacity = 0
				src.private_image.overlays += arrow

	proc/add_label()
		var/chip_state = "survey_[dir2text(src.side)]"
		var/mutable_appearance/chip = mutable_appearance('icons/effects/classifier_callout.dmi', chip_state, FLOAT_LAYER)
		var/panel_x = (src.side & EAST) ? CLASSIFIER_LABEL_GAP_X : 0
		var/panel_y = (src.side & NORTH) ? 4 : 0
		chip.pixel_x = src.label_left(src.side) - panel_x
		chip.pixel_y = src.label_bottom(src.side) - panel_y
		var/wide_spill_label = src.tile_count > 1 && length_char(src.caption) * CLASSIFIER_GLYPH_WIDTH > CLASSIFIER_LABEL_WIDTH - 4
		if (src.glitch_mask || wide_spill_label)
			src.add_glyph_caption(chip, panel_x, panel_y)
		else
			chip.maptext_x = panel_x + 2
			chip.maptext_y = panel_y
			chip.maptext_width = CLASSIFIER_LABEL_WIDTH - 4
			chip.maptext_height = CLASSIFIER_LABEL_HEIGHT
			chip.maptext = "<span class='xfont c vm'>[html_encode(src.caption)]</span>"
		chip.mouse_opacity = 0
		src.private_image.overlays += chip

	proc/glyph_caption(word)
		var/max_chars = floor((CLASSIFIER_LABEL_WIDTH - 4) / 3)
		if (length_char(word) > max_chars)
			var/suffix = src.tile_count > 1 ? " [src.tile_count]T" : ""
			return "[copytext_char(word, 1, max_chars - length(suffix) - 2)]...[suffix]"
		return word

	proc/roll_glitches(caption, chance)
		if (chance <= 0)
			return 0
		var/word = src.glyph_caption(caption)
		var/mask = 0
		for (var/index in 1 to length_char(word))
			var/codepoint = text2ascii_char(word, index)
			if (codepoint >= 33 && codepoint <= 126 && (chance >= 100 || prob(chance)))
				mask |= 1 << (index - 1)
		return mask

	proc/add_glyph_caption(mutable_appearance/chip, panel_x, panel_y)
		var/word = src.glyph_caption(src.caption)
		var/available = CLASSIFIER_LABEL_WIDTH - 4
		var/count = length_char(word)
		var/advance = min(CLASSIFIER_GLYPH_WIDTH, available / count)
		var/left = panel_x + floor((CLASSIFIER_LABEL_WIDTH - advance * count) / 2)
		var/letter_index = 0
		for (var/index in 1 to count)
			var/letter = copytext_char(word, index, index + 1)
			if (letter == " ")
				continue
			var/codepoint = text2ascii(letter)
			var/mutable_appearance/glyph
			if (codepoint >= 33 && codepoint <= 126)
				var/phase = letter_index % CLASSIFIER_GLITCH_TRACKS
				letter_index++
				var/state = (src.glitch_mask & (1 << (index - 1))) ? "[codepoint]_[phase]" : "[codepoint]_still"
				glyph = mutable_appearance('icons/effects/classifier_letters.dmi', state, FLOAT_LAYER)
				glyph.pixel_x = -CLASSIFIER_GLYPH_BLEED
			else
				glyph = new
				glyph.maptext_width = CLASSIFIER_GLYPH_WIDTH
				glyph.maptext_height = CLASSIFIER_LABEL_HEIGHT
				glyph.maptext = "<span class='xfont'>[html_encode(letter)]</span>"
			glyph.pixel_x += left + floor((index - 1) * advance) - round((CLASSIFIER_GLYPH_WIDTH - advance) / 2)
			glyph.pixel_y = panel_y + 1
			if (advance < CLASSIFIER_GLYPH_WIDTH)
				glyph.transform = matrix().Scale(advance / CLASSIFIER_GLYPH_WIDTH, 1)
			chip.overlays += glyph

#undef CLASSIFIER_LABEL_GAP_X
#undef CLASSIFIER_LABEL_GAP_Y
#undef CLASSIFIER_GLYPH_WIDTH
#undef CLASSIFIER_GLYPH_BLEED
#undef CLASSIFIER_GLITCH_TRACKS
