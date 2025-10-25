/proc/animate_expanding_outline(atom/A, min_size = -7, time = 1 SECOND, fade_time = 0.5 SECONDS)
	var/list/value_alpha_swap = list(
		1,		0,		0,		0,
		0,		1,		0,		0,
		0,		0,		0,		1,
		0,		0,		1,		0,
		0,		0,		0,		0,
	)

	A.add_filter("alpha_swap_1", 2, color_matrix_filter(value_alpha_swap, COLORSPACE_HSV))
	A.add_filter("alpha_swap_2", 3, color_matrix_filter(value_alpha_swap, COLORSPACE_HSV))

	A.add_filter("outline_alpha_mask", 1, outline_filter(min_size, "#000000", OUTLINE_SHARP))
	A.add_filter("outline_colour", 4, outline_filter(-1, "#d73715", OUTLINE_SHARP))

	A.alpha = 255
	animate(A.get_filter("outline_alpha_mask"), time = time, size = 0)

	SPAWN(time)
		animate(A.get_filter("outline_colour"), time = fade_time, alpha = 0)

	SPAWN(time + fade_time)
		A.remove_filter(list("alpha_swap_1", "alpha_swap_2", "outline_alpha_mask", "outline_colour"))

/proc/animate_shrinking_outline(atom/A, min_size = -7, time = 1 SECOND, fade_time = 0.5 SECONDS)
	var/list/value_alpha_swap = list(
		1,		0,		0,		0,
		0,		1,		0,		0,
		0,		0,		0,		1,
		0,		0,		1,		0,
		0,		0,		0,		0,
	)

	A.add_filter("alpha_swap_1", 2, color_matrix_filter(value_alpha_swap, COLORSPACE_HSV))
	A.add_filter("alpha_swap_2", 3, color_matrix_filter(value_alpha_swap, COLORSPACE_HSV))

	A.add_filter("outline_alpha_mask", 1, outline_filter(0, "#000000", OUTLINE_SHARP))
	A.add_filter("outline_colour", 4, outline_filter(-1, "#d73715", OUTLINE_SHARP))

	var/dm_filter/outline_colour = A.get_filter("outline_colour")
	outline_colour.alpha = 0
	animate(outline_colour, time = fade_time, alpha = 255)

	SPAWN(fade_time)
		animate(A.get_filter("outline_alpha_mask"), time = time, size = min_size)

	SPAWN(time + fade_time)
		A.alpha = 0
		A.remove_filter(list("alpha_swap_1", "alpha_swap_2", "outline_alpha_mask", "outline_colour"))
