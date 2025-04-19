#define MAPTEXT_FADE_IN_DURATION 4
#define MAPTEXT_LINGER_DURATION 36
#define MAPTEXT_FADE_OUT_DURATION 4

#define MAPTEXT_FADE_IN_DISTANCE 6
#define MAPTEXT_FADE_OUT_DISTANCE 8
#define MAPTEXT_SCALE_FACTOR 1.05


/**
 *	Maptext holders are `atom/movable`s that are attached to a parent maptext manager, and are responsible for displaying maptext
 *	images to a single client. When maptext is required to be displayed to a client, the parent maptext manager will instruct the
 *	maptext holder associated with that client to add a line of maptext to itself and add it to the client's images list.
 */
/atom/movable/maptext_holder
	mouse_opacity = 0

	/// The maptext manager that this maptext holder belongs to.
	var/atom/movable/maptext_manager/parent
	/// The client that this maptext holder is displaying maptext to.
	var/client/client
	/// A list of maptext images currently displayed to the client.
	var/list/image/maptext/lines
	/// The amount by which this maptext holder's `pixel_y` value has been increased as a result of new maptext lines.
	var/aggregate_height = 0

/atom/movable/maptext_holder/New(atom/movable/maptext_manager/parent, client/client)
	. = ..()

	src.parent = parent
	src.parent.vis_contents += src
	src.client = client
	src.lines = list()

/atom/movable/maptext_holder/disposing()
	for (var/image/line as anything in src.lines)
		qdel(line)

	src.parent.maptext_holders_by_client -= src.client
	src.parent = null
	src.client = null
	src.lines = null

	. = ..()

/// Adds a line of maptext to this maptext holder, displays it, animates it scrolling in, and queues its removal.
/atom/movable/maptext_holder/proc/add_line(image/maptext/text)
	// Notify the parent maptext manager if this is the first line of maptext added.
	var/line_number = length(src.lines)
	if (!line_number)
		src.parent.notify_nonempty()

	// If the previous maptext line matches the new one, increase the size of the previous maptext line and exit early.
	else if (src.lines[line_number].maptext == text.maptext)
		src.lines[line_number].transform *= MAPTEXT_SCALE_FACTOR
		qdel(text)
		return

	// Push all maptext lines upwards.
	var/text_height = (text.maptext_height / 6) * (1 + round(length(strip_html_tags(text.maptext)) / 40))
	src.aggregate_height += text_height
	animate(src, pixel_y = pixel_y + text_height, time = MAPTEXT_FADE_IN_DURATION)

	// Add the new maptext line.
	text.loc = src
	text.pixel_y -= src.aggregate_height
	src.lines += text
	src.client.images += text

	// Handle the fade-in animation.
	var/target_alpha = text.alpha
	var/target_pixel_y = text.pixel_y
	text.alpha = 0
	text.pixel_y += text_height - MAPTEXT_FADE_IN_DISTANCE

	animate(text, alpha = target_alpha, pixel_y = target_pixel_y, time = MAPTEXT_FADE_IN_DURATION, flags = ANIMATION_PARALLEL)

	// Remove the maptext line after a short delay.
	SPAWN(MAPTEXT_FADE_IN_DURATION + MAPTEXT_LINGER_DURATION)
		if (QDELETED(src))
			return

		src.lines -= text
		animate(text, alpha = 0, pixel_y = text.pixel_y + MAPTEXT_FADE_OUT_DISTANCE, time = MAPTEXT_FADE_OUT_DURATION, flags = ANIMATION_PARALLEL)

		SPAWN(MAPTEXT_FADE_OUT_DURATION + 1)
			qdel(text)

			if (!length(src.lines))
				src.pixel_y -= src.aggregate_height
				src.aggregate_height = 0
				src.parent?.notify_empty(src.client)


#undef MAPTEXT_FADE_IN_DURATION
#undef MAPTEXT_LINGER_DURATION
#undef MAPTEXT_FADE_OUT_DURATION
#undef MAPTEXT_FADE_IN_DISTANCE
#undef MAPTEXT_FADE_OUT_DISTANCE
#undef MAPTEXT_SCALE_FACTOR
